From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 1/2] bnx2: Fix register printouts during
 NETEV_WATCHDOG.
Date: Mon, 10 May 2010 16:18:58 -0700
Message-ID: <1273533539-8646-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1175 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757251Ab0EKAOr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 20:14:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <waie@broadcom.com>

Dump the correct MCP registers and add EMAC_RX_STATUS register during
NETDEV_WATCHDOG for debugging.

Signed-off-by: Eddie Wai <waie@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   15 ++++++++++++---
 drivers/net/bnx2.h |    2 ++
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 667f419..c281218 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6301,14 +6301,23 @@ static void
 bnx2_dump_state(struct bnx2 *bp)
 {
 	struct net_device *dev = bp->dev;
+	u32 mcp_p0, mcp_p1;
 
 	netdev_err(dev, "DEBUG: intr_sem[%x]\n", atomic_read(&bp->intr_sem));
-	netdev_err(dev, "DEBUG: EMAC_TX_STATUS[%08x] RPM_MGMT_PKT_CTRL[%08x]\n",
+	netdev_err(dev, "DEBUG: EMAC_TX_STATUS[%08x] EMAC_RX_STATUS[%08x]\n",
 		   REG_RD(bp, BNX2_EMAC_TX_STATUS),
+		   REG_RD(bp, BNX2_EMAC_RX_STATUS));
+	netdev_err(dev, "DEBUG: RPM_MGMT_PKT_CTRL[%08x]\n",
 		   REG_RD(bp, BNX2_RPM_MGMT_PKT_CTRL));
+	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
+		mcp_p0 = BNX2_MCP_STATE_P0;
+		mcp_p1 = BNX2_MCP_STATE_P1;
+	} else {
+		mcp_p0 = BNX2_MCP_STATE_P0_5708;
+		mcp_p1 = BNX2_MCP_STATE_P1_5708;
+	}
 	netdev_err(dev, "DEBUG: MCP_STATE_P0[%08x] MCP_STATE_P1[%08x]\n",
-		   bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P0),
-		   bnx2_reg_rd_ind(bp, BNX2_MCP_STATE_P1));
+		   bnx2_reg_rd_ind(bp, mcp_p0), bnx2_reg_rd_ind(bp, mcp_p1));
 	netdev_err(dev, "DEBUG: HC_STATS_INTERRUPT_STATUS[%08x]\n",
 		   REG_RD(bp, BNX2_HC_STATS_INTERRUPT_STATUS));
 	if (bp->flags & BNX2_FLAG_USING_MSIX)
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index dd35bd0..ddaa3fc 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6347,6 +6347,8 @@ struct l2_fhdr {
 #define BNX2_MCP_SCRATCH				0x00160000
 #define BNX2_MCP_STATE_P1				 0x0016f9c8
 #define BNX2_MCP_STATE_P0				 0x0016fdc8
+#define BNX2_MCP_STATE_P1_5708				 0x001699c8
+#define BNX2_MCP_STATE_P0_5708				 0x00169dc8
 
 #define BNX2_SHM_HDR_SIGNATURE				BNX2_MCP_SCRATCH
 #define BNX2_SHM_HDR_SIGNATURE_SIG_MASK			 0xffff0000
-- 
1.6.4.GIT


