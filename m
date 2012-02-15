From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 05/11] bnx2x: force 10G on 84833 phy should be
 autoneg with only 10G advertised
Date: Wed, 15 Feb 2012 07:10:26 -0500
Message-ID: <1329307832-32454-6-git-send-email-yuvalmin@broadcom.com>
References: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Mintz Yuval" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4937 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751870Ab2BOFQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 00:16:15 -0500
In-Reply-To: <1329307832-32454-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mintz Yuval <yuvalmin@broadcom.com>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    9 +--------
 1 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index acc9649..57fe056 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9492,13 +9492,8 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u16 autoneg_val, an_1000_val, an_10_100_val, an_10g_val;
-	u16 tmp_req_line_speed;
 
-	tmp_req_line_speed = phy->req_line_speed;
-	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
-		if (phy->req_line_speed == SPEED_10000)
-			phy->req_line_speed = SPEED_AUTO_NEG;
-	} else {
+	if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
 		/* Save spirom version */
 		bnx2x_save_848xx_spirom_version(phy, bp, params->port);
 	}
@@ -9642,8 +9637,6 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				 MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
 				 1);
 
-	phy->req_line_speed = tmp_req_line_speed;
-
 	return 0;
 }
 
-- 
1.7.9.rc2
