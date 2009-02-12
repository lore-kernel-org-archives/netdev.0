From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 23/41]bnx2x: Using registers name
Date: Thu, 12 Feb 2009 20:37:16 +0200
Message-ID: <1234463836.1863.155.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3738 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758320AbZBLShm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 23/41]bnx2x: Using registers name

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    9 ++++--
 drivers/net/bnx2x_link.c |   71 +++++++++++++++++++++++----------------------
 drivers/net/bnx2x_reg.h  |    7 ++++
 3 files changed, 49 insertions(+), 38 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 12d2d0b..9834a86 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -446,10 +446,13 @@ struct bnx2x_fastpath {
 #define BNX2X_RX_CSUM_OK(cqe) \
 			(!(BNX2X_L4_CSUM_ERR(cqe) || BNX2X_IP_CSUM_ERR(cqe)))
 
+#define BNX2X_PRS_FLAG_OVERETH_IPV4(flags) \
+				(((le16_to_cpu(flags) & \
+				   PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) >> \
+				  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT) \
+				 == PRS_FLAG_OVERETH_IPV4)
 #define BNX2X_RX_SUM_FIX(cqe) \
-			((le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) & \
-			  PARSING_FLAGS_OVER_ETHERNET_PROTOCOL) == \
-			 (1 << PARSING_FLAGS_OVER_ETHERNET_PROTOCOL_SHIFT))
+	BNX2X_PRS_FLAG_OVERETH_IPV4(cqe->fast_path_cqe.pars_flags.flags)
 
 
 #define FP_USB_FUNC_OFF			(2 + 2*HC_USTORM_SB_NUM_INDICES)
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 4a594b8..39db995 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -2094,7 +2094,7 @@ static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
 		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 		      ext_phy_addr,
 		      MDIO_PMA_DEVAD,
-		      0xc801, &val);
+		      MDIO_PMA_REG_8073_CHIP_REV, &val);
 
 	if (val != 1) {
 		/* No need to workaround in 8073 A1 */
@@ -2126,7 +2126,7 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 		      ext_phy_addr,
 		      MDIO_PMA_DEVAD,
-		      0xc801, &val);
+		      MDIO_PMA_REG_8073_CHIP_REV, &val);
 
 	if (val > 0) {
 		/* No need to workaround in 8073 A1 */
@@ -2142,7 +2142,8 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 			      ext_phy_addr,
 			      MDIO_PMA_DEVAD,
-			      0xc820, &val);
+			      MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
+			      &val);
 		  /* If bit [14] = 0 or bit [13] = 0, continue on with
 		   system initialization (XAUI work-around not required,
 		    as these bits indicate 2.5G or 1G link up). */
@@ -2160,7 +2161,7 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 					ext_phy_addr,
 					MDIO_PMA_DEVAD,
-					0xc841, &val);
+					MDIO_PMA_REG_8073_XAUI_WA, &val);
 				if (val & (1<<15)) {
 					DP(NETIF_MSG_LINK,
 					  "XAUI workaround has completed\n");
@@ -2758,7 +2759,7 @@ static void bnx2x_bcm8073_set_xaui_low_power_mode(struct link_params *params)
 		      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 		      ext_phy_addr,
 		      MDIO_PMA_DEVAD,
-		      0xc801, &val);
+		      MDIO_PMA_REG_8073_CHIP_REV, &val);
 
 	if (val == 0) {
 		/* Mustn't set low power mode in 8073 A0 */
@@ -3283,7 +3284,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				      ext_phy_type,
 				      ext_phy_addr,
 				      MDIO_PMA_DEVAD,
-				      0xca13,
+				      MDIO_PMA_REG_M8051_MSGOUT_REG,
 				      &tmp1);
 
 			bnx2x_cl45_read(bp, params->port,
@@ -3350,7 +3351,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					      ext_phy_type,
 					      ext_phy_addr,
 					      MDIO_AN_DEVAD,
-					      0x8329, &tmp1);
+					      MDIO_AN_REG_8073_2_5G, &tmp1);
 
 				if (((params->speed_cap_mask &
 				      PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) &&
@@ -3364,7 +3365,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					 PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
 					 ext_phy_addr,
 					 MDIO_PMA_DEVAD,
-					 0xc801, &phy_ver);
+					 MDIO_PMA_REG_8073_CHIP_REV, &phy_ver);
 					DP(NETIF_MSG_LINK, "Add 2.5G\n");
 					if (phy_ver > 0)
 						tmp1 |= 1;
@@ -3379,7 +3380,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       ext_phy_type,
 					       ext_phy_addr,
 					       MDIO_AN_DEVAD,
-					       0x8329, tmp1);
+					       MDIO_AN_REG_8073_2_5G, tmp1);
 			}
 
 			/* Add support for CL37 (passive mode) II */
@@ -3737,7 +3738,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				      ext_phy_type,
 				      ext_phy_addr,
 				      MDIO_PMA_DEVAD,
-				      0xca13,
+				      MDIO_PMA_REG_M8051_MSGOUT_REG,
 				      &val1);
 
 			/* Check the LASI */
@@ -3782,17 +3783,17 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 					}
 				}
 				bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
-						      MDIO_AN_DEVAD,
-						      0x8304,
-						      &an1000_status);
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_LINK_STATUS,
+					      &an1000_status);
 				bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
-						      MDIO_AN_DEVAD,
-						      0x8304,
-						      &an1000_status);
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_LINK_STATUS,
+					      &an1000_status);
 
 				/* Check the link status on 1.1.2 */
 				bnx2x_cl45_read(bp, params->port,
@@ -3837,11 +3838,11 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 
 				}
 				bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
-						      MDIO_PMA_DEVAD,
-						      0xc820,
-						      &link_status);
+					   ext_phy_type,
+					   ext_phy_addr,
+					   MDIO_PMA_DEVAD,
+					   MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
+					   &link_status);
 
 				/* Bits 0..2 --> speed detected,
 				   bits 13..15--> link is down */
@@ -3875,17 +3876,17 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			} else {
 				/* See if 1G link is up for the 8072 */
 				bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
-						      MDIO_AN_DEVAD,
-						      0x8304,
-						      &an1000_status);
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_LINK_STATUS,
+					      &an1000_status);
 				bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
-						      MDIO_AN_DEVAD,
-						      0x8304,
-						      &an1000_status);
+					      ext_phy_type,
+					      ext_phy_addr,
+					      MDIO_AN_DEVAD,
+					      MDIO_AN_REG_LINK_STATUS,
+					      &an1000_status);
 				if (an1000_status & (1<<1)) {
 					ext_phy_link_up = 1;
 					vars->line_speed = SPEED_1000;
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 08e703d..360a256 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5239,6 +5239,7 @@
 #define HW_LOCK_RESOURCE_PORT0_ATT_MASK 			 3
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define HW_LOCK_RESOURCE_UNDI					 5
+#define PRS_FLAG_OVERETH_IPV4					 1
 #define AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR		      (1<<18)
 #define AEU_INPUTS_ATTN_BITS_CCM_HW_INTERRUPT		      (1<<31)
 #define AEU_INPUTS_ATTN_BITS_CDU_HW_INTERRUPT		      (1<<9)
@@ -5861,6 +5862,10 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_8726_TX_CTRL2		0xca05
 
 
+#define MDIO_PMA_REG_8073_CHIP_REV			0xc801
+#define MDIO_PMA_REG_8073_SPEED_LINK_STATUS		0xc820
+#define MDIO_PMA_REG_8073_XAUI_WA			0xc841
+
 #define MDIO_PMA_REG_7101_RESET 	0xc000
 #define MDIO_PMA_REG_7107_LED_CNTL	0xc007
 #define MDIO_PMA_REG_7101_VER1		0xc026
@@ -5917,6 +5922,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_AN_REG_CL37_FC_LD		0xffe4
 #define MDIO_AN_REG_CL37_FC_LP		0xffe5
 
+#define MDIO_AN_REG_8073_2_5G		0x8329
+
 
 #define IGU_FUNC_BASE			0x0400
 
-- 
1.5.4.3




