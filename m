From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 6/6] bnx2x: Cosmetic changes
Date: Wed, 27 Mar 2013 13:05:19 +0200
Message-ID: <1364382319-24952-7-git-send-email-yuvalmin@broadcom.com>
References: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3745 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754230Ab3C0MKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:41 -0400
In-Reply-To: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Make few alignments, comment fixes and debug messages.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b1b034d..6cc6c63 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3738,7 +3738,7 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	if (((vars->line_speed == SPEED_AUTO_NEG) &&
 	     (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
 	    (vars->line_speed == SPEED_1000)) {
-		u32 addr = MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2;
+		u16 addr = MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2;
 		an_adv |= (1<<5);
 
 		/* Enable CL37 1G Parallel Detect */
@@ -4761,8 +4761,8 @@ void bnx2x_link_status_update(struct link_params *params,
 					    port_mb[port].link_status));
 
 	/* Force link UP in non LOOPBACK_EXT loopback mode(s) */
-	if (bp->link_params.loopback_mode != LOOPBACK_NONE &&
-	    bp->link_params.loopback_mode != LOOPBACK_EXT)
+	if (params->loopback_mode != LOOPBACK_NONE &&
+	    params->loopback_mode != LOOPBACK_EXT)
 		vars->link_status |= LINK_STATUS_LINK_UP;
 
 	if (bnx2x_eee_has_cap(params))
@@ -9571,8 +9571,7 @@ static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
 	} else {
 		/* For 32-bit registers in 848xx, access via MDIO2ARM i/f. */
 		/* (1) set reg 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-		for (i = 0; i < ARRAY_SIZE(reg_set);
-		      i++)
+		for (i = 0; i < ARRAY_SIZE(reg_set); i++)
 			bnx2x_cl45_write(bp, phy, reg_set[i].devad,
 					 reg_set[i].reg, reg_set[i].val);
 
@@ -12286,7 +12285,7 @@ static void bnx2x_init_bmac_loopback(struct link_params *params,
 
 		bnx2x_xgxs_deassert(params);
 
-		/* set bmac loopback */
+		/* Set bmac loopback */
 		bnx2x_bmac_enable(params, vars, 1, 1);
 
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
@@ -12305,7 +12304,7 @@ static void bnx2x_init_emac_loopback(struct link_params *params,
 		vars->phy_flags = PHY_XGXS_FLAG;
 
 		bnx2x_xgxs_deassert(params);
-		/* set bmac loopback */
+		/* Set bmac loopback */
 		bnx2x_emac_enable(params, vars, 1);
 		bnx2x_emac_program(params, vars);
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
@@ -12565,6 +12564,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		   params->req_line_speed[0], params->req_flow_ctrl[0]);
 	DP(NETIF_MSG_LINK, "(2) req_speed %d, req_flowctrl %d\n",
 		   params->req_line_speed[1], params->req_flow_ctrl[1]);
+	DP(NETIF_MSG_LINK, "req_adv_flow_ctrl 0x%x\n", params->req_fc_auto_adv);
 	vars->link_status = 0;
 	vars->phy_link_up = 0;
 	vars->link_up = 0;
@@ -13490,8 +13490,8 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 	}
 
 	/* Once KR2 was disabled, wait 5 seconds before checking KR2 recovery
-	 * since some switches tend to reinit the AN process and clear the
-	 * advertised BP/NP after ~2 seconds causing the KR2 to be disabled
+	 * Since some switches tend to reinit the AN process and clear the
+	 * the advertised BP/NP after ~2 seconds causing the KR2 to be disabled
 	 * and recovered many times
 	 */
 	if (vars->check_kr2_recovery_cnt > 0) {
@@ -13509,8 +13509,10 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 
 	/* CL73 has not begun yet */
 	if (base_page == 0) {
-		if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE))
+		if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE)) {
 			bnx2x_kr2_recovery(params, vars, phy);
+			DP(NETIF_MSG_LINK, "No BP\n");
+		}
 		return;
 	}
 
@@ -13526,7 +13528,7 @@ static void bnx2x_check_kr2_wa(struct link_params *params,
 	if (!(vars->link_attr_sync & LINK_ATTR_SYNC_KR2_ENABLE)) {
 		if (!not_kr2_device) {
 			DP(NETIF_MSG_LINK, "BP=0x%x, NP=0x%x\n", base_page,
-				       next_page);
+			   next_page);
 			bnx2x_kr2_recovery(params, vars, phy);
 		}
 		return;
-- 
1.8.1.227.g44fe835
