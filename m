From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 2/6] bnx2x: fix loopback for non 10G link
Date: Sun, 24 Jul 2011 16:53:21 +0300
Message-ID: <1311515601.23243.4.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "eilon Greenstein" <eilong@broadcom.com>, "; yanivr"@broadcom.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1790 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592Ab1GXOKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2011 10:10:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Also fixes minor formatting in that function.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index e1ec1a3..48490da 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2151,10 +2151,12 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 		u8 rc;
 		int cfx_idx = bnx2x_get_link_cfg_idx(bp);
 		u16 req_line_speed = bp->link_params.req_line_speed[cfx_idx];
-		/* Initialize link parameters structure variables */
-		/* It is recommended to turn off RX FC for jumbo frames
-		   for better performance */
-		if ((CHIP_IS_E1x(bp)) && (bp->dev->mtu > 5000))
+		/*
+		 * Initialize link parameters structure variables
+		 * It is recommended to turn off RX FC for jumbo frames
+		 * for better performance
+		 */
+		if (CHIP_IS_E1x(bp) && (bp->dev->mtu > 5000))
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_TX;
 		else
 			bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_BOTH;
@@ -2162,8 +2164,18 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 		bnx2x_acquire_phy_lock(bp);
 
 		if (load_mode == LOAD_DIAG) {
-			bp->link_params.loopback_mode = LOOPBACK_XGXS;
-			bp->link_params.req_line_speed[cfx_idx] = SPEED_10000;
+			struct link_params *lp = &bp->link_params;
+			lp->loopback_mode = LOOPBACK_XGXS;
+			/* do PHY loopback at 10G speed, if possible */
+			if (lp->req_line_speed[cfx_idx] < SPEED_10000) {
+				if (lp->speed_cap_mask[cfx_idx] &
+				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+					lp->req_line_speed[cfx_idx] =
+					SPEED_10000;
+				else
+					lp->req_line_speed[cfx_idx] =
+					SPEED_1000;
+			}
 		}
 
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
-- 
1.7.2.2




