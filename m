From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 3/8] net: phy: bcm7xxx: do not use PHY_BRCM_100MBPS_WAR
Date: Fri, 19 Sep 2014 13:07:51 -0700
Message-ID: <1411157276-18260-4-git-send-email-f.fainelli@gmail.com>
References: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:41550 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbaISUIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:08:16 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so750305pad.13
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:08:15 -0700 (PDT)
In-Reply-To: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need for the PHY driver to check PHY_BRCM_100MBPS_WAR since
that is redundant with checking the PHY device supported features. Get
rid of that workaround flag.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 09dd6e1dc6e1..be3a591aabba 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -257,8 +257,8 @@ static int bcm7xxx_config_init(struct phy_device *phydev)
 	phy_write(phydev, MII_BCM7XXX_AUX_MODE, MII_BCM7XX_64CLK_MDIO);
 	phy_read(phydev, MII_BCM7XXX_AUX_MODE);
 
-	/* Workaround only required for 100Mbits/sec */
-	if (!(phydev->dev_flags & PHY_BRCM_100MBPS_WAR))
+	/* Workaround only required for 100Mbits/sec capable PHYs */
+	if (phydev->supported & PHY_GBIT_FEATURES)
 		return 0;
 
 	/* set shadow mode 2 */
-- 
1.9.1
