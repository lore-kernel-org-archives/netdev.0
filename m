From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 1/3] bnx2x: fix hw attention handling
Date: Thu, 22 Sep 2011 15:33:31 +0300
Message-ID: <1316694813-25274-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2897 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750978Ab1IVMda (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 08:33:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use register name to initialize attention mask

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    6 ++++--
 drivers/net/bnx2x/bnx2x_reg.h  |   12 ++++++++++++
 2 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index c027e93..6b46917 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4943,7 +4943,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp)
 	int igu_seg_id;
 	int port = BP_PORT(bp);
 	int func = BP_FUNC(bp);
-	int reg_offset;
+	int reg_offset, reg_offset_en5;
 	u64 section;
 	int index;
 	struct hc_sp_status_block_data sp_sb_data;
@@ -4966,6 +4966,8 @@ static void bnx2x_init_def_sb(struct bnx2x *bp)
 
 	reg_offset = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 			     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
+	reg_offset_en5 = (port ? MISC_REG_AEU_ENABLE5_FUNC_1_OUT_0 :
+				 MISC_REG_AEU_ENABLE5_FUNC_0_OUT_0);
 	for (index = 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		int sindex;
 		/* take care of sig[0]..sig[4] */
@@ -4980,7 +4982,7 @@ static void bnx2x_init_def_sb(struct bnx2x *bp)
 			 * and not 16 between the different groups
 			 */
 			bp->attn_group[index].sig[4] = REG_RD(bp,
-					reg_offset + 0x10 + 0x4*index);
+					reg_offset_en5 + 0x4*index);
 		else
 			bp->attn_group[index].sig[4] = 0;
 	}
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 750e844..fc7bd0f 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -1384,6 +1384,18 @@
    Latched ump_tx_parity; [31] MCP Latched scpad_parity; */
 #define MISC_REG_AEU_ENABLE4_PXP_0				 0xa108
 #define MISC_REG_AEU_ENABLE4_PXP_1				 0xa1a8
+/* [RW 32] fifth 32b for enabling the output for function 0 output0. Mapped
+ * as follows: [0] PGLUE config_space; [1] PGLUE misc_flr; [2] PGLUE B RBC
+ * attention [3] PGLUE B RBC parity; [4] ATC attention; [5] ATC parity; [6]
+ * mstat0 attention; [7] mstat0 parity; [8] mstat1 attention; [9] mstat1
+ * parity; [31-10] Reserved; */
+#define MISC_REG_AEU_ENABLE5_FUNC_0_OUT_0			 0xa688
+/* [RW 32] Fifth 32b for enabling the output for function 1 output0. Mapped
+ * as follows: [0] PGLUE config_space; [1] PGLUE misc_flr; [2] PGLUE B RBC
+ * attention [3] PGLUE B RBC parity; [4] ATC attention; [5] ATC parity; [6]
+ * mstat0 attention; [7] mstat0 parity; [8] mstat1 attention; [9] mstat1
+ * parity; [31-10] Reserved; */
+#define MISC_REG_AEU_ENABLE5_FUNC_1_OUT_0			 0xa6b0
 /* [RW 1] set/clr general attention 0; this will set/clr bit 94 in the aeu
    128 bit vector */
 #define MISC_REG_AEU_GENERAL_ATTN_0				 0xa000
-- 
1.7.2.2
