From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 4/7] bnx2x: display the correct duplex value
Date: Tue, 11 Sep 2012 17:34:11 +0300
Message-ID: <1347374054-16730-5-git-send-email-yuvalmin@broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1391 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759330Ab2IKO6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:58:41 -0400
In-Reply-To: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Prior to this fix, the driver reported the chip's active duplex state
is always 'full', even if using half-duplex mode.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 40a7b8d..b046beb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -5434,7 +5434,7 @@ static int bnx2x_get_link_speed_duplex(struct bnx2x_phy *phy,
 		switch (speed_mask) {
 		case GP_STATUS_10M:
 			vars->line_speed = SPEED_10;
-			if (vars->duplex == DUPLEX_FULL)
+			if (is_duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_10TFD;
 			else
 				vars->link_status |= LINK_10THD;
@@ -5442,7 +5442,7 @@ static int bnx2x_get_link_speed_duplex(struct bnx2x_phy *phy,
 
 		case GP_STATUS_100M:
 			vars->line_speed = SPEED_100;
-			if (vars->duplex == DUPLEX_FULL)
+			if (is_duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_100TXFD;
 			else
 				vars->link_status |= LINK_100TXHD;
@@ -5451,7 +5451,7 @@ static int bnx2x_get_link_speed_duplex(struct bnx2x_phy *phy,
 		case GP_STATUS_1G:
 		case GP_STATUS_1G_KX:
 			vars->line_speed = SPEED_1000;
-			if (vars->duplex == DUPLEX_FULL)
+			if (is_duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_1000TFD;
 			else
 				vars->link_status |= LINK_1000THD;
@@ -5459,7 +5459,7 @@ static int bnx2x_get_link_speed_duplex(struct bnx2x_phy *phy,
 
 		case GP_STATUS_2_5G:
 			vars->line_speed = SPEED_2500;
-			if (vars->duplex == DUPLEX_FULL)
+			if (is_duplex == DUPLEX_FULL)
 				vars->link_status |= LINK_2500TFD;
 			else
 				vars->link_status |= LINK_2500THD;
@@ -5533,6 +5533,7 @@ static int bnx2x_link_settings_status(struct bnx2x_phy *phy,
 
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
 		if (SINGLE_MEDIA_DIRECT(params)) {
+			vars->duplex = duplex;
 			bnx2x_flow_ctrl_resolve(phy, params, vars, gp_status);
 			if (phy->req_line_speed == SPEED_AUTO_NEG)
 				bnx2x_xgxs_an_resolve(phy, params, vars,
@@ -5627,6 +5628,7 @@ static int bnx2x_warpcore_read_status(struct bnx2x_phy *phy,
 					LINK_STATUS_PARALLEL_DETECTION_USED;
 			}
 			bnx2x_ext_phy_resolve_fc(phy, params, vars);
+			vars->duplex = duplex;
 		}
 	}
 
-- 
1.7.9.rc2
