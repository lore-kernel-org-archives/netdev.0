From: akpm@osdl.org
Subject: [patch 4/5] aes-586-asm: formatting changes
Date: Mon, 25 Oct 2004 12:38:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410251940.i9PJeQ910842@mail.osdl.org>
Cc: jmorris@redhat.com, netdev@oss.sgi.com, akpm@osdl.org,
        vda@port.imtp.ilyichevsk.odessa.ua
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>

- Macro parameters renamed for clarity.

- Inaccurate comments fixed.

- ebp register usage de-obfuscated (this is needed for next patch).

No real code changes.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/arch/i386/crypto/aes-i586-asm.S |  233 +++++++++++++++-----------------
 1 files changed, 115 insertions(+), 118 deletions(-)

diff -puN arch/i386/crypto/aes-i586-asm.S~aes-586-asm-formatting-changes arch/i386/crypto/aes-i586-asm.S
--- 25/arch/i386/crypto/aes-i586-asm.S~aes-586-asm-formatting-changes	2004-10-03 16:02:25.383449528 -0700
+++ 25-akpm/arch/i386/crypto/aes-i586-asm.S	2004-10-03 16:02:25.390448464 -0700
@@ -61,7 +61,6 @@
 #define r3  edx
 #define r4  esi
 #define r5  edi
-#define r6  ebp
 
 #define eaxl  al
 #define eaxh  ah
@@ -84,60 +83,61 @@
 // output registers r0, r1, r4 or r5.  
 
 // Parameters:
+// table table base address
 //   %1  out_state[0]
 //   %2  out_state[1]
 //   %3  out_state[2]
 //   %4  out_state[3]
-//   %5  table base address
-//   %6  input register for the round (destroyed)
-//   %7  scratch register for the round
-
-#define do_col(a1, a2, a3, a4, a5, a6, a7)	\
-	movzx   %l(a6),%a7;			\
-	xor     a5(,%a7,4),%a1;			\
-	movzx   %h(a6),%a7;			\
-	shr     $16,%a6;			\
-	xor     a5+tlen(,%a7,4),%a2;		\
-	movzx   %l(a6),%a7;			\
-	movzx   %h(a6),%a6;			\
-	xor     a5+2*tlen(,%a7,4),%a3;		\
-	xor     a5+3*tlen(,%a6,4),%a4;
+//   idx input register for the round (destroyed)
+//   tmp scratch register for the round
+// sched key schedule
+
+#define do_col(table, a1,a2,a3,a4, idx, tmp)	\
+	movzx   %l(idx),%tmp;			\
+	xor     table(,%tmp,4),%a1;		\
+	movzx   %h(idx),%tmp;			\
+	shr     $16,%idx;			\
+	xor     table+tlen(,%tmp,4),%a2;	\
+	movzx   %l(idx),%tmp;			\
+	movzx   %h(idx),%idx;			\
+	xor     table+2*tlen(,%tmp,4),%a3;	\
+	xor     table+3*tlen(,%idx,4),%a4;
 
 // initialise output registers from the key schedule
-
-#define do_fcol(a1, a2, a3, a4, a5, a6, a7, a8)	\
-	mov     0 a8,%a1;			\
-	movzx   %l(a6),%a7;			\
-	mov     12 a8,%a2;			\
-	xor     a5(,%a7,4),%a1;			\
-	mov     4 a8,%a4;			\
-	movzx   %h(a6),%a7;			\
-	shr     $16,%a6;			\
-	xor     a5+tlen(,%a7,4),%a2;		\
-	movzx   %l(a6),%a7;			\
-	movzx   %h(a6),%a6;			\
-	xor     a5+3*tlen(,%a6,4),%a4;		\
-	mov     %a3,%a6;			\
-	mov     8 a8,%a3;			\
-	xor     a5+2*tlen(,%a7,4),%a3;
+// NB: original a3 is in idx on exit
+#define do_fcol(table, a1,a2,a3,a4, idx, tmp, sched) \
+	mov     0 sched,%a1;			\
+	movzx   %l(idx),%tmp;			\
+	mov     12 sched,%a2;			\
+	xor     table(,%tmp,4),%a1;		\
+	mov     4 sched,%a4;			\
+	movzx   %h(idx),%tmp;			\
+	shr     $16,%idx;			\
+	xor     table+tlen(,%tmp,4),%a2;	\
+	movzx   %l(idx),%tmp;			\
+	movzx   %h(idx),%idx;			\
+	xor     table+3*tlen(,%idx,4),%a4;	\
+	mov     %a3,%idx;			\
+	mov     8 sched,%a3;			\
+	xor     table+2*tlen(,%tmp,4),%a3;
 
 // initialise output registers from the key schedule
-
-#define do_icol(a1, a2, a3, a4, a5, a6, a7, a8)	\
-	mov     0 a8,%a1;			\
-	movzx   %l(a6),%a7;			\
-	mov     4 a8,%a2;			\
-	xor     a5(,%a7,4),%a1;			\
-	mov     12 a8,%a4;			\
-	movzx   %h(a6),%a7;			\
-	shr     $16,%a6;			\
-	xor     a5+tlen(,%a7,4),%a2;		\
-	movzx   %l(a6),%a7;			\
-	movzx   %h(a6),%a6;			\
-	xor     a5+3*tlen(,%a6,4),%a4;		\
-	mov     %a3,%a6;			\
-	mov     8 a8,%a3;			\
-	xor     a5+2*tlen(,%a7,4),%a3;
+// NB: original a3 is in idx on exit
+#define do_icol(table, a1,a2,a3,a4, idx, tmp, sched) \
+	mov     0 sched,%a1;			\
+	movzx   %l(idx),%tmp;			\
+	mov     4 sched,%a2;			\
+	xor     table(,%tmp,4),%a1;		\
+	mov     12 sched,%a4;			\
+	movzx   %h(idx),%tmp;			\
+	shr     $16,%idx;			\
+	xor     table+tlen(,%tmp,4),%a2;	\
+	movzx   %l(idx),%tmp;			\
+	movzx   %h(idx),%idx;			\
+	xor     table+3*tlen(,%idx,4),%a4;	\
+	mov     %a3,%idx;			\
+	mov     8 sched,%a3;			\
+	xor     table+2*tlen(,%tmp,4),%a3;
 
 
 // original Gladman had conditional saves to MMX regs.
@@ -149,42 +149,39 @@
 
 // This macro performs a forward encryption cycle. It is entered with
 // the first previous round column values in r0, r1, r4 and r5 and
-// exits with the final values in the same registers, using the MMX
-// registers mm0-mm1 or the stack for temporary storage
+// exits with the final values in the same registers, using stack
+// for temporary storage
 
-// mov current column values into the MMX registers
 #define fwd_rnd(arg, table)					\
-	/* mov current column values into the MMX registers */	\
 	mov     %r0,%r2;					\
 	save   (0,r1);						\
 	save   (1,r5);						\
 								\
 	/* compute new column values */				\
-	do_fcol(r0,r5,r4,r1,table, r2,r3, arg);			\
-	do_col (r4,r1,r0,r5,table, r2,r3);			\
+	do_fcol(table, r0,r5,r4,r1, r2,r3, arg);		\
+	do_col (table, r4,r1,r0,r5, r2,r3);			\
 	restore(r2,0);						\
-	do_col (r1,r0,r5,r4,table, r2,r3);			\
+	do_col (table, r1,r0,r5,r4, r2,r3);			\
 	restore(r2,1);						\
-	do_col (r5,r4,r1,r0,table, r2,r3);
+	do_col (table, r5,r4,r1,r0, r2,r3);
 
 // This macro performs an inverse encryption cycle. It is entered with
 // the first previous round column values in r0, r1, r4 and r5 and
-// exits with the final values in the same registers, using the MMX
-// registers mm0-mm1 or the stack for temporary storage
+// exits with the final values in the same registers, using stack
+// for temporary storage
 
 #define inv_rnd(arg, table)					\
-	/* mov current column values into the MMX registers */	\
 	mov     %r0,%r2;					\
 	save    (0,r1);						\
 	save    (1,r5);						\
 								\
 	/* compute new column values */				\
-	do_icol(r0,r1,r4,r5, table, r2,r3, arg);		\
-	do_col (r4,r5,r0,r1, table, r2,r3);			\
+	do_icol(table, r0,r1,r4,r5, r2,r3, arg);		\
+	do_col (table, r4,r5,r0,r1, r2,r3);			\
 	restore(r2,0);						\
-	do_col (r1,r4,r5,r0, table, r2,r3);			\
+	do_col (table, r1,r4,r5,r0, r2,r3);			\
 	restore(r2,1);						\
-	do_col (r5,r0,r1,r4, table, r2,r3);
+	do_col (table, r5,r0,r1,r4, r2,r3);
 
 // AES (Rijndael) Encryption Subroutine
 
@@ -208,7 +205,7 @@ aes_enc_blk:
 	push    %esi
 	mov     nrnd(%ebp),%r3   // number of rounds
 	push    %edi
-	lea     ekey(%ebp),%r6   // key pointer
+	lea     ekey(%ebp),%ebp  // key pointer
 
 // input four columns and xor in first round key
 
@@ -216,47 +213,47 @@ aes_enc_blk:
 	mov     4(%r2),%r1
 	mov     8(%r2),%r4
 	mov     12(%r2),%r5
-	xor     (%r6),%r0
-	xor     4(%r6),%r1
-	xor     8(%r6),%r4
-	xor     12(%r6),%r5
+	xor     (%ebp),%r0
+	xor     4(%ebp),%r1
+	xor     8(%ebp),%r4
+	xor     12(%ebp),%r5
 
 	sub     $8,%esp           // space for register saves on stack
-	add     $16,%r6           // increment to next round key   
+	add     $16,%ebp          // increment to next round key
 	sub     $10,%r3          
 	je      4f              // 10 rounds for 128-bit key
-	add     $32,%r6
+	add     $32,%ebp
 	sub     $2,%r3
 	je      3f              // 12 rounds for 128-bit key
-	add     $32,%r6
+	add     $32,%ebp
 
-2:	fwd_rnd( -64(%r6) ,ft_tab)	// 14 rounds for 128-bit key
-	fwd_rnd( -48(%r6) ,ft_tab)
-3:	fwd_rnd( -32(%r6) ,ft_tab)	// 12 rounds for 128-bit key
-	fwd_rnd( -16(%r6) ,ft_tab)
-4:	fwd_rnd(    (%r6) ,ft_tab)	// 10 rounds for 128-bit key
-	fwd_rnd( +16(%r6) ,ft_tab)
-	fwd_rnd( +32(%r6) ,ft_tab)
-	fwd_rnd( +48(%r6) ,ft_tab)
-	fwd_rnd( +64(%r6) ,ft_tab)
-	fwd_rnd( +80(%r6) ,ft_tab)
-	fwd_rnd( +96(%r6) ,ft_tab)
-	fwd_rnd(+112(%r6) ,ft_tab)
-	fwd_rnd(+128(%r6) ,ft_tab)
-	fwd_rnd(+144(%r6) ,fl_tab)	// last round uses a different table
+2:	fwd_rnd( -64(%ebp) ,ft_tab)	// 14 rounds for 128-bit key
+	fwd_rnd( -48(%ebp) ,ft_tab)
+3:	fwd_rnd( -32(%ebp) ,ft_tab)	// 12 rounds for 128-bit key
+	fwd_rnd( -16(%ebp) ,ft_tab)
+4:	fwd_rnd(    (%ebp) ,ft_tab)	// 10 rounds for 128-bit key
+	fwd_rnd( +16(%ebp) ,ft_tab)
+	fwd_rnd( +32(%ebp) ,ft_tab)
+	fwd_rnd( +48(%ebp) ,ft_tab)
+	fwd_rnd( +64(%ebp) ,ft_tab)
+	fwd_rnd( +80(%ebp) ,ft_tab)
+	fwd_rnd( +96(%ebp) ,ft_tab)
+	fwd_rnd(+112(%ebp) ,ft_tab)
+	fwd_rnd(+128(%ebp) ,ft_tab)
+	fwd_rnd(+144(%ebp) ,fl_tab)	// last round uses a different table
 
 // move final values to the output array.  CAUTION: the 
 // order of these assigns rely on the register mappings
 
 	add     $8,%esp
-	mov     out_blk+12(%esp),%r6
-	mov     %r5,12(%r6)
+	mov     out_blk+12(%esp),%ebp
+	mov     %r5,12(%ebp)
 	pop     %edi
-	mov     %r4,8(%r6)
+	mov     %r4,8(%ebp)
 	pop     %esi
-	mov     %r1,4(%r6)
+	mov     %r1,4(%ebp)
 	pop     %ebx
-	mov     %r0,(%r6)
+	mov     %r0,(%ebp)
 	pop     %ebp
 	mov     $1,%eax
 	ret
@@ -283,10 +280,10 @@ aes_dec_blk:
 	push    %esi
 	mov     nrnd(%ebp),%r3   // number of rounds
 	push    %edi
-	lea     dkey(%ebp),%r6   // key pointer
+	lea     dkey(%ebp),%ebp  // key pointer
 	mov     %r3,%r0
 	shl     $4,%r0
-	add     %r0,%r6
+	add     %r0,%ebp
 	
 // input four columns and xor in first round key
 
@@ -294,47 +291,47 @@ aes_dec_blk:
 	mov     4(%r2),%r1
 	mov     8(%r2),%r4
 	mov     12(%r2),%r5
-	xor     (%r6),%r0
-	xor     4(%r6),%r1
-	xor     8(%r6),%r4
-	xor     12(%r6),%r5
+	xor     (%ebp),%r0
+	xor     4(%ebp),%r1
+	xor     8(%ebp),%r4
+	xor     12(%ebp),%r5
 
-	sub     $8,%esp           // space for register saves on stack
-	sub     $16,%r6           // increment to next round key   
+	sub     $8,%esp         // space for register saves on stack
+	sub     $16,%ebp        // increment to next round key
 	sub     $10,%r3          
 	je      4f              // 10 rounds for 128-bit key
-	sub     $32,%r6
+	sub     $32,%ebp
 	sub     $2,%r3
 	je      3f              // 12 rounds for 128-bit key
-	sub     $32,%r6
+	sub     $32,%ebp
 
-2:	inv_rnd( +64(%r6), it_tab)	// 14 rounds for 128-bit key 
-	inv_rnd( +48(%r6), it_tab)
-3:	inv_rnd( +32(%r6), it_tab)	// 12 rounds for 128-bit key
-	inv_rnd( +16(%r6), it_tab)
-4:	inv_rnd(    (%r6), it_tab)	// 10 rounds for 128-bit key
-	inv_rnd( -16(%r6), it_tab)
-	inv_rnd( -32(%r6), it_tab)
-	inv_rnd( -48(%r6), it_tab)
-	inv_rnd( -64(%r6), it_tab)
-	inv_rnd( -80(%r6), it_tab)
-	inv_rnd( -96(%r6), it_tab)
-	inv_rnd(-112(%r6), it_tab)
-	inv_rnd(-128(%r6), it_tab)
-	inv_rnd(-144(%r6), il_tab)	// last round uses a different table
+2:	inv_rnd( +64(%ebp), it_tab)	// 14 rounds for 128-bit key
+	inv_rnd( +48(%ebp), it_tab)
+3:	inv_rnd( +32(%ebp), it_tab)	// 12 rounds for 128-bit key
+	inv_rnd( +16(%ebp), it_tab)
+4:	inv_rnd(    (%ebp), it_tab)	// 10 rounds for 128-bit key
+	inv_rnd( -16(%ebp), it_tab)
+	inv_rnd( -32(%ebp), it_tab)
+	inv_rnd( -48(%ebp), it_tab)
+	inv_rnd( -64(%ebp), it_tab)
+	inv_rnd( -80(%ebp), it_tab)
+	inv_rnd( -96(%ebp), it_tab)
+	inv_rnd(-112(%ebp), it_tab)
+	inv_rnd(-128(%ebp), it_tab)
+	inv_rnd(-144(%ebp), il_tab)	// last round uses a different table
 
 // move final values to the output array.  CAUTION: the 
 // order of these assigns rely on the register mappings
 
 	add     $8,%esp
-	mov     out_blk+12(%esp),%r6
-	mov     %r5,12(%r6)
+	mov     out_blk+12(%esp),%ebp
+	mov     %r5,12(%ebp)
 	pop     %edi
-	mov     %r4,8(%r6)
+	mov     %r4,8(%ebp)
 	pop     %esi
-	mov     %r1,4(%r6)
+	mov     %r1,4(%ebp)
 	pop     %ebx
-	mov     %r0,(%r6)
+	mov     %r0,(%ebp)
 	pop     %ebp
 	mov     $1,%eax
 	ret
_
