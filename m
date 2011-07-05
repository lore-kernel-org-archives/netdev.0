From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 2/8] bnx2x: Change BCM54616S to BCM54618SE
Date: Tue, 5 Jul 2011 14:06:34 +0300
Message-ID: <1309863994.4050.81.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1690 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755879Ab1GELGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:06:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change 1G copper PHY BCM54616S to BCM54618SE since we only have HW with latter one of the two.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    4 +-
 drivers/net/bnx2x/bnx2x_link.c |   78 ++++++++++++++++++++++++++--------------
 drivers/net/bnx2x/bnx2x_reg.h  |   10 +++++-
 3 files changed, 62 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index d6a7aa9..e6f816d 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -696,7 +696,7 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84823      0x00000b00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54640      0x00000c00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84833      0x00000d00
-		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54616      0x00000e00
+		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54618SE    0x00000e00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8722       0x00000f00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_FAILURE       0x0000fd00
 		#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_NOT_CONN      0x0000ff00
@@ -751,7 +751,7 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823       0x00000b00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54640       0x00000c00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833       0x00000d00
-		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616       0x00000e00
+		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE     0x00000e00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8722        0x00000f00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT_WC      0x0000fc00
 		#define PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE        0x0000fd00
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 57ba811..011548a 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -3530,7 +3530,7 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 		vars->flow_ctrl = params->req_fc_auto_adv;
 	else if (vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
 		ret = 1;
-		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616) {
+		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE) {
 			bnx2x_cl22_read(bp, phy,
 					0x4, &ld_pause);
 			bnx2x_cl22_read(bp, phy,
@@ -5549,7 +5549,7 @@ static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
 	u16 cnt, ctrl;
 	/* Wait for soft reset to get cleared up to 1 sec */
 	for (cnt = 0; cnt < 1000; cnt++) {
-		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616)
+		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE)
 			bnx2x_cl22_read(bp, phy,
 				MDIO_PMA_REG_CTRL, &ctrl);
 		else
@@ -9800,9 +9800,9 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 }
 
 /******************************************************************/
-/*			54616S PHY SECTION			  */
+/*			54618SE PHY SECTION			  */
 /******************************************************************/
-static int bnx2x_54616s_config_init(struct bnx2x_phy *phy,
+static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 					       struct link_params *params,
 					       struct link_vars *vars)
 {
@@ -9811,7 +9811,7 @@ static int bnx2x_54616s_config_init(struct bnx2x_phy *phy,
 	u16 autoneg_val, an_1000_val, an_10_100_val, fc_val, temp;
 	u32 cfg_pin;
 
-	DP(NETIF_MSG_LINK, "54616S cfg init\n");
+	DP(NETIF_MSG_LINK, "54618SE cfg init\n");
 	usleep_range(1000, 1000);
 
 	/* This works with E3 only, no need to check the chip
@@ -9973,11 +9973,11 @@ static int bnx2x_54616s_config_init(struct bnx2x_phy *phy,
 	return 0;
 }
 
-static void bnx2x_54616s_set_link_led(struct bnx2x_phy *phy,
-				      struct link_params *params, u8 mode)
+static void bnx2x_54618se_set_link_led(struct bnx2x_phy *phy,
+				       struct link_params *params, u8 mode)
 {
 	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "54616S set link led (mode=%x)\n", mode);
+	DP(NETIF_MSG_LINK, "54618SE set link led (mode=%x)\n", mode);
 	switch (mode) {
 	case LED_MODE_FRONT_PANEL_OFF:
 	case LED_MODE_OFF:
@@ -9989,8 +9989,8 @@ static void bnx2x_54616s_set_link_led(struct bnx2x_phy *phy,
 	return;
 }
 
-static void bnx2x_54616s_link_reset(struct bnx2x_phy *phy,
-				    struct link_params *params)
+static void bnx2x_54618se_link_reset(struct bnx2x_phy *phy,
+				     struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u32 cfg_pin;
@@ -10009,9 +10009,9 @@ static void bnx2x_54616s_link_reset(struct bnx2x_phy *phy,
 	bnx2x_set_cfg_pin(bp, cfg_pin, 0);
 }
 
-static u8 bnx2x_54616s_read_status(struct bnx2x_phy *phy,
-				   struct link_params *params,
-				   struct link_vars *vars)
+static u8 bnx2x_54618se_read_status(struct bnx2x_phy *phy,
+				    struct link_params *params,
+				    struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val;
@@ -10022,7 +10022,7 @@ static u8 bnx2x_54616s_read_status(struct bnx2x_phy *phy,
 	bnx2x_cl22_read(bp, phy,
 			0x19,
 			&legacy_status);
-	DP(NETIF_MSG_LINK, "54616S read_status: 0x%x\n", legacy_status);
+	DP(NETIF_MSG_LINK, "54618SE read_status: 0x%x\n", legacy_status);
 
 	/* Read status to clear the PHY interrupt. */
 	bnx2x_cl22_read(bp, phy,
@@ -10074,21 +10074,45 @@ static u8 bnx2x_54616s_read_status(struct bnx2x_phy *phy,
 			vars->link_status |=
 				LINK_STATUS_PARALLEL_DETECTION_USED;
 
-		DP(NETIF_MSG_LINK, "BCM54616S: link speed is %d\n",
+		DP(NETIF_MSG_LINK, "BCM54618SE: link speed is %d\n",
 			   vars->line_speed);
+
+		/* Report whether EEE is resolved. */
+		bnx2x_cl22_read(bp, phy, MDIO_REG_GPHY_PHYID_LSB, &val);
+		if (val == MDIO_REG_GPHY_ID_54618SE) {
+			if (vars->link_status &
+			    LINK_STATUS_AUTO_NEGOTIATE_COMPLETE)
+				val = 0;
+			else {
+				bnx2x_cl22_write(bp, phy,
+					MDIO_REG_GPHY_CL45_ADDR_REG,
+					MDIO_AN_DEVAD);
+				bnx2x_cl22_write(bp, phy,
+					MDIO_REG_GPHY_CL45_DATA_REG,
+					MDIO_REG_GPHY_EEE_RESOLVED);
+				bnx2x_cl22_write(bp, phy,
+					MDIO_REG_GPHY_CL45_ADDR_REG,
+					(0x1 << 14) | MDIO_AN_DEVAD);
+				bnx2x_cl22_read(bp, phy,
+					MDIO_REG_GPHY_CL45_DATA_REG,
+					&val);
+			}
+			DP(NETIF_MSG_LINK, "EEE resolution: 0x%x\n", val);
+		}
+
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
 	}
 	return link_up;
 }
 
-static void bnx2x_54616s_config_loopback(struct bnx2x_phy *phy,
-				       struct link_params *params)
+static void bnx2x_54618se_config_loopback(struct bnx2x_phy *phy,
+					  struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val;
 	u32 umac_base = params->port ? GRCBASE_UMAC1 : GRCBASE_UMAC0;
 
-	DP(NETIF_MSG_LINK, "2PMA/PMD ext_phy_loopback: 54616s\n");
+	DP(NETIF_MSG_LINK, "2PMA/PMD ext_phy_loopback: 54618se\n");
 
 	/* Enable master/slave manual mmode and set to master */
 	/* mii write 9 [bits set 11 12] */
@@ -10705,8 +10729,8 @@ static struct bnx2x_phy phy_84833 = {
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
-static struct bnx2x_phy phy_54616s = {
-	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616,
+static struct bnx2x_phy phy_54618se = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
 	.flags		= FLAGS_INIT_XGXS_FIRST,
@@ -10729,13 +10753,13 @@ static struct bnx2x_phy phy_54616s = {
 	.speed_cap_mask	= 0,
 	/* req_duplex = */0,
 	/* rsrv = */0,
-	.config_init	= (config_init_t)bnx2x_54616s_config_init,
-	.read_status	= (read_status_t)bnx2x_54616s_read_status,
-	.link_reset	= (link_reset_t)bnx2x_54616s_link_reset,
-	.config_loopback = (config_loopback_t)bnx2x_54616s_config_loopback,
+	.config_init	= (config_init_t)bnx2x_54618se_config_init,
+	.read_status	= (read_status_t)bnx2x_54618se_read_status,
+	.link_reset	= (link_reset_t)bnx2x_54618se_link_reset,
+	.config_loopback = (config_loopback_t)bnx2x_54618se_config_loopback,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)bnx2x_54616s_set_link_led,
+	.set_link_led	= (set_link_led_t)bnx2x_54618se_set_link_led,
 	.phy_specific_func = (phy_specific_func_t)NULL
 };
 /*****************************************************************/
@@ -10978,8 +11002,8 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
 		*phy = phy_84833;
 		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54616:
-		*phy = phy_54616s;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM54618SE:
+		*phy = phy_54618se;
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		*phy = phy_7101;
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 064b445..1684e1b 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6919,7 +6919,15 @@ Theotherbitsarereservedandshouldbezero*/
 
 #define DIGITAL5_ACTUAL_SPEED_TX_MASK			0x003f
 
-/* 54616s */
+/* 54618se */
+#define MDIO_REG_GPHY_PHYID_LSB				0x3
+#define MDIO_REG_GPHY_ID_54618SE		0x5cd5
+#define MDIO_REG_GPHY_CL45_ADDR_REG			0xd
+#define MDIO_REG_GPHY_CL45_DATA_REG			0xe
+#define MDIO_REG_GPHY_EEE_ADV			0x3c
+#define MDIO_REG_GPHY_EEE_1G		(0x1 << 2)
+#define MDIO_REG_GPHY_EEE_100		(0x1 << 1)
+#define MDIO_REG_GPHY_EEE_RESOLVED		0x803e
 #define MDIO_REG_INTR_STATUS				0x1a
 #define MDIO_REG_INTR_MASK				0x1b
 #define MDIO_REG_INTR_MASK_LINK_STATUS			(0x1 << 1)
-- 
1.7.1







