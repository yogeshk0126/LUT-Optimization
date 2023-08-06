module modified_LUT(input [4:0] X,output [3:0] d, output [10:0] product,output reg [9:0] LUT_OUT,output [9:0] barrel_out,output s0,s1,output [8:0] w1 );

//made by Souhardya Mondal ,213070092

//W refers to the no.of bits in the binary
// representation of A. Here A is 32. Thus, W=6
//L refers to the size of the bus of  input x. Here, L=5 is taken.

parameter W=6;
parameter A=32;

address_generation_unit aa(X,d);   // This block will map the input address X to the address which goes to the 4 to 9 decoder

// notation used same as in the paper. 
//" LUT Optimization for Memory-Based Computation" 

wire reset;
four_to_nine_decoder(d,w1); // w1 is the address given to the LUT . In paper, it is represented as w.

control_ckt(X,d[3],s0,s1,reset); // produces the s0,s1 and reset signal

 barrel b11( LUT_OUT ,{s1,s0} ,barrel_out); // barrel shifter which produces the required left shifter
 // s1,s0 determine the amount of shifting required.



assign product = (X[4])? (16*A + barrel_out):(16*A - barrel_out) ;



always @(w1,X,reset)
begin
  if(reset==1)
  LUT_OUT=0;
  else
  begin
	case (w1)
	9'b000000001: LUT_OUT=A;
	9'b000000010: LUT_OUT=3*A;
	9'b000000100: LUT_OUT=5*A;
	9'b000001000: LUT_OUT=7*A;
	9'b000010000: LUT_OUT=9*A;
	9'b000100000: LUT_OUT=11*A;
	9'b001000000: LUT_OUT=13*A;
	9'b010000000: LUT_OUT=15*A;
	9'b100000001: LUT_OUT=2*A;   // 2A is stored here. Why? Explanation in paper
	endcase
	end
	
	
end




	
	
	








endmodule



module control_ckt(input [4:0] x,input d3,output s0,s1,reset);

assign s0= ~(t1|x[0]);
assign t1=~(~x[2]| x[1]);

assign s1=~(x[0]| x[1]);

assign reset=d3 & x[4];

endmodule





module address_generation_unit(input [4:0] X,output reg [3:0] d,Xbarbar,output [3:0]Xbar);

wire [3:0] Xlbar;
two_comp t1(X[3:0] , Xlbar);
 // Xlbar stores the 2's complement of the 4 LSBs of input X
assign Xl=X[3:0]; // Xl stores just the 4LSBs of X
//notations as per the paper
assign Xbar=X[4]?X[3:0] :Xlbar;     

always @(Xbar)

//defining Xbarbar here
begin

 if (Xbar[2:0]==0)
	Xbarbar={3'b0,Xbar[3]};
	else if (Xbar[1:0]==0)
	Xbarbar={2'b0,Xbar[3:2]};
	else if ( Xbar[0]==0)
	Xbarbar={1'b0,Xbar[3:1]};
	else
	Xbarbar=Xbar;
	
end

// mapping of Xbarbar to d

integer i;
always @(Xbarbar)
begin
 d[3]= ~(Xbarbar[0]);
for(i=0;i<=2;i=i+1)
begin
 d[i]=Xbarbar[i+1];
 end
 end
endmodule










//operand size for barrel shifting is W+4=10 here.
//need to implement maximum shifting =3




module barrel( input [9:0] d_in ,input [1:0] control , output [9:0] y); //barrel shifter architecture from Prof. Dinesh Sharma's Class

wire [9:0] q;
row_of_mux r1(d_in,{d_in[7:0],2'b0},control[1],q);

row_of_mux r2(q,{q[8:0],1'b0},control[0],y);



endmodule

module mux_2to1(input a,input b, input sel ,output out1);

 assign out1=sel?b:a;
 
 endmodule

module row_of_mux(input [9:0] a,input [9:0] b ,input sel, output [9:0] out1);


 mux_2to1 f7(   a[9],b[9],   sel,  out1[9]);
 mux_2to1 f8(   a[8],b[8], 	 sel,  out1[8]);
 mux_2to1 f9(   a[7],b[7], 	 sel,  out1[7]);
 mux_2to1 f10(  a[6],b[6],   sel,  out1[6]);
 mux_2to1 f11(  a[5],b[5],   sel,  out1[5]);
 mux_2to1 f12(  a[4],b[4],   sel,  out1[4]);
 mux_2to1 f13(  a[3],b[3],   sel,  out1[3]);
 mux_2to1 f14(  a[2],b[2],   sel,  out1[2]);
 mux_2to1 f15(  a[1],b[1],   sel,  out1[1]);
 mux_2to1 f16(  a[0],b[0],   sel,  out1[0]);
 endmodule


module two_comp(input [3:0] in, output [3:0] out);

assign out=~in +1;

endmodule



module four_to_nine_decoder(input [3:0] d,output [8:0] w);


// Why 9 outputs required? Because we will store A,3A,5A,.....,15A and then 2A.



three_to_eight_decoder(d[2:0],w[7:0]);

assign w[8]=d[3] & w[0];

endmodule






module three_to_eight_decoder(input [2:0] d, output reg [7:0] w);

always @(d)
begin
	case(d)
	
	0:begin w[0]=1;w[7:1]=0; end
    1:begin w[1]=1;w[7:2]=0; w[0]=0; end 	
	2:begin w[2]=1;w[7:3]=0; w[1:0]=0; end 	
	3:begin w[3]=1;w[7:4]=0; w[2:0]=0; end 	
    4:begin w[4]=1;w[7:5]=0; w[3:0]=0; end 	
    5:begin w[5]=1;w[7:6]=0; w[4:0]=0; end 	
    6:begin w[6]=1;w[7]=0; w[5:0]=0; end 	
    7:begin w[7]=1;w[6:0]=0;  end 	
     endcase
	 
end
endmodule



