From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 04/10] bnx2x: Function Level Reset Final
 Cleanup
Date: Thu, 26 Jan 2012 18:01:48 +0200
Message-ID: <1327593714-18358-5-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1901 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752817Ab2AZQB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:58 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Fix bug where return value is ignored
2. Improve printouts
3. Fix typos

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   28 ++++++++++++---------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 115d77a..9a1c450 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1017,8 +1017,8 @@ void bnx2x_panic_dump(struct bnx2x *bp)
  * initialization.
  */
 #define FLR_WAIT_USEC		10000	/* 10 miliseconds */
-#define FLR_WAIT_INTERAVAL	50	/* usec */
-#define	FLR_POLL_CNT		(FLR_WAIT_USEC/FLR_WAIT_INTERAVAL) /* 200 */
+#define FLR_WAIT_INTERVAL	50	/* usec */
+#define	FLR_POLL_CNT		(FLR_WAIT_USEC/FLR_WAIT_INTERVAL) /* 200 */
 
 struct pbf_pN_buf_regs {
 	int pN;
@@ -1051,7 +1051,7 @@ static void bnx2x_pbf_pN_buf_flushed(struct bnx2x *bp,
 	while ((crd != init_crd) && ((u32)SUB_S32(crd_freed, crd_freed_start) <
 	       (init_crd - crd_start))) {
 		if (cur_cnt--) {
-			udelay(FLR_WAIT_INTERAVAL);
+			udelay(FLR_WAIT_INTERVAL);
 			crd = REG_RD(bp, regs->crd);
 			crd_freed = REG_RD(bp, regs->crd_freed);
 		} else {
@@ -1065,7 +1065,7 @@ static void bnx2x_pbf_pN_buf_flushed(struct bnx2x *bp,
 		}
 	}
 	DP(BNX2X_MSG_SP, "Waited %d*%d usec for PBF tx buffer[%d]\n",
-	   poll_count-cur_cnt, FLR_WAIT_INTERAVAL, regs->pN);
+	   poll_count-cur_cnt, FLR_WAIT_INTERVAL, regs->pN);
 }
 
 static void bnx2x_pbf_pN_cmd_flushed(struct bnx2x *bp,
@@ -1083,7 +1083,7 @@ static void bnx2x_pbf_pN_cmd_flushed(struct bnx2x *bp,
 
 	while (occup && ((u32)SUB_S32(freed, freed_start) < to_free)) {
 		if (cur_cnt--) {
-			udelay(FLR_WAIT_INTERAVAL);
+			udelay(FLR_WAIT_INTERVAL);
 			occup = REG_RD(bp, regs->lines_occup);
 			freed = REG_RD(bp, regs->lines_freed);
 		} else {
@@ -1097,7 +1097,7 @@ static void bnx2x_pbf_pN_cmd_flushed(struct bnx2x *bp,
 		}
 	}
 	DP(BNX2X_MSG_SP, "Waited %d*%d usec for PBF cmd queue[%d]\n",
-	   poll_count-cur_cnt, FLR_WAIT_INTERAVAL, regs->pN);
+	   poll_count-cur_cnt, FLR_WAIT_INTERVAL, regs->pN);
 }
 
 static inline u32 bnx2x_flr_clnup_reg_poll(struct bnx2x *bp, u32 reg,
@@ -1107,7 +1107,7 @@ static inline u32 bnx2x_flr_clnup_reg_poll(struct bnx2x *bp, u32 reg,
 	u32 val;
 
 	while ((val = REG_RD(bp, reg)) != expected && cur_cnt--)
-		udelay(FLR_WAIT_INTERAVAL);
+		udelay(FLR_WAIT_INTERVAL);
 
 	return val;
 }
@@ -1220,7 +1220,7 @@ static inline int bnx2x_send_final_clnup(struct bnx2x *bp, u8 clnup_func,
 	int ret = 0;
 
 	if (REG_RD(bp, comp_addr)) {
-		BNX2X_ERR("Cleanup complete is not 0\n");
+		BNX2X_ERR("Cleanup complete was not 0 before sending\n");
 		return 1;
 	}
 
@@ -1229,7 +1229,7 @@ static inline int bnx2x_send_final_clnup(struct bnx2x *bp, u8 clnup_func,
 	op_gen.command |= OP_GEN_AGG_VECT(clnup_func);
 	op_gen.command |= 1 << SDM_OP_GEN_AGG_VECT_IDX_VALID_SHIFT;
 
-	DP(BNX2X_MSG_SP, "FW Final cleanup\n");
+	DP(BNX2X_MSG_SP, "sending FW Final cleanup\n");
 	REG_WR(bp, XSDM_REG_OPERATION_GEN, op_gen.command);
 
 	if (bnx2x_flr_clnup_reg_poll(bp, comp_addr, 1, poll_cnt) != 1) {
@@ -1344,6 +1344,7 @@ static int bnx2x_pf_flr_clnup(struct bnx2x *bp)
 	REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
 
 	/* Poll HW usage counters */
+	DP(BNX2X_MSG_SP, "Polling usage counters\n");
 	if (bnx2x_poll_hw_usage_counters(bp, poll_cnt))
 		return -EBUSY;
 
@@ -6697,13 +6698,16 @@ static int bnx2x_init_hw_func(struct bnx2x *bp)
 	u16 cdu_ilt_start;
 	u32 addr, val;
 	u32 main_mem_base, main_mem_size, main_mem_prty_clr;
-	int i, main_mem_width;
+	int i, main_mem_width, rc;
 
 	DP(BNX2X_MSG_MCP, "starting func init  func %d\n", func);
 
 	/* FLR cleanup - hmmm */
-	if (!CHIP_IS_E1x(bp))
-		bnx2x_pf_flr_clnup(bp);
+	if (!CHIP_IS_E1x(bp)) {
+		rc = bnx2x_pf_flr_clnup(bp);
+		if (rc)
+			return rc;
+	}
 
 	/* set MSI reconfigure capability */
 	if (bp->common.int_block == INT_BLOCK_HC) {
-- 
1.7.1
