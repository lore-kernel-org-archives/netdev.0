From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sky2: sparse warnings
Date: Tue, 5 Dec 2006 12:03:41 -0800
Message-ID: <20061205120341.630564b8@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50567 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968670AbWLEUE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 15:04:29 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of sparse warnings in sky2 driver because of mixed enum
usage.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/sky2.c |   18 ++++--------------
 drivers/net/sky2.h |   53 +++++++++++++++++++++++++---------------------------
 2 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 842abd9..ae91571 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -522,7 +522,7 @@ static void sky2_phy_init(struct sky2_hw
 		/* set Tx LED (LED_TX) to blink mode on Rx OR Tx activity */
 		ledctrl |= PHY_M_LED_BLINK_RT(BLINK_84MS) | PHY_M_LEDC_TX_CTRL;
 		/* turn off the Rx LED (LED_RX) */
-		ledover |= PHY_M_LED_MO_RX(MO_LED_OFF);
+		ledover &= ~PHY_M_LED_MO_RX;
 	}
 
 	if (hw->chip_id == CHIP_ID_YUKON_EC_U && hw->chip_rev == CHIP_REV_YU_EC_A1) {
@@ -545,7 +545,7 @@ static void sky2_phy_init(struct sky2_hw
 
 		if (sky2->autoneg == AUTONEG_DISABLE || sky2->speed == SPEED_100) {
 			/* turn on 100 Mbps LED (LED_LINK100) */
-			ledover |= PHY_M_LED_MO_100(MO_LED_ON);
+			ledover |= PHY_M_LED_MO_100;
 		}
 
 		if (ledover)
@@ -2917,18 +2917,8 @@ static void sky2_led(struct sky2_hw *hw,
 
 	default:
 		gm_phy_write(hw, port, PHY_MARV_LED_CTRL, 0);
-		gm_phy_write(hw, port, PHY_MARV_LED_OVER,
-			     on ? PHY_M_LED_MO_DUP(MO_LED_ON) |
-			     PHY_M_LED_MO_10(MO_LED_ON) |
-			     PHY_M_LED_MO_100(MO_LED_ON) |
-			     PHY_M_LED_MO_1000(MO_LED_ON) |
-			     PHY_M_LED_MO_RX(MO_LED_ON)
-			     : PHY_M_LED_MO_DUP(MO_LED_OFF) |
-			     PHY_M_LED_MO_10(MO_LED_OFF) |
-			     PHY_M_LED_MO_100(MO_LED_OFF) |
-			     PHY_M_LED_MO_1000(MO_LED_OFF) |
-			     PHY_M_LED_MO_RX(MO_LED_OFF));
-
+		gm_phy_write(hw, port, PHY_MARV_LED_OVER, 
+			     on ? PHY_M_LED_ALL : 0);
 	}
 }
 
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 7760545..713d2c5 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -608,7 +608,7 @@ enum {
 	PHY_ADDR_MARV	= 0,
 };
 
-#define RB_ADDR(offs, queue) (B16_RAM_REGS + (queue) + (offs))
+#define RB_ADDR(offs, queue) ((u16) B16_RAM_REGS + (queue) + (offs))
 
 
 enum {
@@ -1060,7 +1060,7 @@ enum {
 	PHY_M_PC_EN_DET_PLUS	= 3<<8, /* Energy Detect Plus (Mode 2) */
 };
 
-#define PHY_M_PC_MDI_XMODE(x)	(((x)<<5) & PHY_M_PC_MDIX_MSK)
+#define PHY_M_PC_MDI_XMODE(x)	(((u16)(x)<<5) & PHY_M_PC_MDIX_MSK)
 
 enum {
 	PHY_M_PC_MAN_MDI	= 0, /* 00 = Manual MDI configuration */
@@ -1156,13 +1156,13 @@ enum {
 	PHY_M_EC_TX_TIM_CT  = 1<<1, /* RGMII Tx Timing Control */
 	PHY_M_EC_TRANS_DIS  = 1<<0, /* Transmitter Disable (88E1111 only) */};
 
-#define PHY_M_EC_M_DSC(x)	((x)<<10 & PHY_M_EC_M_DSC_MSK)
+#define PHY_M_EC_M_DSC(x)	((u16)(x)<<10 & PHY_M_EC_M_DSC_MSK)
 					/* 00=1x; 01=2x; 10=3x; 11=4x */
-#define PHY_M_EC_S_DSC(x)	((x)<<8 & PHY_M_EC_S_DSC_MSK)
+#define PHY_M_EC_S_DSC(x)	((u16)(x)<<8 & PHY_M_EC_S_DSC_MSK)
 					/* 00=dis; 01=1x; 10=2x; 11=3x */
-#define PHY_M_EC_DSC_2(x)	((x)<<9 & PHY_M_EC_M_DSC_MSK2)
+#define PHY_M_EC_DSC_2(x)	((u16)(x)<<9 & PHY_M_EC_M_DSC_MSK2)
 					/* 000=1x; 001=2x; 010=3x; 011=4x */
-#define PHY_M_EC_MAC_S(x)	((x)<<4 & PHY_M_EC_MAC_S_MSK)
+#define PHY_M_EC_MAC_S(x)	((u16)(x)<<4 & PHY_M_EC_MAC_S_MSK)
 					/* 01X=0; 110=2.5; 111=25 (MHz) */
 
 /* for Yukon-2 Gigabit Ethernet PHY (88E1112 only) */
@@ -1173,7 +1173,7 @@ enum {
 };
 /* !!! Errata in spec. (1 = disable) */
 
-#define PHY_M_PC_DSC(x)			(((x)<<12) & PHY_M_PC_DSC_MSK)
+#define PHY_M_PC_DSC(x)			(((u16)(x)<<12) & PHY_M_PC_DSC_MSK)
 											/* 100=5x; 101=6x; 110=7x; 111=8x */
 enum {
 	MAC_TX_CLK_0_MHZ	= 2,
@@ -1203,7 +1203,7 @@ enum {
 	PHY_M_LEDC_TX_C_MSB	= 1<<0, /* Tx Control (MSB, 88E1111 only) */
 };
 
-#define PHY_M_LED_PULS_DUR(x)	(((x)<<12) & PHY_M_LEDC_PULS_MSK)
+#define PHY_M_LED_PULS_DUR(x)	(((u16)(x)<<12) & PHY_M_LEDC_PULS_MSK)
 
 /*****  PHY_MARV_PHY_STAT (page 3)16 bit r/w	Polarity Control Reg. *****/
 enum {
@@ -1233,7 +1233,7 @@ enum {
 	PULS_1300MS	= 7,/* 1.3 s to 2.7 s */
 };
 
-#define PHY_M_LED_BLINK_RT(x)	(((x)<<8) & PHY_M_LEDC_BL_R_MSK)
+#define PHY_M_LED_BLINK_RT(x)	(((u16)(x)<<8) & PHY_M_LEDC_BL_R_MSK)
 
 enum {
 	BLINK_42MS	= 0,/* 42 ms */
@@ -1243,21 +1243,18 @@ enum {
 	BLINK_670MS	= 4,/* 670 ms */
 };
 
-/*****  PHY_MARV_LED_OVER	16 bit r/w	Manual LED Override Reg *****/
-#define PHY_M_LED_MO_SGMII(x)	((x)<<14) /* Bit 15..14:  SGMII AN Timer */
-										/* Bit 13..12:	reserved */
-#define PHY_M_LED_MO_DUP(x)	((x)<<10) /* Bit 11..10:  Duplex */
-#define PHY_M_LED_MO_10(x)	((x)<<8) /* Bit  9.. 8:  Link 10 */
-#define PHY_M_LED_MO_100(x)	((x)<<6) /* Bit  7.. 6:  Link 100 */
-#define PHY_M_LED_MO_1000(x)	((x)<<4) /* Bit  5.. 4:  Link 1000 */
-#define PHY_M_LED_MO_RX(x)	((x)<<2) /* Bit  3.. 2:  Rx */
-#define PHY_M_LED_MO_TX(x)	((x)<<0) /* Bit  1.. 0:  Tx */
-
+/**** PHY_MARV_LED_OVER    16 bit r/w LED control */
 enum {
-	MO_LED_NORM	= 0,
-	MO_LED_BLINK	= 1,
-	MO_LED_OFF	= 2,
-	MO_LED_ON	= 3,
+	PHY_M_LED_MO_DUP  = 3<<10,/* Bit 11..10:  Duplex */
+	PHY_M_LED_MO_10	  = 3<<8, /* Bit  9.. 8:  Link 10 */
+	PHY_M_LED_MO_100  = 3<<6, /* Bit  7.. 6:  Link 100 */
+	PHY_M_LED_MO_1000 = 3<<4, /* Bit  5.. 4:  Link 1000 */
+	PHY_M_LED_MO_RX	  = 3<<2, /* Bit  3.. 2:  Rx */
+	PHY_M_LED_MO_TX	  = 3<<0, /* Bit  1.. 0:  Tx */
+
+	PHY_M_LED_ALL	  = PHY_M_LED_MO_DUP | PHY_M_LED_MO_10 
+			    | PHY_M_LED_MO_100 | PHY_M_LED_MO_1000
+			    | PHY_M_LED_MO_RX,
 };
 
 /*****  PHY_MARV_EXT_CTRL_2	16 bit r/w	Ext. PHY Specific Ctrl 2 *****/
@@ -1294,9 +1291,9 @@ enum {
 	PHY_M_FELP_LED0_MSK = 0xf, /* Bit  3.. 0: LED0 Mask (SPEED) */
 };
 
-#define PHY_M_FELP_LED2_CTRL(x)	(((x)<<8) & PHY_M_FELP_LED2_MSK)
-#define PHY_M_FELP_LED1_CTRL(x)	(((x)<<4) & PHY_M_FELP_LED1_MSK)
-#define PHY_M_FELP_LED0_CTRL(x)	(((x)<<0) & PHY_M_FELP_LED0_MSK)
+#define PHY_M_FELP_LED2_CTRL(x)	(((u16)(x)<<8) & PHY_M_FELP_LED2_MSK)
+#define PHY_M_FELP_LED1_CTRL(x)	(((u16)(x)<<4) & PHY_M_FELP_LED1_MSK)
+#define PHY_M_FELP_LED0_CTRL(x)	(((u16)(x)<<0) & PHY_M_FELP_LED0_MSK)
 
 enum {
 	LED_PAR_CTRL_COLX	= 0x00,
@@ -1552,8 +1549,8 @@ enum {
 	GM_SMI_CT_BUSY		= 1<<3,	/* Bit  3:	Busy (Operation in progress) */
 };
 
-#define GM_SMI_CT_PHY_AD(x)	(((x)<<11) & GM_SMI_CT_PHY_A_MSK)
-#define GM_SMI_CT_REG_AD(x)	(((x)<<6) & GM_SMI_CT_REG_A_MSK)
+#define GM_SMI_CT_PHY_AD(x)	(((u16)(x)<<11) & GM_SMI_CT_PHY_A_MSK)
+#define GM_SMI_CT_REG_AD(x)	(((u16)(x)<<6) & GM_SMI_CT_REG_A_MSK)
 
 /*	GM_PHY_ADDR				16 bit r/w	GPHY Address Register */
 enum {
-- 
1.4.1


-- 
Stephen Hemminger <shemminger@osdl.org>
