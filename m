From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/7] net: phy: broadcom: move shadow 0x1C register accessors to brcmphy.h
Date: Fri, 22 Aug 2014 18:55:40 -0700
Message-ID: <1408758945-18908-3-git-send-email-f.fainelli@gmail.com>
References: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36206 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822AbaHWB4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 21:56:16 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so17098269pdj.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 18:56:16 -0700 (PDT)
In-Reply-To: <1408758945-18908-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The shadow register 0x1C is used both by the BCM54xxx PHYs and the
BCM7xxx internal PHYs, move the accessors to a common location so both
drivers can use them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/broadcom.c | 18 ------------------
 include/linux/brcmphy.h    | 20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 6001d76d8676..854f2c9a7b2b 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -29,24 +29,6 @@ MODULE_DESCRIPTION("Broadcom PHY driver");
 MODULE_AUTHOR("Maciej W. Rozycki");
 MODULE_LICENSE("GPL");
 
-/*
- * Indirect register access functions for the 1000BASE-T/100BASE-TX/10BASE-T
- * 0x1c shadow registers.
- */
-static int bcm54xx_shadow_read(struct phy_device *phydev, u16 shadow)
-{
-	phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
-	return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
-}
-
-static int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow, u16 val)
-{
-	return phy_write(phydev, MII_BCM54XX_SHD,
-			 MII_BCM54XX_SHD_WRITE |
-			 MII_BCM54XX_SHD_VAL(shadow) |
-			 MII_BCM54XX_SHD_DATA(val));
-}
-
 /* Indirect register access functions for the Expansion Registers */
 static int bcm54xx_exp_read(struct phy_device *phydev, u16 regnum)
 {
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index bf902d1c1b19..c221e6df2bc4 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -196,4 +196,24 @@
 #define MII_BRCM_FET_SHDW_AUXSTAT2	0x1b	/* Auxiliary status 2 */
 #define MII_BRCM_FET_SHDW_AS2_APDE	0x0020	/* Auto power down enable */
 
+/*
+ * Indirect register access functions for the 1000BASE-T/100BASE-TX/10BASE-T
+ * 0x1c shadow registers.
+ */
+static inline int bcm54xx_shadow_read(struct phy_device *phydev, u16 shadow)
+{
+	phy_write(phydev, MII_BCM54XX_SHD, MII_BCM54XX_SHD_VAL(shadow));
+	return MII_BCM54XX_SHD_DATA(phy_read(phydev, MII_BCM54XX_SHD));
+}
+
+static inline int bcm54xx_shadow_write(struct phy_device *phydev, u16 shadow,
+				       u16 val)
+{
+	return phy_write(phydev, MII_BCM54XX_SHD,
+			 MII_BCM54XX_SHD_WRITE |
+			 MII_BCM54XX_SHD_VAL(shadow) |
+			 MII_BCM54XX_SHD_DATA(val));
+}
+
+
 #endif /* _LINUX_BRCMPHY_H */
-- 
1.9.1
