From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 5/8] bnx2x: Mark full duplex on some external
 PHYs
Date: Tue, 18 Jan 2011 16:33:42 +0200
Message-ID: <1295361222.5281.88.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3540 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab1AROdM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:33:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Device may show incorrect duplex mode for devices with external PHY

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 500258d..f5fd33e 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4408,6 +4408,7 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 		}
 		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
 		bnx2x_8073_resolve_fc(phy, params, vars);
+		vars->duplex = DUPLEX_FULL;
 	}
 	return link_up;
 }
@@ -5154,6 +5155,7 @@ static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
 		else
 			vars->line_speed = SPEED_10000;
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+		vars->duplex = DUPLEX_FULL;
 	}
 	return link_up;
 }
@@ -5850,8 +5852,11 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "port %x: External link is down\n",
 			   params->port);
 	}
-	if (link_up)
+	if (link_up) {
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+		vars->duplex = DUPLEX_FULL;
+		DP(NETIF_MSG_LINK, "duplex = 0x%x\n", vars->duplex);
+	}
 
 	if ((DUAL_MEDIA(params)) &&
 	    (phy->req_line_speed == SPEED_1000)) {
@@ -6218,6 +6223,7 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 	/* Check link 10G */
 	if (val2 & (1<<11)) {
 		vars->line_speed = SPEED_10000;
+		vars->duplex = DUPLEX_FULL;
 		link_up = 1;
 		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
 	} else { /* Check Legacy speed link */
@@ -6581,6 +6587,7 @@ static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
 				MDIO_AN_DEVAD, MDIO_AN_REG_MASTER_STATUS,
 				&val2);
 		vars->line_speed = SPEED_10000;
+		vars->duplex = DUPLEX_FULL;
 		DP(NETIF_MSG_LINK, "SFX7101 AN status 0x%x->Master=%x\n",
 			   val2, (val2 & (1<<14)));
 		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
-- 
1.7.1








