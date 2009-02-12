From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 20/41]bnx2x: Removing CL73 code
Date: Thu, 12 Feb 2009 20:37:09 +0200
Message-ID: <1234463829.1863.152.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758305AbZBLShe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 20/41]bnx2x: Removing CL73 code
This code is disabled, so removing it to avoid confusion

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  111 ++++++++--------------------------------------
 1 files changed, 19 insertions(+), 92 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 2463de8..526072b 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -29,7 +29,6 @@
 #include "bnx2x.h"
 
 /********************************************************/
-#define SUPPORT_CL73 0 /* Currently no */
 #define ETH_HLEN			14
 #define ETH_OVREHEAD		(ETH_HLEN + 8)/* 8 for CRC + VLAN*/
 #define ETH_MIN_PACKET_SIZE		60
@@ -1208,62 +1207,9 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
 			      reg_val);
 
-	/* Enable Clause 73 Aneg */
-	if ((vars->line_speed == SPEED_AUTO_NEG) &&
-	    (SUPPORT_CL73)) {
-		/* Enable BAM Station Manager */
+	/* CL73 Autoneg Disabled */
+	reg_val = 0;
 
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_CL73_USERB0,
-				      MDIO_CL73_USERB0_CL73_BAM_CTRL1,
-				   (MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN |
-			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN |
-			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN));
-
-		/* Merge CL73 and CL37 aneg resolution */
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_CL73_USERB0,
-				      MDIO_CL73_USERB0_CL73_BAM_CTRL3,
-				      &reg_val);
-
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-			MDIO_REG_BANK_CL73_USERB0,
-			MDIO_CL73_USERB0_CL73_BAM_CTRL3,
-			(reg_val |
-			MDIO_CL73_USERB0_CL73_BAM_CTRL3_USE_CL73_HCD_MR));
-
-		/* Set the CL73 AN speed */
-
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_CL73_IEEEB1,
-				      MDIO_CL73_IEEEB1_AN_ADV2, &reg_val);
-		/* In the SerDes we support only the 1G.
-		   In the XGXS we support the 10G KX4
-		   but we currently do not support the KR */
-		if (vars->phy_flags & PHY_XGXS_FLAG) {
-			DP(NETIF_MSG_LINK, "XGXS\n");
-			/* 10G KX4 */
-			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4;
-		} else {
-			DP(NETIF_MSG_LINK, "SerDes\n");
-			/* 1000M KX */
-			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
-		}
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_CL73_IEEEB1,
-				      MDIO_CL73_IEEEB1_AN_ADV2, reg_val);
-
-		/* CL73 Autoneg Enabled */
-		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
-	} else {
-		/* CL73 Autoneg Disabled */
-		reg_val = 0;
-	}
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_CL73_IEEEB0,
@@ -1396,44 +1342,25 @@ static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
 static void bnx2x_restart_autoneg(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
+	u16 mii_control;
 	DP(NETIF_MSG_LINK, "bnx2x_restart_autoneg\n");
-	if (SUPPORT_CL73) {
-		/* enable and restart clause 73 aneg */
-		u16 an_ctrl;
-
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_CL73_IEEEB0,
-				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				  &an_ctrl);
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				MDIO_REG_BANK_CL73_IEEEB0,
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				(an_ctrl |
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN |
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN));
+	/* Enable and restart BAM/CL37 aneg */
 
-	} else {
-		/* Enable and restart BAM/CL37 aneg */
-		u16 mii_control;
-
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      &mii_control);
-		DP(NETIF_MSG_LINK,
-			 "bnx2x_restart_autoneg mii_control before = 0x%x\n",
-			 mii_control);
-		CL45_WR_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      (mii_control |
-				MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
-				MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
-	}
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_COMBO_IEEE0,
+			      MDIO_COMBO_IEEE0_MII_CONTROL,
+			      &mii_control);
+	DP(NETIF_MSG_LINK,
+		 "bnx2x_restart_autoneg mii_control before = 0x%x\n",
+		 mii_control);
+	CL45_WR_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_COMBO_IEEE0,
+			      MDIO_COMBO_IEEE0_MII_CONTROL,
+			      (mii_control |
+			       MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
+			       MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
 }
 
 static void bnx2x_initialize_sgmii_process(struct link_params *params,
-- 
1.5.4.3




