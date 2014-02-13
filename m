From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 03/10] net: phy: broadcom: extract register definitions
Date: Thu, 13 Feb 2014 14:53:42 -0800
Message-ID: <1392332029-24669-4-git-send-email-f.fainelli@gmail.com>
References: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<cernekee@gmail.com>, <mark.rutland@arm.com>,
	<romieu@fr.zoreil.com>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:51626 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbaBMWzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:55:23 -0500
In-Reply-To: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom BCM54xx register definitions are shared between BCM54xx and
BCM7xx internal PHYs for which we are adding support. Extract these
register definitions and put them in include/linux/brcmphy.h for use by
the BCM7xxx internal PHY driver.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
New patch

 drivers/net/phy/broadcom.c | 52 ----------------------------------------------
 include/linux/brcmphy.h    | 51 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+), 52 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index f8c90ea..34088d6 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -25,58 +25,6 @@
 #define BRCM_PHY_REV(phydev) \
 	((phydev)->drv->phy_id & ~((phydev)->drv->phy_id_mask))
 
-
-#define MII_BCM54XX_ECR		0x10	/* BCM54xx extended control register */
-#define MII_BCM54XX_ECR_IM	0x1000	/* Interrupt mask */
-#define MII_BCM54XX_ECR_IF	0x0800	/* Interrupt force */
-
-#define MII_BCM54XX_ESR		0x11	/* BCM54xx extended status register */
-#define MII_BCM54XX_ESR_IS	0x1000	/* Interrupt status */
-
-#define MII_BCM54XX_EXP_DATA	0x15	/* Expansion register data */
-#define MII_BCM54XX_EXP_SEL	0x17	/* Expansion register select */
-#define MII_BCM54XX_EXP_SEL_SSD	0x0e00	/* Secondary SerDes select */
-#define MII_BCM54XX_EXP_SEL_ER	0x0f00	/* Expansion register select */
-
-#define MII_BCM54XX_AUX_CTL	0x18	/* Auxiliary control register */
-#define MII_BCM54XX_ISR		0x1a	/* BCM54xx interrupt status register */
-#define MII_BCM54XX_IMR		0x1b	/* BCM54xx interrupt mask register */
-#define MII_BCM54XX_INT_CRCERR	0x0001	/* CRC error */
-#define MII_BCM54XX_INT_LINK	0x0002	/* Link status changed */
-#define MII_BCM54XX_INT_SPEED	0x0004	/* Link speed change */
-#define MII_BCM54XX_INT_DUPLEX	0x0008	/* Duplex mode changed */
-#define MII_BCM54XX_INT_LRS	0x0010	/* Local receiver status changed */
-#define MII_BCM54XX_INT_RRS	0x0020	/* Remote receiver status changed */
-#define MII_BCM54XX_INT_SSERR	0x0040	/* Scrambler synchronization error */
-#define MII_BCM54XX_INT_UHCD	0x0080	/* Unsupported HCD negotiated */
-#define MII_BCM54XX_INT_NHCD	0x0100	/* No HCD */
-#define MII_BCM54XX_INT_NHCDL	0x0200	/* No HCD link */
-#define MII_BCM54XX_INT_ANPR	0x0400	/* Auto-negotiation page received */
-#define MII_BCM54XX_INT_LC	0x0800	/* All counters below 128 */
-#define MII_BCM54XX_INT_HC	0x1000	/* Counter above 32768 */
-#define MII_BCM54XX_INT_MDIX	0x2000	/* MDIX status change */
-#define MII_BCM54XX_INT_PSERR	0x4000	/* Pair swap error */
-
-#define MII_BCM54XX_SHD		0x1c	/* 0x1c shadow registers */
-#define MII_BCM54XX_SHD_WRITE	0x8000
-#define MII_BCM54XX_SHD_VAL(x)	((x & 0x1f) << 10)
-#define MII_BCM54XX_SHD_DATA(x)	((x & 0x3ff) << 0)
-
-/*
- * AUXILIARY CONTROL SHADOW ACCESS REGISTERS.  (PHY REG 0x18)
- */
-#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
-#define MII_BCM54XX_AUXCTL_ACTL_TX_6DB		0x0400
-#define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
-
-#define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
-#define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
-#define MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC	0x7000
-#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
-
-#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
-
-
 /*
  * Broadcom LED source encodings.  These are used in BCM5461, BCM5481,
  * BCM5482, and possibly some others.
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 677b4f0..104e3ef 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -33,4 +33,55 @@
 #define PHY_BRCM_DIS_TXCRXC_NOENRGY	0x00008000
 #define PHY_BCM_FLAGS_VALID		0x80000000
 
+/* Broadcom BCM54XX register definitions, common to most Broadcom PHYs */
+#define MII_BCM54XX_ECR		0x10	/* BCM54xx extended control register */
+#define MII_BCM54XX_ECR_IM	0x1000	/* Interrupt mask */
+#define MII_BCM54XX_ECR_IF	0x0800	/* Interrupt force */
+
+#define MII_BCM54XX_ESR		0x11	/* BCM54xx extended status register */
+#define MII_BCM54XX_ESR_IS	0x1000	/* Interrupt status */
+
+#define MII_BCM54XX_EXP_DATA	0x15	/* Expansion register data */
+#define MII_BCM54XX_EXP_SEL	0x17	/* Expansion register select */
+#define MII_BCM54XX_EXP_SEL_SSD	0x0e00	/* Secondary SerDes select */
+#define MII_BCM54XX_EXP_SEL_ER	0x0f00	/* Expansion register select */
+
+#define MII_BCM54XX_AUX_CTL	0x18	/* Auxiliary control register */
+#define MII_BCM54XX_ISR		0x1a	/* BCM54xx interrupt status register */
+#define MII_BCM54XX_IMR		0x1b	/* BCM54xx interrupt mask register */
+#define MII_BCM54XX_INT_CRCERR	0x0001	/* CRC error */
+#define MII_BCM54XX_INT_LINK	0x0002	/* Link status changed */
+#define MII_BCM54XX_INT_SPEED	0x0004	/* Link speed change */
+#define MII_BCM54XX_INT_DUPLEX	0x0008	/* Duplex mode changed */
+#define MII_BCM54XX_INT_LRS	0x0010	/* Local receiver status changed */
+#define MII_BCM54XX_INT_RRS	0x0020	/* Remote receiver status changed */
+#define MII_BCM54XX_INT_SSERR	0x0040	/* Scrambler synchronization error */
+#define MII_BCM54XX_INT_UHCD	0x0080	/* Unsupported HCD negotiated */
+#define MII_BCM54XX_INT_NHCD	0x0100	/* No HCD */
+#define MII_BCM54XX_INT_NHCDL	0x0200	/* No HCD link */
+#define MII_BCM54XX_INT_ANPR	0x0400	/* Auto-negotiation page received */
+#define MII_BCM54XX_INT_LC	0x0800	/* All counters below 128 */
+#define MII_BCM54XX_INT_HC	0x1000	/* Counter above 32768 */
+#define MII_BCM54XX_INT_MDIX	0x2000	/* MDIX status change */
+#define MII_BCM54XX_INT_PSERR	0x4000	/* Pair swap error */
+
+#define MII_BCM54XX_SHD		0x1c	/* 0x1c shadow registers */
+#define MII_BCM54XX_SHD_WRITE	0x8000
+#define MII_BCM54XX_SHD_VAL(x)	((x & 0x1f) << 10)
+#define MII_BCM54XX_SHD_DATA(x)	((x & 0x3ff) << 0)
+
+/*
+ * AUXILIARY CONTROL SHADOW ACCESS REGISTERS.  (PHY REG 0x18)
+ */
+#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
+#define MII_BCM54XX_AUXCTL_ACTL_TX_6DB		0x0400
+#define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
+
+#define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
+#define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
+#define MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC	0x7000
+#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
+
+#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
+
 #endif /* _LINUX_BRCMPHY_H */
-- 
1.8.3.2
