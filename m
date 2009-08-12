From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 28/36] bnx2x: Re-arrange the link structures for
 better alignment
Date: Wed, 12 Aug 2009 21:23:59 +0300
Message-ID: <1250101439.27379.180.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yitchak Gertner" <gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4897 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754533AbZHLSZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change ieee_fc to u16 instead of u32 and re-arrange the link parameters
structures

Signed-off-by: Yitchak Gertner <gertner@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    6 +++---
 drivers/net/bnx2x_link.h |   31 +++++++++++++++++++------------
 2 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index c163c42..74f4d10 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1347,7 +1347,7 @@ static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
 			      MDIO_OVER_1G_UP3, 0x400);
 }
 
-static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u32 *ieee_fc)
+static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u16 *ieee_fc)
 {
 	*ieee_fc = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
 	/* resolve pause mode and advertisement
@@ -1381,7 +1381,7 @@ static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u32 *ieee_fc)
 }
 
 static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
-					   u32 ieee_fc)
+					   u16 ieee_fc)
 {
 	struct bnx2x *bp = params->bp;
 	/* for AN, we are always publishing full duplex */
@@ -1389,7 +1389,7 @@ static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, (u16)ieee_fc);
+			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, ieee_fc);
 }
 
 static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 6d26d6c..e0d7eef 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -81,6 +81,11 @@ struct link_params {
 #define SWITCH_CFG_AUTO_DETECT	PORT_FEATURE_CON_SWITCH_AUTO_DETECT
 
 	u16 hw_led_mode; /* part of the hw_config read from the shmem */
+
+	/* phy_addr populated by the phy_init function */
+	u8 phy_addr;
+	/*u8 reserved1;*/
+
 	u32 lane_config;
 	u32 ext_phy_config;
 #define XGXS_EXT_PHY_TYPE(ext_phy_config)	(ext_phy_config & \
@@ -90,39 +95,41 @@ struct link_params {
 	/* Phy register parameter */
 	u32 chip_id;
 
-	/* phy_addr populated by the CLC */
-	u8 phy_addr;
 	u16 xgxs_config_rx[4]; /* preemphasis values for the rx side */
-
 	u16 xgxs_config_tx[4]; /* preemphasis values for the tx side */
+
 	u32 feature_config_flags;
 #define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY	(1<<2)
 #define FEATURE_CONFIG_BCM8727_NOC			(1<<3)
+
 	/* Device pointer passed to all callback functions */
 	struct bnx2x *bp;
 };
 
 /* Output parameters */
 struct link_vars {
+	u8 phy_flags;
+
+	u8 mac_type;
+#define MAC_TYPE_NONE		0
+#define MAC_TYPE_EMAC		1
+#define MAC_TYPE_BMAC		2
+
 	u8 phy_link_up; /* internal phy link indication */
 	u8 link_up;
+
+	u16 line_speed;
 	u16 duplex;
+
 	u16 flow_ctrl;
-	u32 ieee_fc;
-	u8 mac_type;
+	u16 ieee_fc;
 
-#define MAC_TYPE_NONE	0
-#define MAC_TYPE_EMAC	1
-#define MAC_TYPE_BMAC	2
-	u16 line_speed;
 	u32 autoneg;
 #define AUTO_NEG_DISABLED			0x0
 #define AUTO_NEG_ENABLED			0x1
 #define AUTO_NEG_COMPLETE			0x2
-#define AUTO_NEG_PARALLEL_DETECTION_USED 	0x3
-
-	u8 phy_flags;
+#define AUTO_NEG_PARALLEL_DETECTION_USED	0x3
 
 	/* The same definitions as the shmem parameter */
 	u32 link_status;
-- 
1.5.4.3




