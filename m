From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: reduce the lines of code
Date: Fri, 19 Nov 2010 10:04:44 +0800
Message-ID: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:37410 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab0KSCFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 21:05:24 -0500
Received: by yxf34 with SMTP id 34so2375708yxf.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 18:05:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use macros to reduce the regularity lines.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/core/filter.c     |   96 +++-----------------------------------------------
 net/core/filter_def.h |   55 ++++++++++++++++++++++++++++
 2 files changed, 61 insertions(+), 90 deletions(-)
diff --git a/net/core/filter.c b/net/core/filter.c
index 15a545d..2a8841d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -39,51 +39,9 @@
 #include <linux/filter.h>
 
 enum {
-	BPF_S_RET_K = 0,
-	BPF_S_RET_A,
-	BPF_S_ALU_ADD_K,
-	BPF_S_ALU_ADD_X,
-	BPF_S_ALU_SUB_K,
-	BPF_S_ALU_SUB_X,
-	BPF_S_ALU_MUL_K,
-	BPF_S_ALU_MUL_X,
-	BPF_S_ALU_DIV_X,
-	BPF_S_ALU_AND_K,
-	BPF_S_ALU_AND_X,
-	BPF_S_ALU_OR_K,
-	BPF_S_ALU_OR_X,
-	BPF_S_ALU_LSH_K,
-	BPF_S_ALU_LSH_X,
-	BPF_S_ALU_RSH_K,
-	BPF_S_ALU_RSH_X,
-	BPF_S_ALU_NEG,
-	BPF_S_LD_W_ABS,
-	BPF_S_LD_H_ABS,
-	BPF_S_LD_B_ABS,
-	BPF_S_LD_W_LEN,
-	BPF_S_LD_W_IND,
-	BPF_S_LD_H_IND,
-	BPF_S_LD_B_IND,
-	BPF_S_LD_IMM,
-	BPF_S_LDX_W_LEN,
-	BPF_S_LDX_B_MSH,
-	BPF_S_LDX_IMM,
-	BPF_S_MISC_TAX,
-	BPF_S_MISC_TXA,
-	BPF_S_ALU_DIV_K,
-	BPF_S_LD_MEM,
-	BPF_S_LDX_MEM,
-	BPF_S_ST,
-	BPF_S_STX,
-	BPF_S_JMP_JA,
-	BPF_S_JMP_JEQ_K,
-	BPF_S_JMP_JEQ_X,
-	BPF_S_JMP_JGE_K,
-	BPF_S_JMP_JGE_X,
-	BPF_S_JMP_JGT_K,
-	BPF_S_JMP_JGT_X,
-	BPF_S_JMP_JSET_K,
-	BPF_S_JMP_JSET_X,
+#define BPF_DEFINE(user, kernel) kernel
+#include "filter_def.h"
+#undef BPF_DEFINE
 };
 
 /* No hurry in this branch */
@@ -436,51 +394,9 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 	 * Invalid instructions are initialized to 0.
 	 */
 	static const u8 codes[] = {
-		[BPF_ALU|BPF_ADD|BPF_K]  = BPF_S_ALU_ADD_K + 1,
-		[BPF_ALU|BPF_ADD|BPF_X]  = BPF_S_ALU_ADD_X + 1,
-		[BPF_ALU|BPF_SUB|BPF_K]  = BPF_S_ALU_SUB_K + 1,
-		[BPF_ALU|BPF_SUB|BPF_X]  = BPF_S_ALU_SUB_X + 1,
-		[BPF_ALU|BPF_MUL|BPF_K]  = BPF_S_ALU_MUL_K + 1,
-		[BPF_ALU|BPF_MUL|BPF_X]  = BPF_S_ALU_MUL_X + 1,
-		[BPF_ALU|BPF_DIV|BPF_X]  = BPF_S_ALU_DIV_X + 1,
-		[BPF_ALU|BPF_AND|BPF_K]  = BPF_S_ALU_AND_K + 1,
-		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X + 1,
-		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K + 1,
-		[BPF_ALU|BPF_OR|BPF_X]   = BPF_S_ALU_OR_X + 1,
-		[BPF_ALU|BPF_LSH|BPF_K]  = BPF_S_ALU_LSH_K + 1,
-		[BPF_ALU|BPF_LSH|BPF_X]  = BPF_S_ALU_LSH_X + 1,
-		[BPF_ALU|BPF_RSH|BPF_K]  = BPF_S_ALU_RSH_K + 1,
-		[BPF_ALU|BPF_RSH|BPF_X]  = BPF_S_ALU_RSH_X + 1,
-		[BPF_ALU|BPF_NEG]        = BPF_S_ALU_NEG + 1,
-		[BPF_LD|BPF_W|BPF_ABS]   = BPF_S_LD_W_ABS + 1,
-		[BPF_LD|BPF_H|BPF_ABS]   = BPF_S_LD_H_ABS + 1,
-		[BPF_LD|BPF_B|BPF_ABS]   = BPF_S_LD_B_ABS + 1,
-		[BPF_LD|BPF_W|BPF_LEN]   = BPF_S_LD_W_LEN + 1,
-		[BPF_LD|BPF_W|BPF_IND]   = BPF_S_LD_W_IND + 1,
-		[BPF_LD|BPF_H|BPF_IND]   = BPF_S_LD_H_IND + 1,
-		[BPF_LD|BPF_B|BPF_IND]   = BPF_S_LD_B_IND + 1,
-		[BPF_LD|BPF_IMM]         = BPF_S_LD_IMM + 1,
-		[BPF_LDX|BPF_W|BPF_LEN]  = BPF_S_LDX_W_LEN + 1,
-		[BPF_LDX|BPF_B|BPF_MSH]  = BPF_S_LDX_B_MSH + 1,
-		[BPF_LDX|BPF_IMM]        = BPF_S_LDX_IMM + 1,
-		[BPF_MISC|BPF_TAX]       = BPF_S_MISC_TAX + 1,
-		[BPF_MISC|BPF_TXA]       = BPF_S_MISC_TXA + 1,
-		[BPF_RET|BPF_K]          = BPF_S_RET_K + 1,
-		[BPF_RET|BPF_A]          = BPF_S_RET_A + 1,
-		[BPF_ALU|BPF_DIV|BPF_K]  = BPF_S_ALU_DIV_K + 1,
-		[BPF_LD|BPF_MEM]         = BPF_S_LD_MEM + 1,
-		[BPF_LDX|BPF_MEM]        = BPF_S_LDX_MEM + 1,
-		[BPF_ST]                 = BPF_S_ST + 1,
-		[BPF_STX]                = BPF_S_STX + 1,
-		[BPF_JMP|BPF_JA]         = BPF_S_JMP_JA + 1,
-		[BPF_JMP|BPF_JEQ|BPF_K]  = BPF_S_JMP_JEQ_K + 1,
-		[BPF_JMP|BPF_JEQ|BPF_X]  = BPF_S_JMP_JEQ_X + 1,
-		[BPF_JMP|BPF_JGE|BPF_K]  = BPF_S_JMP_JGE_K + 1,
-		[BPF_JMP|BPF_JGE|BPF_X]  = BPF_S_JMP_JGE_X + 1,
-		[BPF_JMP|BPF_JGT|BPF_K]  = BPF_S_JMP_JGT_K + 1,
-		[BPF_JMP|BPF_JGT|BPF_X]  = BPF_S_JMP_JGT_X + 1,
-		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K + 1,
-		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X + 1,
+#define BPF_DEFINE(user, kernel) [user] = kernel + 1
+#include "filter_def.h"
+#undef BPF_DEFINE
 	};
 	int pc;
 
diff --git a/net/core/filter_def.h b/net/core/filter_def.h
new file mode 100644
index 0000000..51bd662
--- /dev/null
+++ b/net/core/filter_def.h
@@ -0,0 +1,55 @@
+#define BPF_A1(arg1) BPF_DEFINE(BPF_##arg1, BPF_S_##arg1)
+#define BPF_A2(arg1, arg2) \
+	BPF_DEFINE(BPF_##arg1|BPF_##arg2, BPF_S_##arg1##_##arg2)
+#define BPF_A3(arg1, arg2, arg3) \
+	BPF_DEFINE(BPF_##arg1|BPF_##arg2|BPF_##arg3, \
+		   BPF_S_##arg1##_##arg2##_##arg3)
+
+BPF_A2(RET, K),
+BPF_A2(RET, A),
+BPF_A3(ALU, ADD, K),
+BPF_A3(ALU, ADD, X),
+BPF_A3(ALU, SUB, K),
+BPF_A3(ALU, SUB, X),
+BPF_A3(ALU, MUL, K),
+BPF_A3(ALU, MUL, X),
+BPF_A3(ALU, DIV, X),
+BPF_A3(ALU, AND, K),
+BPF_A3(ALU, AND, X),
+BPF_A3(ALU, OR, K),
+BPF_A3(ALU, OR, X),
+BPF_A3(ALU, LSH, K),
+BPF_A3(ALU, LSH, X),
+BPF_A3(ALU, RSH, K),
+BPF_A3(ALU, RSH, X),
+BPF_A2(ALU, NEG),
+BPF_A3(LD, W, ABS),
+BPF_A3(LD, H, ABS),
+BPF_A3(LD, B, ABS),
+BPF_A3(LD, W, LEN),
+BPF_A3(LD, W, IND),
+BPF_A3(LD, H, IND),
+BPF_A3(LD, B, IND),
+BPF_A2(LD, IMM),
+BPF_A3(LDX, W, LEN),
+BPF_A3(LDX, B, MSH),
+BPF_A2(LDX, IMM),
+BPF_A2(MISC, TAX),
+BPF_A2(MISC, TXA),
+BPF_A3(ALU, DIV, K),
+BPF_A2(LD, MEM),
+BPF_A2(LDX, MEM),
+BPF_A1(ST),
+BPF_A1(STX),
+BPF_A2(JMP, JA),
+BPF_A3(JMP, JEQ, K),
+BPF_A3(JMP, JEQ, X),
+BPF_A3(JMP, JGE, K),
+BPF_A3(JMP, JGE, X),
+BPF_A3(JMP, JGT, K),
+BPF_A3(JMP, JGT, X),
+BPF_A3(JMP, JSET, K),
+BPF_A3(JMP, JSET, X),
+#undef BPF_A1
+#undef BPF_A2
+#undef BPF_A3
