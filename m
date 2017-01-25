From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 2/3] net: phy: broadcom: drop duplicated define for RGMII SKEW delay
Date: Wed, 25 Jan 2017 21:00:26 +0100
Message-ID: <20170125200027.14387-3-zajec5@gmail.com>
References: <20170125200027.14387-1-zajec5@gmail.com>
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
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33819 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752091AbdAYUAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:00:51 -0500
Received: by mail-lf0-f68.google.com with SMTP id q89so22070652lfi.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 12:00:50 -0800 (PST)
In-Reply-To: <20170125200027.14387-1-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafał Miłecki <rafal@milecki.pl>

We had two defines for the same bit (both were used with the
MII_BCM54XX_AUXCTL_SHDWSEL_MISC register).

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
V2: Drop the other define to match datasheet. Thanks Florian.
---
 drivers/net/phy/broadcom.c | 2 +-
 include/linux/brcmphy.h    | 1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
index 25c6e6cea2dc..97d1c057c0a1 100644
--- a/drivers/net/phy/broadcom.c
+++ b/drivers/net/phy/broadcom.c
@@ -398,7 +398,7 @@ static int bcm54612e_config_aneg(struct phy_device *phydev)
 		reg = bcm54xx_auxctl_read(phydev,
 					  MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
 		/* Disable RXD to RXC delay (default set) */
-		reg &= ~MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW;
+		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
 		/* Clear shadow selector field */
 		reg &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MASK;
 		bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
index 34e61004b9dc..f9cb73df127e 100644
--- a/include/linux/brcmphy.h
+++ b/include/linux/brcmphy.h
@@ -109,7 +109,6 @@
 #define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
 
 #define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
-#define MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW	0x0100
 #define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
 #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
 #define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
-- 
2.11.0
