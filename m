From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 11/25] bnx2x: Delay in while loops
Date: Wed, 13 Aug 2008 17:14:12 +0300
Message-ID: <1218636853.547.87.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1375 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756288AbYHMOOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delay in while loops
The delay in the loop should be after the change. This has very little
effect (can save one delay) but it is the right thing to do

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   25 +++++++++++--------------
 1 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index b2886db..ea6fcf3 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -235,17 +235,16 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 	while (*wb_comp != DMAE_COMP_VAL) {
 		DP(BNX2X_MSG_OFF, "wb_comp 0x%08x\n", *wb_comp);
 
-		/* adjust delay for emulation/FPGA */
-		if (CHIP_REV_IS_SLOW(bp))
-			msleep(100);
-		else
-			udelay(5);
-
 		if (!cnt) {
 			BNX2X_ERR("dmae timeout!\n");
 			break;
 		}
 		cnt--;
+		/* adjust delay for emulation/FPGA */
+		if (CHIP_REV_IS_SLOW(bp))
+			msleep(100);
+		else
+			udelay(5);
 	}
 
 	mutex_unlock(&bp->dmae_mutex);
@@ -308,17 +307,16 @@ void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32)
 
 	while (*wb_comp != DMAE_COMP_VAL) {
 
-		/* adjust delay for emulation/FPGA */
-		if (CHIP_REV_IS_SLOW(bp))
-			msleep(100);
-		else
-			udelay(5);
-
 		if (!cnt) {
 			BNX2X_ERR("dmae timeout!\n");
 			break;
 		}
 		cnt--;
+		/* adjust delay for emulation/FPGA */
+		if (CHIP_REV_IS_SLOW(bp))
+			msleep(100);
+		else
+			udelay(5);
 	}
 	DP(BNX2X_MSG_OFF, "data [0x%08x 0x%08x 0x%08x 0x%08x]\n",
 	   bp->slowpath->wb_data[0], bp->slowpath->wb_data[1],
@@ -3094,12 +3092,12 @@ static int bnx2x_stats_comp(struct bnx2x *bp)
 
 	might_sleep();
 	while (*stats_comp != DMAE_COMP_VAL) {
-		msleep(1);
 		if (!cnt) {
 			BNX2X_ERR("timeout waiting for stats finished\n");
 			break;
 		}
 		cnt--;
+		msleep(1);
 	}
 	return 1;
 }
@@ -6483,7 +6481,6 @@ static int bnx2x_stop_leading(struct bnx2x *bp)
 	   so there is not much to do if this times out
 	 */
 	while (dsb_sp_prod_idx == *bp->dsb_sp_prod) {
-		msleep(1);
 		if (!cnt) {
 			DP(NETIF_MSG_IFDOWN, "timeout waiting for port del "
 			   "dsb_sp_prod 0x%x != dsb_sp_prod_idx 0x%x\n",
-- 
1.5.3.2




