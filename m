From: Colin King <colin.king@canonical.com>
Subject: [PATCH] bnx2x: fix spelling mistake in macros HW_INTERRUT_ASSERT_SET_*
Date: Mon,  3 Apr 2017 11:19:10 +0100
Message-ID: <20170403101910.27480-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trival fix, rename HW_INTERRUT_ASSERT_SET_* to HW_INTERRUPT_ASSERT_SET_*

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  6 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 18 +++++++++---------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 0a23034bbe3f..352beff796ae 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2277,7 +2277,7 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RBCP) | \
 				 GENERAL_ATTEN_OFFSET(LATCHED_ATTN_RSVD_GRC))
 
-#define HW_INTERRUT_ASSERT_SET_0 \
+#define HW_INTERRUPT_ASSERT_SET_0 \
 				(AEU_INPUTS_ATTN_BITS_TSDM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TCM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TSEMI_HW_INTERRUPT | \
@@ -2290,7 +2290,7 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 				 AEU_INPUTS_ATTN_BITS_TSEMI_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_TCM_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_ERROR)
-#define HW_INTERRUT_ASSERT_SET_1 \
+#define HW_INTERRUPT_ASSERT_SET_1 \
 				(AEU_INPUTS_ATTN_BITS_QM_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_TIMERS_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_XSDM_HW_INTERRUPT | \
@@ -2318,7 +2318,7 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 				 AEU_INPUTS_ATTN_BITS_UPB_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_CSDM_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_CCM_PARITY_ERROR)
-#define HW_INTERRUT_ASSERT_SET_2 \
+#define HW_INTERRUPT_ASSERT_SET_2 \
 				(AEU_INPUTS_ATTN_BITS_CSEMI_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_CDU_HW_INTERRUPT | \
 				 AEU_INPUTS_ATTN_BITS_DMAE_HW_INTERRUPT | \
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ac76fc251d26..b81aafc0f715 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4166,14 +4166,14 @@ static void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		bnx2x_release_phy_lock(bp);
 	}
 
-	if (attn & HW_INTERRUT_ASSERT_SET_0) {
+	if (attn & HW_INTERRUPT_ASSERT_SET_0) {
 
 		val = REG_RD(bp, reg_offset);
-		val &= ~(attn & HW_INTERRUT_ASSERT_SET_0);
+		val &= ~(attn & HW_INTERRUPT_ASSERT_SET_0);
 		REG_WR(bp, reg_offset, val);
 
 		BNX2X_ERR("FATAL HW block attention set0 0x%x\n",
-			  (u32)(attn & HW_INTERRUT_ASSERT_SET_0));
+			  (u32)(attn & HW_INTERRUPT_ASSERT_SET_0));
 		bnx2x_panic();
 	}
 }
@@ -4191,7 +4191,7 @@ static void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
 			BNX2X_ERR("FATAL error from DORQ\n");
 	}
 
-	if (attn & HW_INTERRUT_ASSERT_SET_1) {
+	if (attn & HW_INTERRUPT_ASSERT_SET_1) {
 
 		int port = BP_PORT(bp);
 		int reg_offset;
@@ -4200,11 +4200,11 @@ static void bnx2x_attn_int_deasserted1(struct bnx2x *bp, u32 attn)
 				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_1);
 
 		val = REG_RD(bp, reg_offset);
-		val &= ~(attn & HW_INTERRUT_ASSERT_SET_1);
+		val &= ~(attn & HW_INTERRUPT_ASSERT_SET_1);
 		REG_WR(bp, reg_offset, val);
 
 		BNX2X_ERR("FATAL HW block attention set1 0x%x\n",
-			  (u32)(attn & HW_INTERRUT_ASSERT_SET_1));
+			  (u32)(attn & HW_INTERRUPT_ASSERT_SET_1));
 		bnx2x_panic();
 	}
 }
@@ -4235,7 +4235,7 @@ static void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
 		}
 	}
 
-	if (attn & HW_INTERRUT_ASSERT_SET_2) {
+	if (attn & HW_INTERRUPT_ASSERT_SET_2) {
 
 		int port = BP_PORT(bp);
 		int reg_offset;
@@ -4244,11 +4244,11 @@ static void bnx2x_attn_int_deasserted2(struct bnx2x *bp, u32 attn)
 				     MISC_REG_AEU_ENABLE1_FUNC_0_OUT_2);
 
 		val = REG_RD(bp, reg_offset);
-		val &= ~(attn & HW_INTERRUT_ASSERT_SET_2);
+		val &= ~(attn & HW_INTERRUPT_ASSERT_SET_2);
 		REG_WR(bp, reg_offset, val);
 
 		BNX2X_ERR("FATAL HW block attention set2 0x%x\n",
-			  (u32)(attn & HW_INTERRUT_ASSERT_SET_2));
+			  (u32)(attn & HW_INTERRUPT_ASSERT_SET_2));
 		bnx2x_panic();
 	}
 }
-- 
2.11.0
