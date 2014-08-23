From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/7] net: phy: broadcom: extract all registers to brcmphy.h
Date: Fri, 22 Aug 2014 18:55:39 -0700
Message-ID: <1408758945-18908-2-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36922 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbaHWB4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:15 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so17098254pdj.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:15 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 439d39a9ac8fbbba9c04581361188f33f21ced50 ("net: phy: broadcom:
extract register definitions") added a bunch of registers to brcmphy.h
but left some to broadcom.c, move all of them to the header file since
the BCM54xx and BCM7xxx PHY drivers do share all of these registers.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/broadcom.c | 104 ---------------------------------------------
 include/linux/brcmphy.h    | 103 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 103 insertions(+), 104 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 34088d60da74..6001d76d8676 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -25,110 +25,6 @@
 #define BRCM_PHY_REV(phydev) \
 	((phydev)->drv->phy_id & ~((phydev)->drv->phy_id_mask))
 
-/*
- * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
- * BCM5482, and possibly some others.
- */
-#define BCM_LED_SRC_LINKSPD1	0x0
-#define BCM_LED_SRC_LINKSPD2	0x1
-#define BCM_LED_SRC_XMITLED	0x2
-#define BCM_LED_SRC_ACTIVITYLED	0x3
-#define BCM_LED_SRC_FDXLED	0x4
-#define BCM_LED_SRC_SLAVE	0x5
-#define BCM_LED_SRC_INTR	0x6
-#define BCM_LED_SRC_QUALITY	0x7
-#define BCM_LED_SRC_RCVLED	0x8
-#define BCM_LED_SRC_MULTICOLOR1	0xa
-#define BCM_LED_SRC_OPENSHORT	0xb
-#define BCM_LED_SRC_OFF		0xe	/* Tied high */
-#define BCM_LED_SRC_ON		0xf	/* Tied low */
-
-
-/*
- * BCM5482: Shadow registers
- * Shadow values go into bits [14:10] of register 0x1c to select a shadow
- * register to access.
- */
-/* 00101: Spare Control Register 3 */
-#define BCM54XX_SHD_SCR3		0x05
-#define  BCM54XX_SHD_SCR3_DEF_CLK125	0x0001
-#define  BCM54XX_SHD_SCR3_DLLAPD_DIS	0x0002
-#define  BCM54XX_SHD_SCR3_TRDDAPD	0x0004
-
-/* 01010: Auto Power-Down */
-#define BCM54XX_SHD_APD			0x0a
-#define  BCM54XX_SHD_APD_EN		0x0020
-
-#define BCM5482_SHD_LEDS1	0x0d	/* 01101: LED Selector 1 */
-					/* LED3 / ~LINKSPD[2] selector */
-#define BCM5482_SHD_LEDS1_LED3(src)	((src & 0xf) << 4)
-					/* LED1 / ~LINKSPD[1] selector */
-#define BCM5482_SHD_LEDS1_LED1(src)	((src & 0xf) << 0)
-#define BCM54XX_SHD_RGMII_MODE	0x0b	/* 01011: RGMII Mode Selector */
-#define BCM5482_SHD_SSD		0x14	/* 10100: Secondary SerDes control */
-#define BCM5482_SHD_SSD_LEDM	0x0008	/* SSD LED Mode enable */
-#define BCM5482_SHD_SSD_EN	0x0001	/* SSD enable */
-#define BCM5482_SHD_MODE	0x1f	/* 11111: Mode Control Register */
-#define BCM5482_SHD_MODE_1000BX	0x0001	/* Enable 1000BASE-X registers */
-
-
-/*
- * EXPANSION SHADOW ACCESS REGISTERS.  (PHY REG 0x15, 0x16, and 0x17)
- */
-#define MII_BCM54XX_EXP_AADJ1CH0		0x001f
-#define  MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN	0x0200
-#define  MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF	0x0100
-#define MII_BCM54XX_EXP_AADJ1CH3		0x601f
-#define  MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ	0x0002
-#define MII_BCM54XX_EXP_EXP08			0x0F08
-#define  MII_BCM54XX_EXP_EXP08_RJCT_2MHZ	0x0001
-#define  MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE	0x0200
-#define MII_BCM54XX_EXP_EXP75			0x0f75
-#define  MII_BCM54XX_EXP_EXP75_VDACCTRL		0x003c
-#define  MII_BCM54XX_EXP_EXP75_CM_OSC		0x0001
-#define MII_BCM54XX_EXP_EXP96			0x0f96
-#define  MII_BCM54XX_EXP_EXP96_MYST		0x0010
-#define MII_BCM54XX_EXP_EXP97			0x0f97
-#define  MII_BCM54XX_EXP_EXP97_MYST		0x0c0c
-
-/*
- * BCM5482: Secondary SerDes registers
- */
-#define BCM5482_SSD_1000BX_CTL		0x00	/* 1000BASE-X Control */
-#define BCM5482_SSD_1000BX_CTL_PWRDOWN	0x0800	/* Power-down SSD */
-#define BCM5482_SSD_SGMII_SLAVE		0x15	/* SGMII Slave Register */
-#define BCM5482_SSD_SGMII_SLAVE_EN	0x0002	/* Slave mode enable */
-#define BCM5482_SSD_SGMII_SLAVE_AD	0x0001	/* Slave auto-detection */
-
-
-/*****************************************************************************/
-/* Fast Ethernet Transceiver definitions. */
-/*****************************************************************************/
-
-#define MII_BRCM_FET_INTREG		0x1a	/* Interrupt register */
-#define MII_BRCM_FET_IR_MASK		0x0100	/* Mask all interrupts */
-#define MII_BRCM_FET_IR_LINK_EN		0x0200	/* Link status change enable */
-#define MII_BRCM_FET_IR_SPEED_EN	0x0400	/* Link speed change enable */
-#define MII_BRCM_FET_IR_DUPLEX_EN	0x0800	/* Duplex mode change enable */
-#define MII_BRCM_FET_IR_ENABLE		0x4000	/* Interrupt enable */
-
-#define MII_BRCM_FET_BRCMTEST		0x1f	/* Brcm test register */
-#define MII_BRCM_FET_BT_SRE		0x0080	/* Shadow register enable */
-
-
-/*** Shadow register definitions ***/
-
-#define MII_BRCM_FET_SHDW_MISCCTRL	0x10	/* Shadow misc ctrl */
-#define MII_BRCM_FET_SHDW_MC_FAME	0x4000	/* Force Auto MDIX enable */
-
-#define MII_BRCM_FET_SHDW_AUXMODE4	0x1a	/* Auxiliary mode 4 */
-#define MII_BRCM_FET_SHDW_AM4_LED_MASK	0x0003
-#define MII_BRCM_FET_SHDW_AM4_LED_MODE1 0x0001
-
-#define MII_BRCM_FET_SHDW_AUXSTAT2	0x1b	/* Auxiliary status 2 */
-#define MII_BRCM_FET_SHDW_AS2_APDE	0x0020	/* Auto power down enable */
-
-
 MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 6f76277baf39..bf902d1c1b19 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -93,4 +93,107 @@
 
 #define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
 
+/*
+ * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
+ * BCM5482, and possibly some others.
+ */
+#define BCM_LED_SRC_LINKSPD1	0x0
+#define BCM_LED_SRC_LINKSPD2	0x1
+#define BCM_LED_SRC_XMITLED	0x2
+#define BCM_LED_SRC_ACTIVITYLED	0x3
+#define BCM_LED_SRC_FDXLED	0x4
+#define BCM_LED_SRC_SLAVE	0x5
+#define BCM_LED_SRC_INTR	0x6
+#define BCM_LED_SRC_QUALITY	0x7
+#define BCM_LED_SRC_RCVLED	0x8
+#define BCM_LED_SRC_MULTICOLOR1	0xa
+#define BCM_LED_SRC_OPENSHORT	0xb
+#define BCM_LED_SRC_OFF		0xe	/* Tied high */
+#define BCM_LED_SRC_ON		0xf	/* Tied low */
+
+
+/*
+ * BCM5482: Shadow registers
+ * Shadow values go into bits [14:10] of register 0x1c to select a shadow
+ * register to access.
+ */
+/* 00101: Spare Control Register 3 */
+#define BCM54XX_SHD_SCR3		0x05
+#define  BCM54XX_SHD_SCR3_DEF_CLK125	0x0001
+#define  BCM54XX_SHD_SCR3_DLLAPD_DIS	0x0002
+#define  BCM54XX_SHD_SCR3_TRDDAPD	0x0004
+
+/* 01010: Auto Power-Down */
+#define BCM54XX_SHD_APD			0x0a
+#define  BCM54XX_SHD_APD_EN		0x0020
+
+#define BCM5482_SHD_LEDS1	0x0d	/* 01101: LED Selector 1 */
+					/* LED3 / ~LINKSPD[2] selector */
+#define BCM5482_SHD_LEDS1_LED3(src)	((src & 0xf) << 4)
+					/* LED1 / ~LINKSPD[1] selector */
+#define BCM5482_SHD_LEDS1_LED1(src)	((src & 0xf) << 0)
+#define BCM54XX_SHD_RGMII_MODE	0x0b	/* 01011: RGMII Mode Selector */
+#define BCM5482_SHD_SSD		0x14	/* 10100: Secondary SerDes control */
+#define BCM5482_SHD_SSD_LEDM	0x0008	/* SSD LED Mode enable */
+#define BCM5482_SHD_SSD_EN	0x0001	/* SSD enable */
+#define BCM5482_SHD_MODE	0x1f	/* 11111: Mode Control Register */
+#define BCM5482_SHD_MODE_1000BX	0x0001	/* Enable 1000BASE-X registers */
+
+
+/*
+ * EXPANSION SHADOW ACCESS REGISTERS.  (PHY REG 0x15, 0x16, and 0x17)
+ */
+#define MII_BCM54XX_EXP_AADJ1CH0		0x001f
+#define  MII_BCM54XX_EXP_AADJ1CH0_SWP_ABCD_OEN	0x0200
+#define  MII_BCM54XX_EXP_AADJ1CH0_SWSEL_THPF	0x0100
+#define MII_BCM54XX_EXP_AADJ1CH3		0x601f
+#define  MII_BCM54XX_EXP_AADJ1CH3_ADCCKADJ	0x0002
+#define MII_BCM54XX_EXP_EXP08			0x0F08
+#define  MII_BCM54XX_EXP_EXP08_RJCT_2MHZ	0x0001
+#define  MII_BCM54XX_EXP_EXP08_EARLY_DAC_WAKE	0x0200
+#define MII_BCM54XX_EXP_EXP75			0x0f75
+#define  MII_BCM54XX_EXP_EXP75_VDACCTRL		0x003c
+#define  MII_BCM54XX_EXP_EXP75_CM_OSC		0x0001
+#define MII_BCM54XX_EXP_EXP96			0x0f96
+#define  MII_BCM54XX_EXP_EXP96_MYST		0x0010
+#define MII_BCM54XX_EXP_EXP97			0x0f97
+#define  MII_BCM54XX_EXP_EXP97_MYST		0x0c0c
+
+/*
+ * BCM5482: Secondary SerDes registers
+ */
+#define BCM5482_SSD_1000BX_CTL		0x00	/* 1000BASE-X Control */
+#define BCM5482_SSD_1000BX_CTL_PWRDOWN	0x0800	/* Power-down SSD */
+#define BCM5482_SSD_SGMII_SLAVE		0x15	/* SGMII Slave Register */
+#define BCM5482_SSD_SGMII_SLAVE_EN	0x0002	/* Slave mode enable */
+#define BCM5482_SSD_SGMII_SLAVE_AD	0x0001	/* Slave auto-detection */
+
+
+/*****************************************************************************/
+/* Fast Ethernet Transceiver definitions. */
+/*****************************************************************************/
+
+#define MII_BRCM_FET_INTREG		0x1a	/* Interrupt register */
+#define MII_BRCM_FET_IR_MASK		0x0100	/* Mask all interrupts */
+#define MII_BRCM_FET_IR_LINK_EN		0x0200	/* Link status change enable */
+#define MII_BRCM_FET_IR_SPEED_EN	0x0400	/* Link speed change enable */
+#define MII_BRCM_FET_IR_DUPLEX_EN	0x0800	/* Duplex mode change enable */
+#define MII_BRCM_FET_IR_ENABLE		0x4000	/* Interrupt enable */
+
+#define MII_BRCM_FET_BRCMTEST		0x1f	/* Brcm test register */
+#define MII_BRCM_FET_BT_SRE		0x0080	/* Shadow register enable */
+
+
+/*** Shadow register definitions ***/
+
+#define MII_BRCM_FET_SHDW_MISCCTRL	0x10	/* Shadow misc ctrl */
+#define MII_BRCM_FET_SHDW_MC_FAME	0x4000	/* Force Auto MDIX enable */
+
+#define MII_BRCM_FET_SHDW_AUXMODE4	0x1a	/* Auxiliary mode 4 */
+#define MII_BRCM_FET_SHDW_AM4_LED_MASK	0x0003
+#define MII_BRCM_FET_SHDW_AM4_LED_MODE1 0x0001
+
+#define MII_BRCM_FET_SHDW_AUXSTAT2	0x1b	/* Auxiliary status 2 */
+#define MII_BRCM_FET_SHDW_AS2_APDE	0x0020	/* Auto power down enable */
+
 #endif /* _LINUX_BRCMPHY_H */
-- 
1.9.1
