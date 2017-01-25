From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/3] net: phy: broadcom: use auxctl reading helper in BCM54612E code
Date: Wed, 25 Jan 2017 16:54:09 +0100
Message-ID: <20170125155411.14922-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33224 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751720AbdAYPyg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 10:54:36 -0500
Received: by mail-lf0-f67.google.com with SMTP id x1so21632415lff.0
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 07:54:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

Starting with commit 5b4e29005123 ("net: phy: broadcom: add
bcm54xx_auxctl_read") we have a reading helper so use it and avoid code
duplication.
It also means we don't need MII_BCM54XX_AUXCTL_SHDWSEL_MISC define as
it's the same as MII_BCM54XX_AUXCTL_SHDWSEL_MISC just for reading needs
(same value shifted by 12 bits).

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/phy/broadcom.c | 6 ++----
 include/linux/brcmphy.h    | 1 -
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 4223e35490b0..25c6e6cea2dc 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -395,10 +395,8 @@ static int bcm54612e_config_aneg(struct phy_device *phydev)
 	    (phydev->interface != PHY_INTERFACE_MODE_RGMII_RXID)) {
 		u16 reg;
 
-		/* Errata: reads require filling in the write selector field */
-		bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
-				     MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC);
-		reg = phy_read(phydev, MII_BCM54XX_AUX_CTL);
+		reg = bcm54xx_auxctl_read(phydev,
+					  MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
 		/* Disable RXD to RXC delay (default set) */
 		reg &= ~MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW;
 		/* Clear shadow selector field */
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 295fb3e73de5..34e61004b9dc 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -111,7 +111,6 @@
 #define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
 #define MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW	0x0100
 #define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
-#define MII_BCM54XX_AUXCTL_MISC_RDSEL_MISC	0x7000
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
 #define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN	(1 << 8)
-- 
2.11.0
