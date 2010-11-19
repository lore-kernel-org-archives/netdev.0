From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] filter: cleanup codes[] init
Date: Fri, 19 Nov 2010 08:56:38 +0100
Message-ID: <1290153398.29509.7.camel@edumazet-laptop>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
	 <b2c34db84e88366e465af590900ae3db@localhost>
	 <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
	 <1290153111.29509.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36725 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab0KSH4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 02:56:44 -0500
Received: by wyb28 with SMTP id 28so4154774wyb.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 23:56:43 -0800 (PST)
In-Reply-To: <1290153111.29509.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Starting the translated instruction to 1 instead of 0 allows us to
remove one descrement at check time and makes codes[] array init
cleaner.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/filter.c |   95 +++++++++++++++++++++-----------------------
 1 file changed, 47 insertions(+), 48 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 15a545d..a1edb5d 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -39,7 +39,7 @@
 #include <linux/filter.h>
 
 enum {
-	BPF_S_RET_K = 0,
+	BPF_S_RET_K = 1,
 	BPF_S_RET_A,
 	BPF_S_ALU_ADD_K,
 	BPF_S_ALU_ADD_X,
@@ -436,51 +436,51 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
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
+		[BPF_ALU|BPF_ADD|BPF_K]  = BPF_S_ALU_ADD_K,
+		[BPF_ALU|BPF_ADD|BPF_X]  = BPF_S_ALU_ADD_X,
+		[BPF_ALU|BPF_SUB|BPF_K]  = BPF_S_ALU_SUB_K,
+		[BPF_ALU|BPF_SUB|BPF_X]  = BPF_S_ALU_SUB_X,
+		[BPF_ALU|BPF_MUL|BPF_K]  = BPF_S_ALU_MUL_K,
+		[BPF_ALU|BPF_MUL|BPF_X]  = BPF_S_ALU_MUL_X,
+		[BPF_ALU|BPF_DIV|BPF_X]  = BPF_S_ALU_DIV_X,
+		[BPF_ALU|BPF_AND|BPF_K]  = BPF_S_ALU_AND_K,
+		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X,
+		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K,
+		[BPF_ALU|BPF_OR|BPF_X]   = BPF_S_ALU_OR_X,
+		[BPF_ALU|BPF_LSH|BPF_K]  = BPF_S_ALU_LSH_K,
+		[BPF_ALU|BPF_LSH|BPF_X]  = BPF_S_ALU_LSH_X,
+		[BPF_ALU|BPF_RSH|BPF_K]  = BPF_S_ALU_RSH_K,
+		[BPF_ALU|BPF_RSH|BPF_X]  = BPF_S_ALU_RSH_X,
+		[BPF_ALU|BPF_NEG]        = BPF_S_ALU_NEG,
+		[BPF_LD|BPF_W|BPF_ABS]   = BPF_S_LD_W_ABS,
+		[BPF_LD|BPF_H|BPF_ABS]   = BPF_S_LD_H_ABS,
+		[BPF_LD|BPF_B|BPF_ABS]   = BPF_S_LD_B_ABS,
+		[BPF_LD|BPF_W|BPF_LEN]   = BPF_S_LD_W_LEN,
+		[BPF_LD|BPF_W|BPF_IND]   = BPF_S_LD_W_IND,
+		[BPF_LD|BPF_H|BPF_IND]   = BPF_S_LD_H_IND,
+		[BPF_LD|BPF_B|BPF_IND]   = BPF_S_LD_B_IND,
+		[BPF_LD|BPF_IMM]         = BPF_S_LD_IMM,
+		[BPF_LDX|BPF_W|BPF_LEN]  = BPF_S_LDX_W_LEN,
+		[BPF_LDX|BPF_B|BPF_MSH]  = BPF_S_LDX_B_MSH,
+		[BPF_LDX|BPF_IMM]        = BPF_S_LDX_IMM,
+		[BPF_MISC|BPF_TAX]       = BPF_S_MISC_TAX,
+		[BPF_MISC|BPF_TXA]       = BPF_S_MISC_TXA,
+		[BPF_RET|BPF_K]          = BPF_S_RET_K,
+		[BPF_RET|BPF_A]          = BPF_S_RET_A,
+		[BPF_ALU|BPF_DIV|BPF_K]  = BPF_S_ALU_DIV_K,
+		[BPF_LD|BPF_MEM]         = BPF_S_LD_MEM,
+		[BPF_LDX|BPF_MEM]        = BPF_S_LDX_MEM,
+		[BPF_ST]                 = BPF_S_ST,
+		[BPF_STX]                = BPF_S_STX,
+		[BPF_JMP|BPF_JA]         = BPF_S_JMP_JA,
+		[BPF_JMP|BPF_JEQ|BPF_K]  = BPF_S_JMP_JEQ_K,
+		[BPF_JMP|BPF_JEQ|BPF_X]  = BPF_S_JMP_JEQ_X,
+		[BPF_JMP|BPF_JGE|BPF_K]  = BPF_S_JMP_JGE_K,
+		[BPF_JMP|BPF_JGE|BPF_X]  = BPF_S_JMP_JGE_X,
+		[BPF_JMP|BPF_JGT|BPF_K]  = BPF_S_JMP_JGT_K,
+		[BPF_JMP|BPF_JGT|BPF_X]  = BPF_S_JMP_JGT_X,
+		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
+		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
 	};
 	int pc;
 
@@ -495,8 +495,7 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
 		if (code >= ARRAY_SIZE(codes))
 			return -EINVAL;
 		code = codes[code];
-		/* Undo the '+ 1' in codes[] after validation. */
-		if (!code--)
+		if (!code)
 			return -EINVAL;
 		/* Some instructions need special checks */
 		switch (code) {


