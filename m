From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 26/36] bnx2x: Remove SGMII configuration when not
 required
Date: Wed, 12 Aug 2009 21:23:53 +0300
Message-ID: <1250101433.27379.178.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3162 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbZHLSYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index b81a057..c163c42 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1276,14 +1276,14 @@ static void bnx2x_program_serdes(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
 
-	/* program duplex, disable autoneg */
-
+	/* program duplex, disable autoneg and sgmii*/
 	CL45_RD_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
 	reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX |
-		     MDIO_COMBO_IEEO_MII_CONTROL_AN_EN);
+		     MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
+		     MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK);
 	if (params->req_duplex == DUPLEX_FULL)
 		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
 	CL45_WR_OVER_CL22(bp, params->port,
@@ -5271,6 +5271,13 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			ext_phy_link_up = 0;
 			break;
 		}
+		/* Set SGMII mode for external phy */
+		if (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
+			if (vars->line_speed < SPEED_1000)
+				vars->phy_flags |= PHY_SGMII_FLAG;
+			else
+				vars->phy_flags &= ~PHY_SGMII_FLAG;
+		}
 
 	} else { /* SerDes */
 		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
-- 
1.5.4.3




