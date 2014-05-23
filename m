From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/5] net: filter: remove DL macro
Date: Fri, 23 May 2014 18:43:57 +0200
Message-ID: <1400863441-3711-2-git-send-email-dborkman@redhat.com>
References: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbaEWQoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 12:44:07 -0400
In-Reply-To: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lets get rid of this macro. After commit 5bcfedf06f7f ("net: filter:
simplify label names from jump-table"), labels have become more
readable due to omission of BPF_ prefix but at the same time more
generic, so that things like `git grep -n` would not find them. As
a middle path, lets get rid of the DL macro as it's not strictly
needed and would otherwise just hide the full name.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/filter.h |   3 -
 net/core/filter.c      | 193 +++++++++++++++++++++++++------------------------
 2 files changed, 99 insertions(+), 97 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 7977b39..2b0056a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -37,9 +37,6 @@
 #define BPF_CALL	0x80	/* function call */
 #define BPF_EXIT	0x90	/* function return */
 
-/* Placeholder/dummy for 0 */
-#define BPF_0		0
-
 /* Register numbers */
 enum {
 	BPF_REG_0 = 0,
diff --git a/net/core/filter.c b/net/core/filter.c
index 7067cb2..b3b0889 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -160,95 +160,100 @@ static unsigned int __sk_run_filter(void *ctx, const struct sock_filter_int *ins
 	static const void *jumptable[256] = {
 		[0 ... 255] = &&default_label,
 		/* Now overwrite non-defaults ... */
-#define DL(A, B, C)	[BPF_##A|BPF_##B|BPF_##C] = &&A##_##B##_##C
-		DL(ALU, ADD, X),
-		DL(ALU, ADD, K),
-		DL(ALU, SUB, X),
-		DL(ALU, SUB, K),
-		DL(ALU, AND, X),
-		DL(ALU, AND, K),
-		DL(ALU, OR, X),
-		DL(ALU, OR, K),
-		DL(ALU, LSH, X),
-		DL(ALU, LSH, K),
-		DL(ALU, RSH, X),
-		DL(ALU, RSH, K),
-		DL(ALU, XOR, X),
-		DL(ALU, XOR, K),
-		DL(ALU, MUL, X),
-		DL(ALU, MUL, K),
-		DL(ALU, MOV, X),
-		DL(ALU, MOV, K),
-		DL(ALU, DIV, X),
-		DL(ALU, DIV, K),
-		DL(ALU, MOD, X),
-		DL(ALU, MOD, K),
-		DL(ALU, NEG, 0),
-		DL(ALU, END, TO_BE),
-		DL(ALU, END, TO_LE),
-		DL(ALU64, ADD, X),
-		DL(ALU64, ADD, K),
-		DL(ALU64, SUB, X),
-		DL(ALU64, SUB, K),
-		DL(ALU64, AND, X),
-		DL(ALU64, AND, K),
-		DL(ALU64, OR, X),
-		DL(ALU64, OR, K),
-		DL(ALU64, LSH, X),
-		DL(ALU64, LSH, K),
-		DL(ALU64, RSH, X),
-		DL(ALU64, RSH, K),
-		DL(ALU64, XOR, X),
-		DL(ALU64, XOR, K),
-		DL(ALU64, MUL, X),
-		DL(ALU64, MUL, K),
-		DL(ALU64, MOV, X),
-		DL(ALU64, MOV, K),
-		DL(ALU64, ARSH, X),
-		DL(ALU64, ARSH, K),
-		DL(ALU64, DIV, X),
-		DL(ALU64, DIV, K),
-		DL(ALU64, MOD, X),
-		DL(ALU64, MOD, K),
-		DL(ALU64, NEG, 0),
-		DL(JMP, CALL, 0),
-		DL(JMP, JA, 0),
-		DL(JMP, JEQ, X),
-		DL(JMP, JEQ, K),
-		DL(JMP, JNE, X),
-		DL(JMP, JNE, K),
-		DL(JMP, JGT, X),
-		DL(JMP, JGT, K),
-		DL(JMP, JGE, X),
-		DL(JMP, JGE, K),
-		DL(JMP, JSGT, X),
-		DL(JMP, JSGT, K),
-		DL(JMP, JSGE, X),
-		DL(JMP, JSGE, K),
-		DL(JMP, JSET, X),
-		DL(JMP, JSET, K),
-		DL(JMP, EXIT, 0),
-		DL(STX, MEM, B),
-		DL(STX, MEM, H),
-		DL(STX, MEM, W),
-		DL(STX, MEM, DW),
-		DL(STX, XADD, W),
-		DL(STX, XADD, DW),
-		DL(ST, MEM, B),
-		DL(ST, MEM, H),
-		DL(ST, MEM, W),
-		DL(ST, MEM, DW),
-		DL(LDX, MEM, B),
-		DL(LDX, MEM, H),
-		DL(LDX, MEM, W),
-		DL(LDX, MEM, DW),
-		DL(LD, ABS, W),
-		DL(LD, ABS, H),
-		DL(LD, ABS, B),
-		DL(LD, IND, W),
-		DL(LD, IND, H),
-		DL(LD, IND, B),
-#undef DL
+		/* 32 bit ALU operations */
+		[BPF_ALU | BPF_ADD | BPF_X] = &&ALU_ADD_X,
+		[BPF_ALU | BPF_ADD | BPF_K] = &&ALU_ADD_K,
+		[BPF_ALU | BPF_SUB | BPF_X] = &&ALU_SUB_X,
+		[BPF_ALU | BPF_SUB | BPF_K] = &&ALU_SUB_K,
+		[BPF_ALU | BPF_AND | BPF_X] = &&ALU_AND_X,
+		[BPF_ALU | BPF_AND | BPF_K] = &&ALU_AND_K,
+		[BPF_ALU | BPF_OR | BPF_X]  = &&ALU_OR_X,
+		[BPF_ALU | BPF_OR | BPF_K]  = &&ALU_OR_K,
+		[BPF_ALU | BPF_LSH | BPF_X] = &&ALU_LSH_X,
+		[BPF_ALU | BPF_LSH | BPF_K] = &&ALU_LSH_K,
+		[BPF_ALU | BPF_RSH | BPF_X] = &&ALU_RSH_X,
+		[BPF_ALU | BPF_RSH | BPF_K] = &&ALU_RSH_K,
+		[BPF_ALU | BPF_XOR | BPF_X] = &&ALU_XOR_X,
+		[BPF_ALU | BPF_XOR | BPF_K] = &&ALU_XOR_K,
+		[BPF_ALU | BPF_MUL | BPF_X] = &&ALU_MUL_X,
+		[BPF_ALU | BPF_MUL | BPF_K] = &&ALU_MUL_K,
+		[BPF_ALU | BPF_MOV | BPF_X] = &&ALU_MOV_X,
+		[BPF_ALU | BPF_MOV | BPF_K] = &&ALU_MOV_K,
+		[BPF_ALU | BPF_DIV | BPF_X] = &&ALU_DIV_X,
+		[BPF_ALU | BPF_DIV | BPF_K] = &&ALU_DIV_K,
+		[BPF_ALU | BPF_MOD | BPF_X] = &&ALU_MOD_X,
+		[BPF_ALU | BPF_MOD | BPF_K] = &&ALU_MOD_K,
+		[BPF_ALU | BPF_NEG] = &&ALU_NEG,
+		[BPF_ALU | BPF_END | BPF_TO_BE] = &&ALU_END_TO_BE,
+		[BPF_ALU | BPF_END | BPF_TO_LE] = &&ALU_END_TO_LE,
+		/* 64 bit ALU operations */
+		[BPF_ALU64 | BPF_ADD | BPF_X] = &&ALU64_ADD_X,
+		[BPF_ALU64 | BPF_ADD | BPF_K] = &&ALU64_ADD_K,
+		[BPF_ALU64 | BPF_SUB | BPF_X] = &&ALU64_SUB_X,
+		[BPF_ALU64 | BPF_SUB | BPF_K] = &&ALU64_SUB_K,
+		[BPF_ALU64 | BPF_AND | BPF_X] = &&ALU64_AND_X,
+		[BPF_ALU64 | BPF_AND | BPF_K] = &&ALU64_AND_K,
+		[BPF_ALU64 | BPF_OR | BPF_X] = &&ALU64_OR_X,
+		[BPF_ALU64 | BPF_OR | BPF_K] = &&ALU64_OR_K,
+		[BPF_ALU64 | BPF_LSH | BPF_X] = &&ALU64_LSH_X,
+		[BPF_ALU64 | BPF_LSH | BPF_K] = &&ALU64_LSH_K,
+		[BPF_ALU64 | BPF_RSH | BPF_X] = &&ALU64_RSH_X,
+		[BPF_ALU64 | BPF_RSH | BPF_K] = &&ALU64_RSH_K,
+		[BPF_ALU64 | BPF_XOR | BPF_X] = &&ALU64_XOR_X,
+		[BPF_ALU64 | BPF_XOR | BPF_K] = &&ALU64_XOR_K,
+		[BPF_ALU64 | BPF_MUL | BPF_X] = &&ALU64_MUL_X,
+		[BPF_ALU64 | BPF_MUL | BPF_K] = &&ALU64_MUL_K,
+		[BPF_ALU64 | BPF_MOV | BPF_X] = &&ALU64_MOV_X,
+		[BPF_ALU64 | BPF_MOV | BPF_K] = &&ALU64_MOV_K,
+		[BPF_ALU64 | BPF_ARSH | BPF_X] = &&ALU64_ARSH_X,
+		[BPF_ALU64 | BPF_ARSH | BPF_K] = &&ALU64_ARSH_K,
+		[BPF_ALU64 | BPF_DIV | BPF_X] = &&ALU64_DIV_X,
+		[BPF_ALU64 | BPF_DIV | BPF_K] = &&ALU64_DIV_K,
+		[BPF_ALU64 | BPF_MOD | BPF_X] = &&ALU64_MOD_X,
+		[BPF_ALU64 | BPF_MOD | BPF_K] = &&ALU64_MOD_K,
+		[BPF_ALU64 | BPF_NEG] = &&ALU64_NEG,
+		/* Call instruction */
+		[BPF_JMP | BPF_CALL] = &&JMP_CALL,
+		/* Jumps */
+		[BPF_JMP | BPF_JA] = &&JMP_JA,
+		[BPF_JMP | BPF_JEQ | BPF_X] = &&JMP_JEQ_X,
+		[BPF_JMP | BPF_JEQ | BPF_K] = &&JMP_JEQ_K,
+		[BPF_JMP | BPF_JNE | BPF_X] = &&JMP_JNE_X,
+		[BPF_JMP | BPF_JNE | BPF_K] = &&JMP_JNE_K,
+		[BPF_JMP | BPF_JGT | BPF_X] = &&JMP_JGT_X,
+		[BPF_JMP | BPF_JGT | BPF_K] = &&JMP_JGT_K,
+		[BPF_JMP | BPF_JGE | BPF_X] = &&JMP_JGE_X,
+		[BPF_JMP | BPF_JGE | BPF_K] = &&JMP_JGE_K,
+		[BPF_JMP | BPF_JSGT | BPF_X] = &&JMP_JSGT_X,
+		[BPF_JMP | BPF_JSGT | BPF_K] = &&JMP_JSGT_K,
+		[BPF_JMP | BPF_JSGE | BPF_X] = &&JMP_JSGE_X,
+		[BPF_JMP | BPF_JSGE | BPF_K] = &&JMP_JSGE_K,
+		[BPF_JMP | BPF_JSET | BPF_X] = &&JMP_JSET_X,
+		[BPF_JMP | BPF_JSET | BPF_K] = &&JMP_JSET_K,
+		/* Program return */
+		[BPF_JMP | BPF_EXIT] = &&JMP_EXIT,
+		/* Store instructions */
+		[BPF_STX | BPF_MEM | BPF_B] = &&STX_MEM_B,
+		[BPF_STX | BPF_MEM | BPF_H] = &&STX_MEM_H,
+		[BPF_STX | BPF_MEM | BPF_W] = &&STX_MEM_W,
+		[BPF_STX | BPF_MEM | BPF_DW] = &&STX_MEM_DW,
+		[BPF_STX | BPF_XADD | BPF_W] = &&STX_XADD_W,
+		[BPF_STX | BPF_XADD | BPF_DW] = &&STX_XADD_DW,
+		[BPF_ST | BPF_MEM | BPF_B] = &&ST_MEM_B,
+		[BPF_ST | BPF_MEM | BPF_H] = &&ST_MEM_H,
+		[BPF_ST | BPF_MEM | BPF_W] = &&ST_MEM_W,
+		[BPF_ST | BPF_MEM | BPF_DW] = &&ST_MEM_DW,
+		/* Load instructions */
+		[BPF_LDX | BPF_MEM | BPF_B] = &&LDX_MEM_B,
+		[BPF_LDX | BPF_MEM | BPF_H] = &&LDX_MEM_H,
+		[BPF_LDX | BPF_MEM | BPF_W] = &&LDX_MEM_W,
+		[BPF_LDX | BPF_MEM | BPF_DW] = &&LDX_MEM_DW,
+		[BPF_LD | BPF_ABS | BPF_W] = &&LD_ABS_W,
+		[BPF_LD | BPF_ABS | BPF_H] = &&LD_ABS_H,
+		[BPF_LD | BPF_ABS | BPF_B] = &&LD_ABS_B,
+		[BPF_LD | BPF_IND | BPF_W] = &&LD_IND_W,
+		[BPF_LD | BPF_IND | BPF_H] = &&LD_IND_H,
+		[BPF_LD | BPF_IND | BPF_B] = &&LD_IND_B,
 	};
 	void *ptr;
 	int off;
@@ -290,10 +295,10 @@ select_insn:
 	ALU(XOR,  ^)
 	ALU(MUL,  *)
 #undef ALU
-	ALU_NEG_0:
+	ALU_NEG:
 		A = (u32) -A;
 		CONT;
-	ALU64_NEG_0:
+	ALU64_NEG:
 		A = -A;
 		CONT;
 	ALU_MOV_X:
@@ -382,7 +387,7 @@ select_insn:
 		CONT;
 
 	/* CALL */
-	JMP_CALL_0:
+	JMP_CALL:
 		/* Function call scratches BPF_R1-BPF_R5 registers,
 		 * preserves BPF_R6-BPF_R9, and stores return value
 		 * into BPF_R0.
@@ -392,7 +397,7 @@ select_insn:
 		CONT;
 
 	/* JMP */
-	JMP_JA_0:
+	JMP_JA:
 		insn += insn->off;
 		CONT;
 	JMP_JEQ_X:
@@ -479,7 +484,7 @@ select_insn:
 			CONT_JMP;
 		}
 		CONT;
-	JMP_EXIT_0:
+	JMP_EXIT:
 		return BPF_R0;
 
 	/* STX and ST and LDX*/
-- 
1.7.11.7
