From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 01/10] bnx2x: Fix line indentation
Date: Mon, 31 Jan 2011 16:21:34 +0200
Message-ID: <1296483694.17181.111.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1577 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752299Ab1AaOYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:24:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains cosmetic changes only to fix code alignment, and update copyright comment year

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c | 1226 +++++++++++++++++++---------------------
 drivers/net/bnx2x/bnx2x_link.h |   29 +-
 2 files changed, 607 insertions(+), 648 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 7160ec5..b992126 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1,4 +1,4 @@
-/* Copyright 2008-2009 Broadcom Corporation
+/* Copyright 2008-2011 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
@@ -28,12 +28,13 @@
 
 /********************************************************/
 #define ETH_HLEN			14
-#define ETH_OVREHEAD		(ETH_HLEN + 8 + 8)/* 16 for CRC + VLAN + LLC */
+/* L2 header size + 2*VLANs (8 bytes) + LLC SNAP (8 bytes) */
+#define ETH_OVREHEAD			(ETH_HLEN + 8 + 8)
 #define ETH_MIN_PACKET_SIZE		60
 #define ETH_MAX_PACKET_SIZE		1500
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 #define MDIO_ACCESS_TIMEOUT		1000
-#define BMAC_CONTROL_RX_ENABLE	2
+#define BMAC_CONTROL_RX_ENABLE		2
 
 /***********************************************************/
 /*			Shortcut definitions		   */
@@ -79,7 +80,7 @@
 
 #define AUTONEG_CL37		SHARED_HW_CFG_AN_ENABLE_CL37
 #define AUTONEG_CL73		SHARED_HW_CFG_AN_ENABLE_CL73
-#define AUTONEG_BAM 		SHARED_HW_CFG_AN_ENABLE_BAM
+#define AUTONEG_BAM		SHARED_HW_CFG_AN_ENABLE_BAM
 #define AUTONEG_PARALLEL \
 				SHARED_HW_CFG_AN_ENABLE_PARALLEL_DETECTION
 #define AUTONEG_SGMII_FIBER_AUTODET \
@@ -112,10 +113,10 @@
 #define GP_STATUS_10G_KX4 \
 			MDIO_GP_STATUS_TOP_AN_STATUS1_ACTUAL_SPEED_10G_KX4
 
-#define LINK_10THD			LINK_STATUS_SPEED_AND_DUPLEX_10THD
-#define LINK_10TFD			LINK_STATUS_SPEED_AND_DUPLEX_10TFD
+#define LINK_10THD		LINK_STATUS_SPEED_AND_DUPLEX_10THD
+#define LINK_10TFD		LINK_STATUS_SPEED_AND_DUPLEX_10TFD
 #define LINK_100TXHD		LINK_STATUS_SPEED_AND_DUPLEX_100TXHD
-#define LINK_100T4			LINK_STATUS_SPEED_AND_DUPLEX_100T4
+#define LINK_100T4		LINK_STATUS_SPEED_AND_DUPLEX_100T4
 #define LINK_100TXFD		LINK_STATUS_SPEED_AND_DUPLEX_100TXFD
 #define LINK_1000THD		LINK_STATUS_SPEED_AND_DUPLEX_1000THD
 #define LINK_1000TFD		LINK_STATUS_SPEED_AND_DUPLEX_1000TFD
@@ -123,18 +124,18 @@
 #define LINK_2500THD		LINK_STATUS_SPEED_AND_DUPLEX_2500THD
 #define LINK_2500TFD		LINK_STATUS_SPEED_AND_DUPLEX_2500TFD
 #define LINK_2500XFD		LINK_STATUS_SPEED_AND_DUPLEX_2500XFD
-#define LINK_10GTFD			LINK_STATUS_SPEED_AND_DUPLEX_10GTFD
-#define LINK_10GXFD			LINK_STATUS_SPEED_AND_DUPLEX_10GXFD
-#define LINK_12GTFD			LINK_STATUS_SPEED_AND_DUPLEX_12GTFD
-#define LINK_12GXFD			LINK_STATUS_SPEED_AND_DUPLEX_12GXFD
+#define LINK_10GTFD		LINK_STATUS_SPEED_AND_DUPLEX_10GTFD
+#define LINK_10GXFD		LINK_STATUS_SPEED_AND_DUPLEX_10GXFD
+#define LINK_12GTFD		LINK_STATUS_SPEED_AND_DUPLEX_12GTFD
+#define LINK_12GXFD		LINK_STATUS_SPEED_AND_DUPLEX_12GXFD
 #define LINK_12_5GTFD		LINK_STATUS_SPEED_AND_DUPLEX_12_5GTFD
 #define LINK_12_5GXFD		LINK_STATUS_SPEED_AND_DUPLEX_12_5GXFD
-#define LINK_13GTFD			LINK_STATUS_SPEED_AND_DUPLEX_13GTFD
-#define LINK_13GXFD			LINK_STATUS_SPEED_AND_DUPLEX_13GXFD
-#define LINK_15GTFD			LINK_STATUS_SPEED_AND_DUPLEX_15GTFD
-#define LINK_15GXFD			LINK_STATUS_SPEED_AND_DUPLEX_15GXFD
-#define LINK_16GTFD			LINK_STATUS_SPEED_AND_DUPLEX_16GTFD
-#define LINK_16GXFD			LINK_STATUS_SPEED_AND_DUPLEX_16GXFD
+#define LINK_13GTFD		LINK_STATUS_SPEED_AND_DUPLEX_13GTFD
+#define LINK_13GXFD		LINK_STATUS_SPEED_AND_DUPLEX_13GXFD
+#define LINK_15GTFD		LINK_STATUS_SPEED_AND_DUPLEX_15GTFD
+#define LINK_15GXFD		LINK_STATUS_SPEED_AND_DUPLEX_15GXFD
+#define LINK_16GTFD		LINK_STATUS_SPEED_AND_DUPLEX_16GTFD
+#define LINK_16GXFD		LINK_STATUS_SPEED_AND_DUPLEX_16GXFD
 
 #define PHY_XGXS_FLAG			0x1
 #define PHY_SGMII_FLAG			0x2
@@ -142,7 +143,7 @@
 
 /* */
 #define SFP_EEPROM_CON_TYPE_ADDR		0x2
-	#define SFP_EEPROM_CON_TYPE_VAL_LC 		0x7
+	#define SFP_EEPROM_CON_TYPE_VAL_LC	0x7
 	#define SFP_EEPROM_CON_TYPE_VAL_COPPER	0x21
 

@@ -153,15 +154,15 @@
 
 #define SFP_EEPROM_FC_TX_TECH_ADDR		0x8
 	#define SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_PASSIVE 0x4
-	#define SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_ACTIVE	 0x8
+	#define SFP_EEPROM_FC_TX_TECH_BITMASK_COPPER_ACTIVE  0x8
 
-#define SFP_EEPROM_OPTIONS_ADDR 		0x40
+#define SFP_EEPROM_OPTIONS_ADDR			0x40
 	#define SFP_EEPROM_OPTIONS_LINEAR_RX_OUT_MASK 0x1
-#define SFP_EEPROM_OPTIONS_SIZE 		2
+#define SFP_EEPROM_OPTIONS_SIZE			2
 
-#define EDC_MODE_LINEAR	 			0x0022
-#define EDC_MODE_LIMITING	 			0x0044
-#define EDC_MODE_PASSIVE_DAC 			0x0055
+#define EDC_MODE_LINEAR				0x0022
+#define EDC_MODE_LIMITING				0x0044
+#define EDC_MODE_PASSIVE_DAC			0x0055
 

 #define ETS_BW_LIMIT_CREDIT_UPPER_BOUND		(0x5000)
@@ -329,8 +330,7 @@ void bnx2x_ets_bw_limit(const struct link_params *params, const u32 cos0_bw,
 	if ((0 == total_bw) ||
 	    (0 == cos0_bw) ||
 	    (0 == cos1_bw)) {
-		DP(NETIF_MSG_LINK,
-		   "bnx2x_ets_bw_limit: Total BW can't be zero\n");
+		DP(NETIF_MSG_LINK, "Total BW can't be zero\n");
 		return;
 	}
 
@@ -471,7 +471,7 @@ void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 /*			MAC/PBF section				  */
 /******************************************************************/
 static void bnx2x_emac_init(struct link_params *params,
-			   struct link_vars *vars)
+			    struct link_vars *vars)
 {
 	/* reset and unreset the emac core */
 	struct bnx2x *bp = params->bp;
@@ -481,10 +481,10 @@ static void bnx2x_emac_init(struct link_params *params,
 	u16 timeout;
 
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-		   (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
+	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
 	udelay(5);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-		   (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
+	       (MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE << port));
 
 	/* init emac - use read-modify-write */
 	/* self clear reset */
@@ -515,7 +515,7 @@ static void bnx2x_emac_init(struct link_params *params,
 }
 
 static u8 bnx2x_emac_enable(struct link_params *params,
-			  struct link_vars *vars, u8 lb)
+			    struct link_vars *vars, u8 lb)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -531,8 +531,7 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 	if (CHIP_REV_IS_EMUL(bp)) {
 		/* Use lane 1 (of lanes 0-3) */
 		REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, 1);
-		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL +
-			    port*4, 1);
+		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
 	}
 	/* for fpga */
 	else
@@ -542,40 +541,35 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 		DP(NETIF_MSG_LINK, "bnx2x_emac_enable: Setting FPGA\n");
 
 		REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, 1);
-		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4,
-			    0);
+		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0);
 	} else
 	/* ASIC */
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
 		u32 ser_lane = ((params->lane_config &
-			    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
-			    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
+				 PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
+				PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
 		DP(NETIF_MSG_LINK, "XGXS\n");
 		/* select the master lanes (out of 0-3) */
-		REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 +
-			   port*4, ser_lane);
+		REG_WR(bp, NIG_REG_XGXS_LANE_SEL_P0 + port*4, ser_lane);
 		/* select XGXS */
-		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL +
-			   port*4, 1);
+		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
 
 	} else { /* SerDes */
 		DP(NETIF_MSG_LINK, "SerDes\n");
 		/* select SerDes */
-		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL +
-			   port*4, 0);
+		REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 0);
 	}
 
 	bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
-		    EMAC_RX_MODE_RESET);
+		      EMAC_RX_MODE_RESET);
 	bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
-		    EMAC_TX_MODE_RESET);
+		      EMAC_TX_MODE_RESET);
 
 	if (CHIP_REV_IS_SLOW(bp)) {
 		/* config GMII mode */
 		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-		EMAC_WR(bp, EMAC_REG_EMAC_MODE,
-			    (val | EMAC_MODE_PORT_GMII));
+		EMAC_WR(bp, EMAC_REG_EMAC_MODE, (val | EMAC_MODE_PORT_GMII));
 	} else { /* ASIC */
 		/* pause enable/disable */
 		bnx2x_bits_dis(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
@@ -668,9 +662,8 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 
 	if (CHIP_REV_IS_EMUL(bp)) {
 		/* take the BigMac out of reset */
-		REG_WR(bp,
-			   GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-			   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
+		       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 
 		/* enable access for bmac registers */
 		REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
@@ -731,8 +724,7 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 		val |= (1<<5);
 	wb_data[0] = val;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_CONTROL,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_CONTROL, wb_data, 2);
 	udelay(30);
 
 	/* Tx control */
@@ -781,7 +773,7 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 	wb_data[0] = val;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_PAUSE_CONTROL,
-			wb_data, 2);
+		    wb_data, 2);
 
 	/* mac control */
 	val = 0x3; /* Enable RX and TX */
@@ -795,8 +787,7 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 
 	wb_data[0] = val;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_CONTROL,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_CONTROL, wb_data, 2);
 }
 
 static void bnx2x_update_pfc_brb(struct link_params *params,
@@ -1035,7 +1026,7 @@ void bnx2x_update_pfc(struct link_params *params,
 
 static u8 bnx2x_bmac1_enable(struct link_params *params,
 			     struct link_vars *vars,
-			  u8 is_lb)
+			     u8 is_lb)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -1049,9 +1040,8 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 	/* XGXS control */
 	wb_data[0] = 0x3c;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr +
-		      BIGMAC_REGISTER_BMAC_XGXS_CONTROL,
-		      wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_XGXS_CONTROL,
+		    wb_data, 2);
 
 	/* tx MAC SA */
 	wb_data[0] = ((params->mac_addr[2] << 24) |
@@ -1060,8 +1050,7 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 			params->mac_addr[5]);
 	wb_data[1] = ((params->mac_addr[0] << 8) |
 			params->mac_addr[1]);
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_SOURCE_ADDR,
-		    wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_SOURCE_ADDR, wb_data, 2);
 
 	/* mac control */
 	val = 0x3;
@@ -1071,28 +1060,24 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 	}
 	wb_data[0] = val;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
-		    wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL, wb_data, 2);
 
 	/* set rx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_MAX_SIZE,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_MAX_SIZE, wb_data, 2);
 
 	bnx2x_update_pfc_bmac1(params, vars);
 
 	/* set tx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_MAX_SIZE,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_MAX_SIZE, wb_data, 2);
 
 	/* set cnt max size */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_CNT_MAX_SIZE,
-		    wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_CNT_MAX_SIZE, wb_data, 2);
 
 	/* configure safc */
 	wb_data[0] = 0x1000200;
@@ -1103,8 +1088,7 @@ static u8 bnx2x_bmac1_enable(struct link_params *params,
 	if (CHIP_REV_IS_EMUL(bp)) {
 		wb_data[0] = 0xf000;
 		wb_data[1] = 0;
-		REG_WR_DMAE(bp,
-			    bmac_addr + BIGMAC_REGISTER_TX_PAUSE_THRESHOLD,
+		REG_WR_DMAE(bp,	bmac_addr + BIGMAC_REGISTER_TX_PAUSE_THRESHOLD,
 			    wb_data, 2);
 	}
 
@@ -1126,16 +1110,14 @@ static u8 bnx2x_bmac2_enable(struct link_params *params,
 
 	wb_data[0] = 0;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_CONTROL,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_CONTROL, wb_data, 2);
 	udelay(30);
 
 	/* XGXS control: Reset phy HW, MDIO registers, PHY PLL and BMAC */
 	wb_data[0] = 0x3c;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr +
-			BIGMAC2_REGISTER_BMAC_XGXS_CONTROL,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_BMAC_XGXS_CONTROL,
+		    wb_data, 2);
 
 	udelay(30);
 
@@ -1147,7 +1129,7 @@ static u8 bnx2x_bmac2_enable(struct link_params *params,
 	wb_data[1] = ((params->mac_addr[0] << 8) |
 			params->mac_addr[1]);
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_SOURCE_ADDR,
-			wb_data, 2);
+		    wb_data, 2);
 
 	udelay(30);
 
@@ -1155,27 +1137,24 @@ static u8 bnx2x_bmac2_enable(struct link_params *params,
 	wb_data[0] = 0x1000200;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_LLFC_MSG_FLDS,
-			wb_data, 2);
+		    wb_data, 2);
 	udelay(30);
 
 	/* set rx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_MAX_SIZE,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_MAX_SIZE, wb_data, 2);
 	udelay(30);
 
 	/* set tx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_MAX_SIZE,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_MAX_SIZE, wb_data, 2);
 	udelay(30);
 	/* set cnt max size */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD - 2;
 	wb_data[1] = 0;
-	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_CNT_MAX_SIZE,
-			wb_data, 2);
+	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_CNT_MAX_SIZE, wb_data, 2);
 	udelay(30);
 	bnx2x_update_pfc_bmac2(params, vars, is_lb);
 
@@ -1191,11 +1170,11 @@ static u8 bnx2x_bmac_enable(struct link_params *params,
 	u32 val;
 	/* reset and unreset the BigMac */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-		     (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 	msleep(1);
 
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
-		     (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 
 	/* enable access for bmac registers */
 	REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
@@ -1230,15 +1209,14 @@ static void bnx2x_update_mng(struct link_params *params, u32 link_status)
 	struct bnx2x *bp = params->bp;
 
 	REG_WR(bp, params->shmem_base +
-		   offsetof(struct shmem_region,
-			    port_mb[params->port].link_status),
-			link_status);
+	       offsetof(struct shmem_region,
+			port_mb[params->port].link_status), link_status);
 }
 
 static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 {
 	u32 bmac_addr = port ? NIG_REG_INGRESS_BMAC1_MEM :
-		NIG_REG_INGRESS_BMAC0_MEM;
+			NIG_REG_INGRESS_BMAC0_MEM;
 	u32 wb_data[2];
 	u32 nig_bmac_enable = REG_RD(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4);
 
@@ -1250,12 +1228,12 @@ static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 		if (CHIP_IS_E2(bp)) {
 			/* Clear Rx Enable bit in BMAC_CONTROL register */
 			REG_RD_DMAE(bp, bmac_addr +
-					BIGMAC2_REGISTER_BMAC_CONTROL,
-					wb_data, 2);
+				    BIGMAC2_REGISTER_BMAC_CONTROL,
+				    wb_data, 2);
 			wb_data[0] &= ~BMAC_CONTROL_RX_ENABLE;
 			REG_WR_DMAE(bp, bmac_addr +
-					BIGMAC2_REGISTER_BMAC_CONTROL,
-					wb_data, 2);
+				    BIGMAC2_REGISTER_BMAC_CONTROL,
+				    wb_data, 2);
 		} else {
 			/* Clear Rx Enable bit in BMAC_CONTROL register */
 			REG_RD_DMAE(bp, bmac_addr +
@@ -1271,7 +1249,7 @@ static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 }
 
 static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
-			 u32 line_speed)
+			   u32 line_speed)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -1308,7 +1286,7 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 		/* update threshold */
 		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, 0);
 		/* update init credit */
-		init_crd = 778; 	/* (800-18-4) */
+		init_crd = 778;		/* (800-18-4) */
 
 	} else {
 		u32 thresh = (ETH_MAX_JUMBO_PACKET_SIZE +
@@ -1414,8 +1392,7 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 	for (i = 0; i < 50; i++) {
 		udelay(10);
 
-		tmp = REG_RD(bp, phy->mdio_ctrl +
-				   EMAC_REG_EMAC_MDIO_COMM);
+		tmp = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_COMM);
 		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 			udelay(5);
 			break;
@@ -1435,7 +1412,7 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 			udelay(10);
 
 			tmp = REG_RD(bp, phy->mdio_ctrl +
-					 EMAC_REG_EMAC_MDIO_COMM);
+				     EMAC_REG_EMAC_MDIO_COMM);
 			if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
 				udelay(5);
 				break;
@@ -1466,7 +1443,7 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 
 	saved_mode = REG_RD(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	val = saved_mode & ~((EMAC_MDIO_MODE_AUTO_POLL |
-			     EMAC_MDIO_MODE_CLOCK_CNT));
+			      EMAC_MDIO_MODE_CLOCK_CNT));
 	val |= (EMAC_MDIO_MODE_CLAUSE_45 |
 		(49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
 	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
@@ -1505,7 +1482,7 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 			udelay(10);
 
 			val = REG_RD(bp, phy->mdio_ctrl +
-					  EMAC_REG_EMAC_MDIO_COMM);
+				     EMAC_REG_EMAC_MDIO_COMM);
 			if (!(val & EMAC_MDIO_COMM_START_BUSY)) {
 				*ret_val = (u16)(val & EMAC_MDIO_COMM_DATA);
 				break;
@@ -1576,16 +1553,15 @@ static void bnx2x_set_aer_mmd_xgxs(struct link_params *params,
 		aer_val = 0x3800 + offset - 1;
 	else
 		aer_val = 0x3800 + offset;
-	CL45_WR_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_AER_BLOCK,
-				MDIO_AER_BLOCK_AER_REG, aer_val);
+	CL45_WR_OVER_CL22(bp, phy, MDIO_REG_BANK_AER_BLOCK,
+			  MDIO_AER_BLOCK_AER_REG, aer_val);
 }
 static void bnx2x_set_aer_mmd_serdes(struct bnx2x *bp,
 				     struct bnx2x_phy *phy)
 {
 	CL45_WR_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_AER_BLOCK,
-				MDIO_AER_BLOCK_AER_REG, 0x3800);
+			  MDIO_REG_BANK_AER_BLOCK,
+			  MDIO_AER_BLOCK_AER_REG, 0x3800);
 }
 
 /******************************************************************/
@@ -1621,9 +1597,8 @@ static void bnx2x_serdes_deassert(struct bnx2x *bp, u8 port)
 
 	bnx2x_set_serdes_access(bp, port);
 
-	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
-		     port*0x10,
-		     DEFAULT_PHY_DEV_ADDR);
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD + port*0x10,
+	       DEFAULT_PHY_DEV_ADDR);
 }
 
 static void bnx2x_xgxs_deassert(struct link_params *params)
@@ -1641,23 +1616,22 @@ static void bnx2x_xgxs_deassert(struct link_params *params)
 	udelay(500);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
 
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
-		     port*0x18, 0);
+	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST + port*0x18, 0);
 	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
-		     params->phy[INT_PHY].def_md_devad);
+	       params->phy[INT_PHY].def_md_devad);
 }
 

 void bnx2x_link_status_update(struct link_params *params,
-			    struct link_vars   *vars)
+			      struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u8 link_10g;
 	u8 port = params->port;
 
 	vars->link_status = REG_RD(bp, params->shmem_base +
-					  offsetof(struct shmem_region,
-					   port_mb[port].link_status));
+				   offsetof(struct shmem_region,
+					    port_mb[port].link_status));
 
 	vars->link_up = (vars->link_status & LINK_STATUS_LINK_UP);
 
@@ -1667,7 +1641,7 @@ void bnx2x_link_status_update(struct link_params *params,
 		vars->phy_link_up = 1;
 		vars->duplex = DUPLEX_FULL;
 		switch (vars->link_status &
-					LINK_STATUS_SPEED_AND_DUPLEX_MASK) {
+			LINK_STATUS_SPEED_AND_DUPLEX_MASK) {
 			case LINK_10THD:
 				vars->duplex = DUPLEX_HALF;
 				/* fall thru */
@@ -1779,20 +1753,20 @@ static void bnx2x_set_master_ln(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u16 new_master_ln, ser_lane;
-	ser_lane =  ((params->lane_config &
+	ser_lane = ((params->lane_config &
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
-		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
+		    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
 	/* set the master_ln for AN */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_XGXS_BLOCK2,
-			      MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
-			      &new_master_ln);
+			  MDIO_REG_BANK_XGXS_BLOCK2,
+			  MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
+			  &new_master_ln);
 
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_XGXS_BLOCK2 ,
-			      MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
-			      (new_master_ln | ser_lane));
+			  MDIO_REG_BANK_XGXS_BLOCK2 ,
+			  MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
+			  (new_master_ln | ser_lane));
 }
 
 static u8 bnx2x_reset_unicore(struct link_params *params,
@@ -1804,15 +1778,15 @@ static u8 bnx2x_reset_unicore(struct link_params *params,
 	u16 i;
 
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
 
 	/* reset the unicore */
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL,
-			      (mii_control |
-			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_MII_CONTROL,
+			  (mii_control |
+			   MDIO_COMBO_IEEO_MII_CONTROL_RESET));
 	if (set_serdes)
 		bnx2x_set_serdes_access(bp, params->port);
 
@@ -1822,9 +1796,9 @@ static u8 bnx2x_reset_unicore(struct link_params *params,
 
 		/* the reset erased the previous bank value */
 		CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL,
-			      &mii_control);
+				  MDIO_REG_BANK_COMBO_IEEE0,
+				  MDIO_COMBO_IEEE0_MII_CONTROL,
+				  &mii_control);
 
 		if (!(mii_control & MDIO_COMBO_IEEO_MII_CONTROL_RESET)) {
 			udelay(5);
@@ -1846,38 +1820,38 @@ static void bnx2x_set_swap_lanes(struct link_params *params,
 	u16 ser_lane, rx_lane_swap, tx_lane_swap;
 
 	ser_lane = ((params->lane_config &
-			 PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
-			PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
+		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
+		    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 	rx_lane_swap = ((params->lane_config &
-			     PORT_HW_CFG_LANE_SWAP_CFG_RX_MASK) >>
-			    PORT_HW_CFG_LANE_SWAP_CFG_RX_SHIFT);
+			 PORT_HW_CFG_LANE_SWAP_CFG_RX_MASK) >>
+			PORT_HW_CFG_LANE_SWAP_CFG_RX_SHIFT);
 	tx_lane_swap = ((params->lane_config &
-			     PORT_HW_CFG_LANE_SWAP_CFG_TX_MASK) >>
-			    PORT_HW_CFG_LANE_SWAP_CFG_TX_SHIFT);
+			 PORT_HW_CFG_LANE_SWAP_CFG_TX_MASK) >>
+			PORT_HW_CFG_LANE_SWAP_CFG_TX_SHIFT);
 
 	if (rx_lane_swap != 0x1b) {
 		CL45_WR_OVER_CL22(bp, phy,
-				    MDIO_REG_BANK_XGXS_BLOCK2,
-				    MDIO_XGXS_BLOCK2_RX_LN_SWAP,
-				    (rx_lane_swap |
-				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE |
-				    MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE));
+				  MDIO_REG_BANK_XGXS_BLOCK2,
+				  MDIO_XGXS_BLOCK2_RX_LN_SWAP,
+				  (rx_lane_swap |
+				   MDIO_XGXS_BLOCK2_RX_LN_SWAP_ENABLE |
+				   MDIO_XGXS_BLOCK2_RX_LN_SWAP_FORCE_ENABLE));
 	} else {
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_XGXS_BLOCK2,
-				      MDIO_XGXS_BLOCK2_RX_LN_SWAP, 0);
+				  MDIO_REG_BANK_XGXS_BLOCK2,
+				  MDIO_XGXS_BLOCK2_RX_LN_SWAP, 0);
 	}
 
 	if (tx_lane_swap != 0x1b) {
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_XGXS_BLOCK2,
-				      MDIO_XGXS_BLOCK2_TX_LN_SWAP,
-				      (tx_lane_swap |
-				       MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE));
+				  MDIO_REG_BANK_XGXS_BLOCK2,
+				  MDIO_XGXS_BLOCK2_TX_LN_SWAP,
+				  (tx_lane_swap |
+				   MDIO_XGXS_BLOCK2_TX_LN_SWAP_ENABLE));
 	} else {
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_XGXS_BLOCK2,
-				      MDIO_XGXS_BLOCK2_TX_LN_SWAP, 0);
+				  MDIO_REG_BANK_XGXS_BLOCK2,
+				  MDIO_XGXS_BLOCK2_TX_LN_SWAP, 0);
 	}
 }
 
@@ -1887,9 +1861,9 @@ static void bnx2x_set_parallel_detection(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 control2;
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
-			      &control2);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
+			  &control2);
 	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
 		control2 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
 	else
@@ -1897,9 +1871,9 @@ static void bnx2x_set_parallel_detection(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "phy->speed_cap_mask = 0x%x, control2 = 0x%x\n",
 		phy->speed_cap_mask, control2);
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
-			      control2);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
+			  control2);
 
 	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
 	     (phy->speed_cap_mask &
@@ -1907,45 +1881,45 @@ static void bnx2x_set_parallel_detection(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "XGXS\n");
 
 		CL45_WR_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_10G_PARALLEL_DETECT,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT);
+				 MDIO_REG_BANK_10G_PARALLEL_DETECT,
+				 MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK,
+				 MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_LINK_CNT);
 
 		CL45_RD_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_10G_PARALLEL_DETECT,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
-				&control2);
+				  MDIO_REG_BANK_10G_PARALLEL_DETECT,
+				  MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
+				  &control2);
 

 		control2 |=
 		    MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL_PARDET10G_EN;
 
 		CL45_WR_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_10G_PARALLEL_DETECT,
-				MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
-				control2);
+				  MDIO_REG_BANK_10G_PARALLEL_DETECT,
+				  MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_CONTROL,
+				  control2);
 
 		/* Disable parallel detection of HiG */
 		CL45_WR_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_XGXS_BLOCK2,
-				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G,
-				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS |
-				MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_HIGIG_XGXS);
+				  MDIO_REG_BANK_XGXS_BLOCK2,
+				  MDIO_XGXS_BLOCK2_UNICORE_MODE_10G,
+				  MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_CX4_XGXS |
+				  MDIO_XGXS_BLOCK2_UNICORE_MODE_10G_HIGIG_XGXS);
 	}
 }
 
 static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 			      struct link_params *params,
-			    struct link_vars *vars,
-			    u8 enable_cl73)
+			      struct link_vars *vars,
+			      u8 enable_cl73)
 {
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
 
 	/* CL37 Autoneg */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
 
 	/* CL37 Autoneg Enabled */
 	if (vars->line_speed == SPEED_AUTO_NEG)
@@ -1955,14 +1929,14 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 			     MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN);
 
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
 
 	/* Enable/Disable Autodetection */
 
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, &reg_val);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, &reg_val);
 	reg_val &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN |
 		    MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT);
 	reg_val |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE;
@@ -1972,13 +1946,13 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 		reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
 
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, reg_val);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, reg_val);
 
 	/* Enable TetonII and BAM autoneg */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_BAM_NEXT_PAGE,
-			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
+			  MDIO_REG_BANK_BAM_NEXT_PAGE,
+			  MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
 			  &reg_val);
 	if (vars->line_speed == SPEED_AUTO_NEG) {
 		/* Enable BAM aneg Mode and TetonII aneg Mode */
@@ -1990,16 +1964,16 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 			     MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN);
 	}
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_BAM_NEXT_PAGE,
-			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
-			      reg_val);
+			  MDIO_REG_BANK_BAM_NEXT_PAGE,
+			  MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
+			  reg_val);
 
 	if (enable_cl73) {
 		/* Enable Cl73 FSM status bits */
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_CL73_USERB0,
-				    MDIO_CL73_USERB0_CL73_UCTRL,
-				      0xe);
+				  MDIO_REG_BANK_CL73_USERB0,
+				  MDIO_CL73_USERB0_CL73_UCTRL,
+				  0xe);
 
 		/* Enable BAM Station Manager*/
 		CL45_WR_OVER_CL22(bp, phy,
@@ -2011,9 +1985,9 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 
 		/* Advertise CL73 link speeds */
 		CL45_RD_OVER_CL22(bp, phy,
-					      MDIO_REG_BANK_CL73_IEEEB1,
-					      MDIO_CL73_IEEEB1_AN_ADV2,
-					      &reg_val);
+				  MDIO_REG_BANK_CL73_IEEEB1,
+				  MDIO_CL73_IEEEB1_AN_ADV2,
+				  &reg_val);
 		if (phy->speed_cap_mask &
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4;
@@ -2022,9 +1996,9 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
 
 		CL45_WR_OVER_CL22(bp, phy,
-					      MDIO_REG_BANK_CL73_IEEEB1,
-					      MDIO_CL73_IEEEB1_AN_ADV2,
-				      reg_val);
+				  MDIO_REG_BANK_CL73_IEEEB1,
+				  MDIO_CL73_IEEEB1_AN_ADV2,
+				  reg_val);
 
 		/* CL73 Autoneg Enabled */
 		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
@@ -2033,36 +2007,36 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 		reg_val = 0;
 
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_CL73_IEEEB0,
-			      MDIO_CL73_IEEEB0_CL73_AN_CONTROL, reg_val);
+			  MDIO_REG_BANK_CL73_IEEEB0,
+			  MDIO_CL73_IEEEB0_CL73_AN_CONTROL, reg_val);
 }
 
 /* program SerDes, forced speed */
 static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 				 struct link_params *params,
-			       struct link_vars *vars)
+				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
 
 	/* program duplex, disable autoneg and sgmii*/
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
 	reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX |
 		     MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
 		     MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK);
 	if (phy->req_duplex == DUPLEX_FULL)
 		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_MII_CONTROL, reg_val);
 
 	/* program speed
 	   - needed only if the speed is greater than 1G (2.5G or 10G) */
 	CL45_RD_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_SERDES_DIGITAL,
-				      MDIO_SERDES_DIGITAL_MISC1, &reg_val);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_MISC1, &reg_val);
 	/* clearing the speed value before setting the right speed */
 	DP(NETIF_MSG_LINK, "MDIO_REG_BANK_SERDES_DIGITAL = 0x%x\n", reg_val);
 
@@ -2084,8 +2058,8 @@ static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 	}
 
 	CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_SERDES_DIGITAL,
-				      MDIO_SERDES_DIGITAL_MISC1, reg_val);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_MISC1, reg_val);
 
 }
 
@@ -2103,12 +2077,12 @@ static void bnx2x_set_brcm_cl37_advertisment(struct bnx2x_phy *phy,
 	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
 		val |= MDIO_OVER_1G_UP1_10G;
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_OVER_1G,
-			      MDIO_OVER_1G_UP1, val);
+			  MDIO_REG_BANK_OVER_1G,
+			  MDIO_OVER_1G_UP1, val);
 
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_OVER_1G,
-			      MDIO_OVER_1G_UP3, 0x400);
+			  MDIO_REG_BANK_OVER_1G,
+			  MDIO_OVER_1G_UP3, 0x400);
 }
 
 static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
@@ -2121,17 +2095,14 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 
 	switch (phy->req_flow_ctrl) {
 	case BNX2X_FLOW_CTRL_AUTO:
-		if (params->req_fc_auto_adv == BNX2X_FLOW_CTRL_BOTH) {
-			*ieee_fc |=
-			     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-		} else {
+		if (params->req_fc_auto_adv == BNX2X_FLOW_CTRL_BOTH)
+			*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+		else
 			*ieee_fc |=
-		       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-		}
+			MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
 		break;
 	case BNX2X_FLOW_CTRL_TX:
-		*ieee_fc |=
-		       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+		*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
 		break;
 
 	case BNX2X_FLOW_CTRL_RX:
@@ -2149,23 +2120,23 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 
 static void bnx2x_set_ieee_aneg_advertisment(struct bnx2x_phy *phy,
 					     struct link_params *params,
-					   u16 ieee_fc)
+					     u16 ieee_fc)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val;
 	/* for AN, we are always publishing full duplex */
 
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, ieee_fc);
+			  MDIO_REG_BANK_COMBO_IEEE0,
+			  MDIO_COMBO_IEEE0_AUTO_NEG_ADV, ieee_fc);
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_CL73_IEEEB1,
-			      MDIO_CL73_IEEEB1_AN_ADV1, &val);
+			  MDIO_REG_BANK_CL73_IEEEB1,
+			  MDIO_CL73_IEEEB1_AN_ADV1, &val);
 	val &= ~MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_BOTH;
 	val |= ((ieee_fc<<3) & MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_MASK);
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_CL73_IEEEB1,
-			      MDIO_CL73_IEEEB1_AN_ADV1, val);
+			  MDIO_REG_BANK_CL73_IEEEB1,
+			  MDIO_CL73_IEEEB1_AN_ADV1, val);
 }
 
 static void bnx2x_restart_autoneg(struct bnx2x_phy *phy,
@@ -2180,37 +2151,37 @@ static void bnx2x_restart_autoneg(struct bnx2x_phy *phy,
 
 	if (enable_cl73) {
 		CL45_RD_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_CL73_IEEEB0,
-				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				      &mii_control);
+				  MDIO_REG_BANK_CL73_IEEEB0,
+				  MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+				  &mii_control);
 
 		CL45_WR_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_CL73_IEEEB0,
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				(mii_control |
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN |
-				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN));
+				  MDIO_REG_BANK_CL73_IEEEB0,
+				  MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+				  (mii_control |
+				  MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN |
+				  MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN));
 	} else {
 
 		CL45_RD_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      &mii_control);
+				  MDIO_REG_BANK_COMBO_IEEE0,
+				  MDIO_COMBO_IEEE0_MII_CONTROL,
+				  &mii_control);
 		DP(NETIF_MSG_LINK,
 			 "bnx2x_restart_autoneg mii_control before = 0x%x\n",
 			 mii_control);
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      (mii_control |
-				       MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
-				       MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
+				  MDIO_REG_BANK_COMBO_IEEE0,
+				  MDIO_COMBO_IEEE0_MII_CONTROL,
+				  (mii_control |
+				   MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
+				   MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
 	}
 }
 
 static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 					   struct link_params *params,
-					 struct link_vars *vars)
+					   struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 control1;
@@ -2218,18 +2189,18 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 	/* in SGMII mode, the unicore is always slave */
 
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
-		      &control1);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
+			  &control1);
 	control1 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT;
 	/* set sgmii mode (and not fiber) */
 	control1 &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE |
 		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET |
 		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_MSTR_MODE);
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
-			      control1);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
+			  control1);
 
 	/* if forced speed */
 	if (!(vars->line_speed == SPEED_AUTO_NEG)) {
@@ -2237,9 +2208,9 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 		u16 mii_control;
 
 		CL45_RD_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      &mii_control);
+				  MDIO_REG_BANK_COMBO_IEEE0,
+				  MDIO_COMBO_IEEE0_MII_CONTROL,
+				  &mii_control);
 		mii_control &= ~(MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
 				 MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK|
 				 MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX);
@@ -2268,9 +2239,9 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 			mii_control |=
 				MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_MII_CONTROL,
-				      mii_control);
+				  MDIO_REG_BANK_COMBO_IEEE0,
+				  MDIO_COMBO_IEEE0_MII_CONTROL,
+				  mii_control);
 
 	} else { /* AN mode */
 		/* enable and restart AN */
@@ -2285,19 +2256,19 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 
 static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 {						/*  LD	    LP	 */
-	switch (pause_result) { 		/* ASYM P ASYM P */
-	case 0xb:       			/*   1  0   1  1 */
+	switch (pause_result) {			/* ASYM P ASYM P */
+	case 0xb:				/*   1  0   1  1 */
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_TX;
 		break;
 
-	case 0xe:       			/*   1  1   1  0 */
+	case 0xe:				/*   1  1   1  0 */
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_RX;
 		break;
 
-	case 0x5:       			/*   0  1   0  1 */
-	case 0x7:       			/*   0  1   1  1 */
-	case 0xd:       			/*   1  1   0  1 */
-	case 0xf:       			/*   1  1   1  1 */
+	case 0x5:				/*   0  1   0  1 */
+	case 0x7:				/*   0  1   1  1 */
+	case 0xd:				/*   1  1   0  1 */
+	case 0xf:				/*   1  1   1  1 */
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_BOTH;
 		break;
 
@@ -2318,13 +2289,13 @@ static u8 bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
 	if (phy->req_line_speed != SPEED_AUTO_NEG)
 		return 0;
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
-			      &status2_1000x);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
+			  &status2_1000x);
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_SERDES_DIGITAL,
-			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
-			      &status2_1000x);
+			  MDIO_REG_BANK_SERDES_DIGITAL,
+			  MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
+			  &status2_1000x);
 	if (status2_1000x & MDIO_SERDES_DIGITAL_A_1000X_STATUS2_AN_DISABLED) {
 		DP(NETIF_MSG_LINK, "1G parallel detect link on port %d\n",
 			 params->port);
@@ -2332,9 +2303,9 @@ static u8 bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
 	}
 
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_10G_PARALLEL_DETECT,
-			      MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS,
-			      &pd_10g);
+			  MDIO_REG_BANK_10G_PARALLEL_DETECT,
+			  MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS,
+			  &pd_10g);
 
 	if (pd_10g & MDIO_10G_PARALLEL_DETECT_PAR_DET_10G_STATUS_PD_LINK) {
 		DP(NETIF_MSG_LINK, "10G parallel detect link on port %d\n",
@@ -2374,13 +2345,13 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x_phy *phy,
 		     MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE)) {
 
 			CL45_RD_OVER_CL22(bp, phy,
-					      MDIO_REG_BANK_CL73_IEEEB1,
-					      MDIO_CL73_IEEEB1_AN_ADV1,
-					      &ld_pause);
+					  MDIO_REG_BANK_CL73_IEEEB1,
+					  MDIO_CL73_IEEEB1_AN_ADV1,
+					  &ld_pause);
 			CL45_RD_OVER_CL22(bp, phy,
-					     MDIO_REG_BANK_CL73_IEEEB1,
-					     MDIO_CL73_IEEEB1_AN_LP_ADV1,
-					     &lp_pause);
+					  MDIO_REG_BANK_CL73_IEEEB1,
+					  MDIO_CL73_IEEEB1_AN_LP_ADV1,
+					  &lp_pause);
 			pause_result = (ld_pause &
 					MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_MASK)
 					>> 8;
@@ -2391,17 +2362,17 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x_phy *phy,
 				 pause_result);
 		} else {
 			CL45_RD_OVER_CL22(bp, phy,
-					      MDIO_REG_BANK_COMBO_IEEE0,
-					      MDIO_COMBO_IEEE0_AUTO_NEG_ADV,
-					      &ld_pause);
+					  MDIO_REG_BANK_COMBO_IEEE0,
+					  MDIO_COMBO_IEEE0_AUTO_NEG_ADV,
+					  &ld_pause);
 			CL45_RD_OVER_CL22(bp, phy,
-			       MDIO_REG_BANK_COMBO_IEEE0,
-			       MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1,
-			       &lp_pause);
+				MDIO_REG_BANK_COMBO_IEEE0,
+				MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1,
+				&lp_pause);
 			pause_result = (ld_pause &
 				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>5;
 			pause_result |= (lp_pause &
-				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>7;
+				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>7;
 			DP(NETIF_MSG_LINK, "pause_result CL37 0x%x\n",
 				 pause_result);
 		}
@@ -2418,24 +2389,24 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "bnx2x_check_fallback_to_cl37\n");
 	/* Step 1: Make sure signal is detected */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_RX0,
-			      MDIO_RX0_RX_STATUS,
-			      &rx_status);
+			  MDIO_REG_BANK_RX0,
+			  MDIO_RX0_RX_STATUS,
+			  &rx_status);
 	if ((rx_status & MDIO_RX0_RX_STATUS_SIGDET) !=
 	    (MDIO_RX0_RX_STATUS_SIGDET)) {
 		DP(NETIF_MSG_LINK, "Signal is not detected. Restoring CL73."
 			     "rx_status(0x80b0) = 0x%x\n", rx_status);
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_CL73_IEEEB0,
-				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN);
+				  MDIO_REG_BANK_CL73_IEEEB0,
+				  MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+				  MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN);
 		return;
 	}
 	/* Step 2: Check CL73 state machine */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_CL73_USERB0,
-			      MDIO_CL73_USERB0_CL73_USTAT1,
-			      &ustat_val);
+			  MDIO_REG_BANK_CL73_USERB0,
+			  MDIO_CL73_USERB0_CL73_USTAT1,
+			  &ustat_val);
 	if ((ustat_val &
 	     (MDIO_CL73_USERB0_CL73_USTAT1_LINK_STATUS_CHECK |
 	      MDIO_CL73_USERB0_CL73_USTAT1_AN_GOOD_CHECK_BAM37)) !=
@@ -2448,9 +2419,9 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 	/* Step 3: Check CL37 Message Pages received to indicate LP
 	supports only CL37 */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_REMOTE_PHY,
-			      MDIO_REMOTE_PHY_MISC_RX_STATUS,
-			      &cl37_fsm_recieved);
+			  MDIO_REG_BANK_REMOTE_PHY,
+			  MDIO_REMOTE_PHY_MISC_RX_STATUS,
+			  &cl37_fsm_recieved);
 	if ((cl37_fsm_recieved &
 	     (MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_OVER1G_MSG |
 	     MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_BRCM_OUI_MSG)) !=
@@ -2466,9 +2437,9 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 	cl37 BAM. In this case we disable cl73 and restart cl37 auto-neg */
 	/* Disable CL73 */
 	CL45_WR_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_CL73_IEEEB0,
-			      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
-			      0);
+			  MDIO_REG_BANK_CL73_IEEEB0,
+			  MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+			  0);
 	/* Restart CL37 autoneg */
 	bnx2x_restart_autoneg(phy, params, 0);
 	DP(NETIF_MSG_LINK, "Disabling CL73, and restarting CL37 autoneg\n");
@@ -2493,14 +2464,14 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 new_line_speed , gp_status;
+	u16 new_line_speed, gp_status;
 	u8 rc = 0;
 
 	/* Read gp_status */
 	CL45_RD_OVER_CL22(bp, phy,
-				MDIO_REG_BANK_GP_STATUS,
-				MDIO_GP_STATUS_TOP_AN_STATUS1,
-				&gp_status);
+			  MDIO_REG_BANK_GP_STATUS,
+			  MDIO_GP_STATUS_TOP_AN_STATUS1,
+			  &gp_status);
 
 	if (phy->req_line_speed == SPEED_AUTO_NEG)
 		vars->link_status |= LINK_STATUS_AUTO_NEGOTIATE_ENABLED;
@@ -2638,8 +2609,8 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 
 	/* read precomp */
 	CL45_RD_OVER_CL22(bp, phy,
-			      MDIO_REG_BANK_OVER_1G,
-			      MDIO_OVER_1G_LP_UP2, &lp_up2);
+			  MDIO_REG_BANK_OVER_1G,
+			  MDIO_OVER_1G_LP_UP2, &lp_up2);
 
 	/* bits [10:7] at lp_up2, positioned at [15:12] */
 	lp_up2 = (((lp_up2 & MDIO_OVER_1G_LP_UP2_PREEMPHASIS_MASK) >>
@@ -2652,8 +2623,8 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 	for (bank = MDIO_REG_BANK_TX0; bank <= MDIO_REG_BANK_TX3;
 	      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0)) {
 		CL45_RD_OVER_CL22(bp, phy,
-				      bank,
-				      MDIO_TX0_TX_DRIVER, &tx_driver);
+				  bank,
+				  MDIO_TX0_TX_DRIVER, &tx_driver);
 
 		/* replace tx_driver bits [15:12] */
 		if (lp_up2 !=
@@ -2661,8 +2632,8 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 			tx_driver &= ~MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK;
 			tx_driver |= lp_up2;
 			CL45_WR_OVER_CL22(bp, phy,
-					      bank,
-					      MDIO_TX0_TX_DRIVER, tx_driver);
+					  bank,
+					  MDIO_TX0_TX_DRIVER, tx_driver);
 		}
 	}
 }
@@ -2676,10 +2647,10 @@ static u8 bnx2x_emac_program(struct link_params *params,
 
 	DP(NETIF_MSG_LINK, "setting link speed & duplex\n");
 	bnx2x_bits_dis(bp, GRCBASE_EMAC0 + port*0x400 +
-		     EMAC_REG_EMAC_MODE,
-		     (EMAC_MODE_25G_MODE |
-		     EMAC_MODE_PORT_MII_10M |
-		     EMAC_MODE_HALF_DUPLEX));
+		       EMAC_REG_EMAC_MODE,
+		       (EMAC_MODE_25G_MODE |
+			EMAC_MODE_PORT_MII_10M |
+			EMAC_MODE_HALF_DUPLEX));
 	switch (vars->line_speed) {
 	case SPEED_10:
 		mode |= EMAC_MODE_PORT_MII_10M;
@@ -2707,8 +2678,8 @@ static u8 bnx2x_emac_program(struct link_params *params,
 	if (vars->duplex == DUPLEX_HALF)
 		mode |= EMAC_MODE_HALF_DUPLEX;
 	bnx2x_bits_en(bp,
-		    GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
-		    mode);
+		      GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
+		      mode);
 
 	bnx2x_set_led(params, vars, LED_MODE_OPER, vars->line_speed);
 	return 0;
@@ -2754,7 +2725,7 @@ static void bnx2x_init_internal_phy(struct bnx2x_phy *phy,
 		/* forced speed requested? */
 		if (vars->line_speed != SPEED_AUTO_NEG ||
 		    (SINGLE_MEDIA_DIRECT(params) &&
-			  params->loopback_mode == LOOPBACK_EXT)) {
+		     params->loopback_mode == LOOPBACK_EXT)) {
 			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
 
 			/* disable autoneg */
@@ -2771,7 +2742,7 @@ static void bnx2x_init_internal_phy(struct bnx2x_phy *phy,
 
 			/* program duplex & pause advertisement (for aneg) */
 			bnx2x_set_ieee_aneg_advertisment(phy, params,
-						       vars->ieee_fc);
+							 vars->ieee_fc);
 
 			/* enable autoneg */
 			bnx2x_set_autoneg(phy, params, vars, enable_cl73);
@@ -2933,13 +2904,13 @@ static void bnx2x_rearm_latch_signal(struct bnx2x *bp, u8 port,
 
 		/* For all latched-signal=up : Re-Arm Latch signals */
 		REG_WR(bp, NIG_REG_LATCH_STATUS_0 + port*8,
-			     (latch_status & 0xfffe) | (latch_status & 1));
+		       (latch_status & 0xfffe) | (latch_status & 1));
 	}
 	/* For all latched-signal=up,Write original_signal to status */
 }
 
 static void bnx2x_link_int_ack(struct link_params *params,
-			     struct link_vars *vars, u8 is_10g)
+			       struct link_vars *vars, u8 is_10g)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -2947,9 +2918,9 @@ static void bnx2x_link_int_ack(struct link_params *params,
 	/* first reset all status
 	 * we assume only one line will be change at a time */
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		     (NIG_STATUS_XGXS0_LINK10G |
-		      NIG_STATUS_XGXS0_LINK_STATUS |
-		      NIG_STATUS_SERDES0_LINK_STATUS));
+		       (NIG_STATUS_XGXS0_LINK10G |
+			NIG_STATUS_XGXS0_LINK_STATUS |
+			NIG_STATUS_SERDES0_LINK_STATUS));
 	if (vars->phy_link_up) {
 		if (is_10g) {
 			/* Disable the 10G link interrupt
@@ -3059,8 +3030,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	}
 	if ((params->num_phys == MAX_PHYS) &&
 	    (params->phy[EXT_PHY2].ver_addr != 0)) {
-		spirom_ver = REG_RD(bp,
-					  params->phy[EXT_PHY2].ver_addr);
+		spirom_ver = REG_RD(bp, params->phy[EXT_PHY2].ver_addr);
 		if (params->phy[EXT_PHY2].format_fw_ver) {
 			*ver_p = '/';
 			ver_p++;
@@ -3089,29 +3059,27 @@ static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
 
 		/* change the uni_phy_addr in the nig */
 		md_devad = REG_RD(bp, (NIG_REG_XGXS0_CTRL_MD_DEVAD +
-					  port*0x18));
+				       port*0x18));
 
 		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, 0x5);
 
 		bnx2x_cl45_write(bp, phy,
-			       5,
-			       (MDIO_REG_BANK_AER_BLOCK +
-				(MDIO_AER_BLOCK_AER_REG & 0xf)),
-			       0x2800);
+				 5,
+				 (MDIO_REG_BANK_AER_BLOCK +
+				  (MDIO_AER_BLOCK_AER_REG & 0xf)),
+				 0x2800);
 
 		bnx2x_cl45_write(bp, phy,
-			       5,
-			       (MDIO_REG_BANK_CL73_IEEEB0 +
-				(MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
-			       0x6041);
+				 5,
+				 (MDIO_REG_BANK_CL73_IEEEB0 +
+				  (MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
+				 0x6041);
 		msleep(200);
 		/* set aer mmd back */
 		bnx2x_set_aer_mmd_xgxs(params, phy);
 
 		/* and md_devad */
-		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
-			    md_devad);
-
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, md_devad);
 	} else {
 		u16 mii_ctrl;
 		DP(NETIF_MSG_LINK, "XGXS 1G loopback enable\n");
@@ -3152,7 +3120,7 @@ u8 bnx2x_set_led(struct link_params *params,
 	case LED_MODE_OFF:
 		REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 0);
 		REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
-			   SHARED_HW_CFG_LED_MAC1);
+		       SHARED_HW_CFG_LED_MAC1);
 
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
 		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
@@ -3190,20 +3158,17 @@ u8 bnx2x_set_led(struct link_params *params,
 			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
 			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
 		} else {
-			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
-				   hw_led_mode);
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, hw_led_mode);
 		}
 
-		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 +
-			   port*4, 0);
+		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 + port*4, 0);
 		/* Set blinking rate to ~15.9Hz */
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
-			   LED_BLINK_RATE_VAL);
+		       LED_BLINK_RATE_VAL);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
-			   port*4, 1);
+		       port*4, 1);
 		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(bp, EMAC_REG_EMAC_LED,
-			    (tmp & (~EMAC_LED_OVERRIDE)));
+		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp & (~EMAC_LED_OVERRIDE)));
 
 		if (CHIP_IS_E1(bp) &&
 		    ((speed == SPEED_2500) ||
@@ -3213,11 +3178,11 @@ u8 bnx2x_set_led(struct link_params *params,
 			/* On Everest 1 Ax chip versions for speeds less than
 			10G LED scheme is different */
 			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
-				   + port*4, 1);
+			       + port*4, 1);
 			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 +
-				   port*4, 0);
+			       port*4, 0);
 			REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_TRAFFIC_P0 +
-				   port*4, 1);
+			       port*4, 1);
 		}
 		break;
 
@@ -3244,9 +3209,9 @@ u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars,
 	struct link_vars temp_vars;
 
 	CL45_RD_OVER_CL22(bp, &params->phy[INT_PHY],
-			      MDIO_REG_BANK_GP_STATUS,
-			      MDIO_GP_STATUS_TOP_AN_STATUS1,
-			      &gp_status);
+			  MDIO_REG_BANK_GP_STATUS,
+			  MDIO_GP_STATUS_TOP_AN_STATUS1,
+			  &gp_status);
 	/* link is up only if both local phy and external phy are up */
 	if (!(gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS))
 		return -ESRCH;
@@ -3358,9 +3323,8 @@ static void bnx2x_int_link_reset(struct bnx2x_phy *phy,
 				 struct link_params *params)
 {
 	/* reset the SerDes/XGXS */
-	REG_WR(params->bp, GRCBASE_MISC +
-		     MISC_REGISTERS_RESET_REG_3_CLEAR,
-		     (0x1ff << (params->port*16)));
+	REG_WR(params->bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR,
+	       (0x1ff << (params->port*16)));
 }
 
 static void bnx2x_common_ext_link_reset(struct bnx2x_phy *phy,
@@ -3374,11 +3338,11 @@ static void bnx2x_common_ext_link_reset(struct bnx2x_phy *phy,
 	else
 		gpio_port = params->port;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    gpio_port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW,
+		       gpio_port);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    gpio_port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW,
+		       gpio_port);
 	DP(NETIF_MSG_LINK, "reset external PHY\n");
 }
 
@@ -3409,9 +3373,8 @@ static u8 bnx2x_update_link_down(struct link_params *params,
 
 	/* reset BigMac */
 	bnx2x_bmac_rx_disable(bp, params->port);
-	REG_WR(bp, GRCBASE_MISC +
-		   MISC_REGISTERS_RESET_REG_2_CLEAR,
-		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 	return 0;
 }
 
@@ -3501,12 +3464,11 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
 
 	is_mi_int = (u8)(REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT +
-				    port*0x18) > 0);
+				port*0x18) > 0);
 	DP(NETIF_MSG_LINK, "int_mask 0x%x MI_INT %x, SERDES_LINK %x\n",
 		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
 		 is_mi_int,
-		 REG_RD(bp,
-			    NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c));
+		 REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c));
 
 	DP(NETIF_MSG_LINK, " 10G %x, XGXS_LINK %x\n",
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
@@ -3658,8 +3620,8 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 				   ext_phy_line_speed);
 			vars->phy_link_up = 0;
 		} else if (prev_line_speed != vars->line_speed) {
-			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
-				     + params->port*4, 0);
+			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4,
+			       0);
 			msleep(1);
 		}
 	}
@@ -3724,10 +3686,10 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 {
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 	msleep(1);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
 
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
@@ -3747,9 +3709,9 @@ static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp,
 	u16 fw_ver1, fw_ver2;
 
 	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
+			MDIO_PMA_REG_ROM_VER1, &fw_ver1);
 	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER2, &fw_ver2);
+			MDIO_PMA_REG_ROM_VER2, &fw_ver2);
 	bnx2x_save_spirom_version(bp, port, (u32)(fw_ver1<<16 | fw_ver2),
 				  phy->ver_addr);
 }
@@ -3770,7 +3732,7 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 	if ((vars->ieee_fc &
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
-		val |=  MDIO_AN_REG_ADV_PAUSE_ASYMMETRIC;
+		val |= MDIO_AN_REG_ADV_PAUSE_ASYMMETRIC;
 	}
 	if ((vars->ieee_fc &
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
@@ -3801,11 +3763,11 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 	else if (vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
 		ret = 1;
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_AN_DEVAD,
-			      MDIO_AN_REG_ADV_PAUSE, &ld_pause);
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_ADV_PAUSE, &ld_pause);
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_AN_DEVAD,
-			      MDIO_AN_REG_LP_AUTO_NEG, &lp_pause);
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_LP_AUTO_NEG, &lp_pause);
 		pause_result = (ld_pause &
 				MDIO_AN_REG_ADV_PAUSE_MASK) >> 8;
 		pause_result |= (lp_pause &
@@ -3881,31 +3843,31 @@ static u8 bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 	/* Boot port from external ROM  */
 	/* EDC grst */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       0x0001);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL,
+			 0x0001);
 
 	/* ucode reboot and rst */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       0x008c);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL,
+			 0x008c);
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_MISC_CTRL1, 0x0001);
 
 	/* Reset internal microprocessor */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL,
+			 MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 
 	/* Release srst bit */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL,
+			 MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 
 	/* Delay 100ms per the PHY specifications */
 	msleep(100);
@@ -3936,8 +3898,8 @@ static u8 bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 
 	/* Clear ser_boot_ctl bit */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 	bnx2x_save_bcm_spirom_ver(bp, phy, port);
 
 	DP(NETIF_MSG_LINK,
@@ -4000,8 +3962,8 @@ static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
 
 	/* Read 8073 HW revision*/
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_8073_CHIP_REV, &val);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8073_CHIP_REV, &val);
 
 	if (val != 1) {
 		/* No need to workaround in 8073 A1 */
@@ -4009,8 +3971,8 @@ static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
 	}
 
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER2, &val);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_ROM_VER2, &val);
 
 	/* SNR should be applied only for version 0x102 */
 	if (val != 0x102)
@@ -4024,8 +3986,8 @@ static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 	u16 val, cnt, cnt1 ;
 
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_8073_CHIP_REV, &val);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8073_CHIP_REV, &val);
 
 	if (val > 0) {
 		/* No need to workaround in 8073 A1 */
@@ -4038,9 +4000,9 @@ static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 
 	for (cnt = 0; cnt < 1000; cnt++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
-			      &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
+				&val);
 		  /* If bit [14] = 0 or bit [13] = 0, continue on with
 		   system initialization (XAUI work-around not required,
 		    as these bits indicate 2.5G or 1G link up). */
@@ -4135,10 +4097,10 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 		gpio_port = params->port;
 	/* Restore normal power mode*/
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
 	/* enable LASI */
 	bnx2x_cl45_write(bp, phy,
@@ -4425,8 +4387,8 @@ static void bnx2x_8073_link_reset(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "Setting 8073 port %d into low power mode\n",
 	   gpio_port);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    gpio_port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW,
+		       gpio_port);
 }
 
 /******************************************************************/
@@ -4440,7 +4402,7 @@ static u8 bnx2x_8705_config_init(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "init 8705\n");
 	/* Restore normal power mode*/
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
@@ -4523,7 +4485,7 @@ static void bnx2x_sfp_set_transmitter(struct bnx2x *bp,
 
 static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 					    struct link_params *params,
-					  u16 addr, u8 byte_cnt, u8 *o_buf)
+					    u16 addr, u8 byte_cnt, u8 *o_buf)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
@@ -4536,23 +4498,23 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* Set the read command byte count */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
-		       (byte_cnt | 0xa000));
+			 (byte_cnt | 0xa000));
 
 	/* Set the read command address */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_MEM_ADDR,
-		       addr);
+			 addr);
 
 	/* Activate read command */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
-		       0x2c0f);
+			 0x2c0f);
 
 	/* Wait up to 500us for command complete status */
 	for (i = 0; i < 100; i++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_COMPLETE)
 			break;
@@ -4570,15 +4532,15 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* Read the buffer */
 	for (i = 0; i < byte_cnt; i++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_8726_TWO_WIRE_DATA_BUF + i, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_8726_TWO_WIRE_DATA_BUF + i, &val);
 		o_buf[i] = (u8)(val & MDIO_PMA_REG_8726_TWO_WIRE_DATA_MASK);
 	}
 
 	for (i = 0; i < 100; i++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_IDLE)
 			return 0;
@@ -4589,7 +4551,7 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 
 static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 					    struct link_params *params,
-					  u16 addr, u8 byte_cnt, u8 *o_buf)
+					    u16 addr, u8 byte_cnt, u8 *o_buf)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val, i;
@@ -4602,32 +4564,32 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 
 	/* Need to read from 1.8000 to clear it */
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
-		      &val);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
+			&val);
 
 	/* Set the read command byte count */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
-		       ((byte_cnt < 2) ? 2 : byte_cnt));
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_SFP_TWO_WIRE_BYTE_CNT,
+			 ((byte_cnt < 2) ? 2 : byte_cnt));
 
 	/* Set the read command address */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_SFP_TWO_WIRE_MEM_ADDR,
-		       addr);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_SFP_TWO_WIRE_MEM_ADDR,
+			 addr);
 	/* Set the destination address */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       0x8004,
-		       MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF);
+			 MDIO_PMA_DEVAD,
+			 0x8004,
+			 MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF);
 
 	/* Activate read command */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
-		       0x8002);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_SFP_TWO_WIRE_CTRL,
+			 0x8002);
 	/* Wait appropriate time for two-wire command to finish before
 	polling the status register */
 	msleep(1);
@@ -4635,8 +4597,8 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* Wait up to 500us for command complete status */
 	for (i = 0; i < 100; i++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_COMPLETE)
 			break;
@@ -4654,15 +4616,15 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* Read the buffer */
 	for (i = 0; i < byte_cnt; i++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF + i, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_8727_TWO_WIRE_DATA_BUF + i, &val);
 		o_buf[i] = (u8)(val & MDIO_PMA_REG_8727_TWO_WIRE_DATA_MASK);
 	}
 
 	for (i = 0; i < 100; i++) {
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_IDLE)
 			return 0;
@@ -4672,22 +4634,22 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	return -EINVAL;
 }
 
-static u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
-				       struct link_params *params, u16 addr,
-				       u8 byte_cnt, u8 *o_buf)
+u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+				struct link_params *params, u16 addr,
+				u8 byte_cnt, u8 *o_buf)
 {
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726)
 		return bnx2x_8726_read_sfp_module_eeprom(phy, params, addr,
-						       byte_cnt, o_buf);
+							 byte_cnt, o_buf);
 	else if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727)
 		return bnx2x_8727_read_sfp_module_eeprom(phy, params, addr,
-						       byte_cnt, o_buf);
+							 byte_cnt, o_buf);
 	return -EINVAL;
 }
 
 static u8 bnx2x_get_edc_mode(struct bnx2x_phy *phy,
 			     struct link_params *params,
-				  u16 *edc_mode)
+			     u16 *edc_mode)
 {
 	struct bnx2x *bp = params->bp;
 	u8 val, check_limiting_mode = 0;
@@ -4818,17 +4780,17 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	/* format the warning message */
 	if (bnx2x_read_sfp_module_eeprom(phy,
 					 params,
-				       SFP_EEPROM_VENDOR_NAME_ADDR,
-				       SFP_EEPROM_VENDOR_NAME_SIZE,
-				       (u8 *)vendor_name))
+					 SFP_EEPROM_VENDOR_NAME_ADDR,
+					 SFP_EEPROM_VENDOR_NAME_SIZE,
+					 (u8 *)vendor_name))
 		vendor_name[0] = '\0';
 	else
 		vendor_name[SFP_EEPROM_VENDOR_NAME_SIZE] = '\0';
 	if (bnx2x_read_sfp_module_eeprom(phy,
 					 params,
-				       SFP_EEPROM_PART_NO_ADDR,
-				       SFP_EEPROM_PART_NO_SIZE,
-				       (u8 *)vendor_pn))
+					 SFP_EEPROM_PART_NO_ADDR,
+					 SFP_EEPROM_PART_NO_SIZE,
+					 (u8 *)vendor_pn))
 		vendor_pn[0] = '\0';
 	else
 		vendor_pn[SFP_EEPROM_PART_NO_SIZE] = '\0';
@@ -4905,15 +4867,14 @@ static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 	u16 cur_limiting_mode;
 
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER2,
-		      &cur_limiting_mode);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_ROM_VER2,
+			&cur_limiting_mode);
 	DP(NETIF_MSG_LINK, "Current Limiting mode is 0x%x\n",
 		 cur_limiting_mode);
 
 	if (edc_mode == EDC_MODE_LIMITING) {
-		DP(NETIF_MSG_LINK,
-			 "Setting LIMITING MODE\n");
+		DP(NETIF_MSG_LINK, "Setting LIMITING MODE\n");
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_PMA_DEVAD,
 				 MDIO_PMA_REG_ROM_VER2,
@@ -4929,55 +4890,55 @@ static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 			return 0;
 
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_LRM_MODE,
-			       0);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_LRM_MODE,
+				 0);
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_ROM_VER2,
-			       0x128);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_ROM_VER2,
+				 0x128);
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_MISC_CTRL0,
-			       0x4008);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_MISC_CTRL0,
+				 0x4008);
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_LRM_MODE,
-			       0xaaaa);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_LRM_MODE,
+				 0xaaaa);
 	}
 	return 0;
 }
 
 static u8 bnx2x_8727_set_limiting_mode(struct bnx2x *bp,
 				       struct bnx2x_phy *phy,
-					u16 edc_mode)
+				       u16 edc_mode)
 {
 	u16 phy_identifier;
 	u16 rom_ver2_val;
 	bnx2x_cl45_read(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_PHY_IDENTIFIER,
-		       &phy_identifier);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_PHY_IDENTIFIER,
+			&phy_identifier);
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_PHY_IDENTIFIER,
-		       (phy_identifier & ~(1<<9)));
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_PHY_IDENTIFIER,
+			 (phy_identifier & ~(1<<9)));
 
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_ROM_VER2,
-		      &rom_ver2_val);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_ROM_VER2,
+			&rom_ver2_val);
 	/* Keep the MSB 8-bits, and set the LSB 8-bits with the edc_mode */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_ROM_VER2,
-		       (rom_ver2_val & 0xff00) | (edc_mode & 0x00ff));
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_ROM_VER2,
+			 (rom_ver2_val & 0xff00) | (edc_mode & 0x00ff));
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_PHY_IDENTIFIER,
-		       (phy_identifier | (1<<9)));
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_PHY_IDENTIFIER,
+			 (phy_identifier | (1<<9)));
 
 	return 0;
 }
@@ -5020,8 +4981,7 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 	if (bnx2x_get_edc_mode(phy, params, &edc_mode) != 0) {
 		DP(NETIF_MSG_LINK, "Failed to get valid module type\n");
 		return -EINVAL;
-	} else if (bnx2x_verify_sfp_module(phy, params) !=
-		   0) {
+	} else if (bnx2x_verify_sfp_module(phy, params) != 0) {
 		/* check SFP+ module compatibility */
 		DP(NETIF_MSG_LINK, "Module verification failed!!\n");
 		rc = -EINVAL;
@@ -5097,9 +5057,9 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 			DP(NETIF_MSG_LINK, "SFP+ module is not initialized\n");
 	} else {
 		u32 val = REG_RD(bp, params->shmem_base +
-				     offsetof(struct shmem_region, dev_info.
-					      port_feature_config[params->port].
-					      config));
+				 offsetof(struct shmem_region, dev_info.
+					  port_feature_config[params->port].
+					  config));
 
 		bnx2x_set_gpio_int(bp, MISC_REGISTERS_GPIO_3,
 				   MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
@@ -5170,7 +5130,7 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	u16 cnt, val;
 	struct bnx2x *bp = params->bp;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
@@ -5275,26 +5235,26 @@ static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
 
 	/* Set soft reset */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL,
+			 MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_MISC_CTRL1, 0x0001);
 
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL,
+			 MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 
 	/* wait for 150ms for microcode load */
 	msleep(150);
 
 	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_MISC_CTRL1, 0x0000);
 
 	msleep(200);
 	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
@@ -5411,7 +5371,7 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 
 	/* Set GPIO3 to trigger SFP+ module insertion/removal */
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
-			    MISC_REGISTERS_GPIO_INPUT_HI_Z, params->port);
+		       MISC_REGISTERS_GPIO_INPUT_HI_Z, params->port);
 
 	/* The GPIO should be swapped if the swap register is set and active */
 	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
@@ -5511,7 +5471,7 @@ static void bnx2x_8727_hw_reset(struct bnx2x_phy *phy,
 	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
 	port = (swap_val && swap_override) ^ 1;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 }
 
 static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
@@ -5664,8 +5624,8 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				      port_feature_config[params->port].
 				      config));
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_PHY_IDENTIFIER, &mod_abs);
 	if (mod_abs & (1<<8)) {
 
 		/* Module is absent */
@@ -5682,14 +5642,14 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 		if (!(phy->flags & FLAGS_NOC))
 			mod_abs &= ~(1<<9);
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 
 		/* Clear RX alarm since it stays up as long as
 		the mod_abs wasn't changed */
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_RX_ALARM, &rx_alarm_status);
 
 	} else {
 		/* Module is present */
@@ -6130,7 +6090,7 @@ static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	/* Restore normal power mode*/
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
@@ -6220,8 +6180,8 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 }
 
 static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
-				       struct link_params *params,
-				       struct link_vars *vars)
+				  struct link_params *params,
+				  struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 val, val1, val2;
@@ -6317,9 +6277,9 @@ static void bnx2x_8481_hw_reset(struct bnx2x_phy *phy,
 				struct link_params *params)
 {
 	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 0);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, 0);
 	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 1);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, 1);
 }
 
 static void bnx2x_8481_link_reset(struct bnx2x_phy *phy,
@@ -6341,8 +6301,8 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 	else
 		port = params->port;
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW,
+		       port);
 }
 
 static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
@@ -6397,24 +6357,24 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 
 			/* Set LED masks */
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED1_MASK,
-					0x0);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x0);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED2_MASK,
-					0x0);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED2_MASK,
+					 0x0);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED3_MASK,
-					0x0);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED3_MASK,
+					 0x0);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED5_MASK,
-					0x20);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED5_MASK,
+					 0x20);
 
 		} else {
 			bnx2x_cl45_write(bp, phy,
@@ -6438,35 +6398,35 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 			val |= 0x2492;
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LINK_SIGNAL,
-					val);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LINK_SIGNAL,
+					 val);
 
 			/* Set LED masks */
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED1_MASK,
-					0x0);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x0);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED2_MASK,
-					0x20);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED2_MASK,
+					 0x20);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED3_MASK,
-					0x20);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED3_MASK,
+					 0x20);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED5_MASK,
-					0x0);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED5_MASK,
+					 0x0);
 		} else {
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED1_MASK,
-					0x20);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x20);
 		}
 		break;
 
@@ -6484,8 +6444,8 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 					&val);
 
 			if (!((val &
-			      MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_MASK)
-			   >> MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_SHIFT)){
+			       MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_MASK)
+			  >> MDIO_PMA_REG_8481_LINK_SIGNAL_LED4_ENABLE_SHIFT)) {
 				DP(NETIF_MSG_LINK, "Seting LINK_SIGNAL\n");
 				bnx2x_cl45_write(bp, phy,
 						 MDIO_PMA_DEVAD,
@@ -6495,24 +6455,24 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 
 			/* Set LED masks */
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED1_MASK,
-					0x10);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED1_MASK,
+					 0x10);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED2_MASK,
-					0x80);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED2_MASK,
+					 0x80);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED3_MASK,
-					0x98);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED3_MASK,
+					 0x98);
 
 			bnx2x_cl45_write(bp, phy,
-					MDIO_PMA_DEVAD,
-					MDIO_PMA_REG_8481_LED5_MASK,
-					0x40);
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8481_LED5_MASK,
+					 0x40);
 
 		} else {
 			bnx2x_cl45_write(bp, phy,
@@ -6545,7 +6505,7 @@ static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
 
 	/* Restore normal power mode*/
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_wait_reset_complete(bp, phy);
@@ -6631,20 +6591,20 @@ void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy)
 	u16 val, cnt;
 
 	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_7101_RESET, &val);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_7101_RESET, &val);
 
 	for (cnt = 0; cnt < 10; cnt++) {
 		msleep(50);
 		/* Writes a self-clearing reset */
 		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_7101_RESET,
-			       (val | (1<<15)));
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_7101_RESET,
+				 (val | (1<<15)));
 		/* Wait for clear */
 		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_7101_RESET, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_7101_RESET, &val);
 
 		if ((val & (1<<15)) == 0)
 			break;
@@ -6655,10 +6615,10 @@ static void bnx2x_7101_hw_reset(struct bnx2x_phy *phy,
 				struct link_params *params) {
 	/* Low power mode is controlled by GPIO 2 */
 	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
 	/* The PHY reset is controlled by GPIO 1 */
 	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
+		       MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
 }
 
 static void bnx2x_7101_set_link_led(struct bnx2x_phy *phy,
@@ -6700,9 +6660,9 @@ static struct bnx2x_phy phy_null = {
 	.supported	= 0,
 	.media_type	= ETH_PHY_NOT_PRESENT,
 	.ver_addr	= 0,
-	.req_flow_ctrl  = 0,
-	.req_line_speed = 0,
-	.speed_cap_mask = 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
 	.req_duplex	= 0,
 	.rsrv		= 0,
 	.config_init	= (config_init_t)NULL,
@@ -6737,8 +6697,8 @@ static struct bnx2x_phy phy_serdes = {
 	.media_type	= ETH_PHY_UNSPECIFIED,
 	.ver_addr	= 0,
 	.req_flow_ctrl	= 0,
-	.req_line_speed = 0,
-	.speed_cap_mask = 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
 	.req_duplex	= 0,
 	.rsrv		= 0,
 	.config_init	= (config_init_t)bnx2x_init_serdes,
@@ -6774,8 +6734,8 @@ static struct bnx2x_phy phy_xgxs = {
 	.media_type	= ETH_PHY_UNSPECIFIED,
 	.ver_addr	= 0,
 	.req_flow_ctrl	= 0,
-	.req_line_speed = 0,
-	.speed_cap_mask = 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
 	.req_duplex	= 0,
 	.rsrv		= 0,
 	.config_init	= (config_init_t)bnx2x_init_xgxs,
@@ -6805,8 +6765,8 @@ static struct bnx2x_phy phy_7101 = {
 	.media_type	= ETH_PHY_BASE_T,
 	.ver_addr	= 0,
 	.req_flow_ctrl	= 0,
-	.req_line_speed = 0,
-	.speed_cap_mask = 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
 	.req_duplex	= 0,
 	.rsrv		= 0,
 	.config_init	= (config_init_t)bnx2x_7101_config_init,
@@ -6836,9 +6796,9 @@ static struct bnx2x_phy phy_8073 = {
 			   SUPPORTED_Asym_Pause),
 	.media_type	= ETH_PHY_UNSPECIFIED,
 	.ver_addr	= 0,
-	.req_flow_ctrl  = 0,
-	.req_line_speed = 0,
-	.speed_cap_mask = 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
 	.req_duplex	= 0,
 	.rsrv		= 0,
 	.config_init	= (config_init_t)bnx2x_8073_config_init,
@@ -7068,19 +7028,19 @@ static void bnx2x_populate_preemphasis(struct bnx2x *bp, u32 shmem_base,
 		if (phy_index == INT_PHY || phy_index == EXT_PHY1) {
 			rx = REG_RD(bp, shmem_base +
 				    offsetof(struct shmem_region,
-			   dev_info.port_hw_config[port].xgxs_config_rx[i<<1]));
+			  dev_info.port_hw_config[port].xgxs_config_rx[i<<1]));
 
 			tx = REG_RD(bp, shmem_base +
 				    offsetof(struct shmem_region,
-			   dev_info.port_hw_config[port].xgxs_config_tx[i<<1]));
+			  dev_info.port_hw_config[port].xgxs_config_tx[i<<1]));
 		} else {
 			rx = REG_RD(bp, shmem_base +
 				    offsetof(struct shmem_region,
-			  dev_info.port_hw_config[port].xgxs_config2_rx[i<<1]));
+			 dev_info.port_hw_config[port].xgxs_config2_rx[i<<1]));
 
 			tx = REG_RD(bp, shmem_base +
 				    offsetof(struct shmem_region,
-			  dev_info.port_hw_config[port].xgxs_config2_rx[i<<1]));
+			 dev_info.port_hw_config[port].xgxs_config2_rx[i<<1]));
 		}
 
 		phy->rx_preemphasis[i << 1] = ((rx>>16) & 0xffff);
@@ -7225,10 +7185,10 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 		phy->ver_addr = shmem_base + offsetof(struct shmem_region,
 				port_mb[port].ext_phy_fw_version);
 
-	/* Check specific mdc mdio settings */
-	if (config2 & SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK)
-		mdc_mdio_access = config2 &
-		SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK;
+		/* Check specific mdc mdio settings */
+		if (config2 & SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK)
+			mdc_mdio_access = config2 &
+			SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK;
 	} else {
 		u32 size = REG_RD(bp, shmem2_base);
 
@@ -7282,18 +7242,20 @@ static void bnx2x_phy_def_cfg(struct link_params *params,
 	/* Populate the default phy configuration for MF mode */
 	if (phy_index == EXT_PHY2) {
 		link_config = REG_RD(bp, params->shmem_base +
-					 offsetof(struct shmem_region, dev_info.
+				     offsetof(struct shmem_region, dev_info.
 			port_feature_config[params->port].link_config2));
 		phy->speed_cap_mask = REG_RD(bp, params->shmem_base +
-					offsetof(struct shmem_region, dev_info.
+					     offsetof(struct shmem_region,
+						      dev_info.
 			port_hw_config[params->port].speed_capability_mask2));
 	} else {
 		link_config = REG_RD(bp, params->shmem_base +
-				offsetof(struct shmem_region, dev_info.
+				     offsetof(struct shmem_region, dev_info.
 				port_feature_config[params->port].link_config));
 		phy->speed_cap_mask = REG_RD(bp, params->shmem_base +
-				offsetof(struct shmem_region, dev_info.
-			   port_hw_config[params->port].speed_capability_mask));
+					     offsetof(struct shmem_region,
+						      dev_info.
+			port_hw_config[params->port].speed_capability_mask));
 	}
 	DP(NETIF_MSG_LINK, "Default config phy idx %x cfg 0x%x speed_cap_mask"
 		       " 0x%x\n", phy_index, link_config, phy->speed_cap_mask);
@@ -7440,7 +7402,7 @@ static void set_phy_vars(struct link_params *params)
 			else if (phy_index == EXT_PHY2)
 				actual_phy_idx = EXT_PHY1;
 		}
-		params->phy[actual_phy_idx].req_flow_ctrl  =
+		params->phy[actual_phy_idx].req_flow_ctrl =
 			params->req_flow_ctrl[link_cfg_idx];
 
 		params->phy[actual_phy_idx].req_line_speed =
@@ -7559,8 +7521,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		/* set bmac loopback */
 		bnx2x_bmac_enable(params, vars, 1);
 
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
-		    params->port*4, 0);
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 
 	} else if (params->loopback_mode == LOOPBACK_EMAC) {
 
@@ -7576,8 +7537,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		/* set bmac loopback */
 		bnx2x_emac_enable(params, vars, 1);
 		bnx2x_emac_program(params, vars);
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
-		    params->port*4, 0);
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 
 	} else if ((params->loopback_mode == LOOPBACK_XGXS) ||
 		   (params->loopback_mode == LOOPBACK_EXT_PHY)) {
@@ -7600,8 +7560,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 			bnx2x_emac_program(params, vars);
 			bnx2x_emac_enable(params, vars, 0);
 		} else
-		bnx2x_bmac_enable(params, vars, 0);
-
+			bnx2x_bmac_enable(params, vars, 0);
 		if (params->loopback_mode == LOOPBACK_XGXS) {
 			/* set 10G XGXS loopback */
 			params->phy[INT_PHY].config_loopback(
@@ -7619,9 +7578,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 						params);
 			}
 		}
-
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
-			    params->port*4, 0);
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 
 		bnx2x_set_led(params, vars,
 			      LED_MODE_OPER, vars->line_speed);
@@ -7640,7 +7597,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	return 0;
 }
 u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
-		  u8 reset_ext_phy)
+		    u8 reset_ext_phy)
 {
 	struct bnx2x *bp = params->bp;
 	u8 phy_index, port = params->port, clear_latch_ind = 0;
@@ -7649,10 +7606,10 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	vars->link_status = 0;
 	bnx2x_update_mng(params, vars->link_status);
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-		     (NIG_MASK_XGXS0_LINK_STATUS |
-		      NIG_MASK_XGXS0_LINK10G |
-		      NIG_MASK_SERDES0_LINK_STATUS |
-		      NIG_MASK_MI_INT));
+		       (NIG_MASK_XGXS0_LINK_STATUS |
+			NIG_MASK_XGXS0_LINK10G |
+			NIG_MASK_SERDES0_LINK_STATUS |
+			NIG_MASK_MI_INT));
 
 	/* activate nig drain */
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
@@ -7748,21 +7705,22 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 		/* disable attentions */
 		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 +
 			       port_of_path*4,
-			     (NIG_MASK_XGXS0_LINK_STATUS |
-			      NIG_MASK_XGXS0_LINK10G |
-			      NIG_MASK_SERDES0_LINK_STATUS |
-			      NIG_MASK_MI_INT));
+			       (NIG_MASK_XGXS0_LINK_STATUS |
+				NIG_MASK_XGXS0_LINK10G |
+				NIG_MASK_SERDES0_LINK_STATUS |
+				NIG_MASK_MI_INT));
 
 		/* Need to take the phy out of low power mode in order
 			to write to access its registers */
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				  MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
+			       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+			       port);
 
 		/* Reset the phy */
 		bnx2x_cl45_write(bp, &phy[port],
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_CTRL,
-			       1<<15);
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_CTRL,
+				 1<<15);
 	}
 
 	/* Add delay of 150ms after reset */
@@ -7791,14 +7749,14 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 
 		/* Only set bit 10 = 1 (Tx power down) */
 		bnx2x_cl45_read(bp, phy_blk[port],
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_TX_POWER_DOWN, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_TX_POWER_DOWN, &val);
 
 		/* Phase1 of TX_POWER_DOWN reset */
 		bnx2x_cl45_write(bp, phy_blk[port],
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_TX_POWER_DOWN,
-			       (val | 1<<10));
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_TX_POWER_DOWN,
+				 (val | 1<<10));
 	}
 
 	/* Toggle Transmitter: Power down and then up with 600ms
@@ -7810,25 +7768,25 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp,
 		/* Phase2 of POWER_DOWN_RESET */
 		/* Release bit 10 (Release Tx power down) */
 		bnx2x_cl45_read(bp, phy_blk[port],
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_TX_POWER_DOWN, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_TX_POWER_DOWN, &val);
 
 		bnx2x_cl45_write(bp, phy_blk[port],
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_TX_POWER_DOWN, (val & (~(1<<10))));
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_TX_POWER_DOWN, (val & (~(1<<10))));
 		msleep(15);
 
 		/* Read modify write the SPI-ROM version select register */
 		bnx2x_cl45_read(bp, phy_blk[port],
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_EDC_FFE_MAIN, &val);
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_EDC_FFE_MAIN, &val);
 		bnx2x_cl45_write(bp, phy_blk[port],
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_EDC_FFE_MAIN, (val | (1<<12)));
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_EDC_FFE_MAIN, (val | (1<<12)));
 
 		/* set GPIO2 back to LOW */
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				  MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
+			       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 	}
 	return 0;
 }
@@ -7875,8 +7833,8 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp,
 
 		/* Set fault module detected LED on */
 		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-				  MISC_REGISTERS_GPIO_HIGH,
-				  port);
+			       MISC_REGISTERS_GPIO_HIGH,
+			       port);
 	}
 
 	return 0;
@@ -7891,8 +7849,8 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
 	s8 port_of_path;
-	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
-	swap_override = REG_RD(bp,  NIG_REG_STRAP_OVERRIDE);
+	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
+	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
 
 	port = 1;
 
@@ -7936,9 +7894,7 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
 
 		/* Reset the phy */
 		bnx2x_cl45_write(bp, &phy[port],
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_CTRL,
-			       1<<15);
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	}
 
 	/* Add delay of 150ms after reset */
@@ -7952,7 +7908,7 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	}
 	/* PART2 - Download firmware to both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
-		 if (CHIP_IS_E2(bp))
+		if (CHIP_IS_E2(bp))
 			port_of_path = 0;
 		else
 			port_of_path = port;
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index bedab1a..d9e847b 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -1,4 +1,4 @@
-/* Copyright 2008-2010 Broadcom Corporation
+/* Copyright 2008-2011 Broadcom Corporation
  *
  * Unless you and Broadcom execute a separate written software license
  * agreement governing use of this software, this software is licensed to you
@@ -33,7 +33,7 @@
 #define BNX2X_FLOW_CTRL_BOTH		PORT_FEATURE_FLOW_CONTROL_BOTH
 #define BNX2X_FLOW_CTRL_NONE		PORT_FEATURE_FLOW_CONTROL_NONE
 
-#define SPEED_AUTO_NEG	    0
+#define SPEED_AUTO_NEG		0
 #define SPEED_12000		12000
 #define SPEED_12500		12500
 #define SPEED_13000		13000
@@ -44,8 +44,8 @@
 #define SFP_EEPROM_VENDOR_NAME_SIZE		16
 #define SFP_EEPROM_VENDOR_OUI_ADDR		0x25
 #define SFP_EEPROM_VENDOR_OUI_SIZE		3
-#define SFP_EEPROM_PART_NO_ADDR 		0x28
-#define SFP_EEPROM_PART_NO_SIZE		16
+#define SFP_EEPROM_PART_NO_ADDR			0x28
+#define SFP_EEPROM_PART_NO_SIZE			16
 #define PWR_FLT_ERR_MSG_LEN			250
 
 #define XGXS_EXT_PHY_TYPE(ext_phy_config) \
@@ -62,7 +62,7 @@
 #define SINGLE_MEDIA(params)		(params->num_phys == 2)
 /* Dual Media board contains two external phy with different media */
 #define DUAL_MEDIA(params)		(params->num_phys == 3)
-#define FW_PARAM_MDIO_CTRL_OFFSET 16
+#define FW_PARAM_MDIO_CTRL_OFFSET		16
 #define FW_PARAM_SET(phy_addr, phy_type, mdio_access) \
 	(phy_addr | phy_type | mdio_access << FW_PARAM_MDIO_CTRL_OFFSET)
 
@@ -201,12 +201,14 @@ struct link_params {
 
 	/* Default / User Configuration */
 	u8 loopback_mode;
-#define LOOPBACK_NONE	0
-#define LOOPBACK_EMAC	1
-#define LOOPBACK_BMAC	2
+#define LOOPBACK_NONE		0
+#define LOOPBACK_EMAC		1
+#define LOOPBACK_BMAC		2
 #define LOOPBACK_XGXS		3
 #define LOOPBACK_EXT_PHY	4
-#define LOOPBACK_EXT 	5
+#define LOOPBACK_EXT		5
+#define LOOPBACK_UMAC		6
+#define LOOPBACK_XMAC		7
 
 	/* Device parameters */
 	u8 mac_addr[6];
@@ -230,10 +232,11 @@ struct link_params {
 	/* Phy register parameter */
 	u32 chip_id;
 
+	/* features */
 	u32 feature_config_flags;
-#define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
-#define FEATURE_CONFIG_PFC_ENABLED		(1<<1)
-#define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY	(1<<2)
+#define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED	(1<<0)
+#define FEATURE_CONFIG_PFC_ENABLED			(1<<1)
+#define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY		(1<<2)
 #define FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY	(1<<3)
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
@@ -379,7 +382,7 @@ void bnx2x_ets_disabled(struct link_params *params);
 
 /* Used to configure the ETS to BW limited */
 void bnx2x_ets_bw_limit(const struct link_params *params, const u32 cos0_bw,
-						const u32 cos1_bw);
+			const u32 cos1_bw);
 
 /* Used to configure the ETS to strict */
 u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos);
-- 
1.7.1







