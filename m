From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 3/4] net: phy: bcm7xxx: Fix bcm7xxx_config_init() check
Date: Sat,  6 Feb 2016 12:58:50 -0800
Message-ID: <1454792331-4435-4-git-send-email-f.fainelli@gmail.com>
References: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34947 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbcBFU66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:58:58 -0500
Received: by mail-pf0-f173.google.com with SMTP id c10so21329887pfc.2
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:58:58 -0800 (PST)
In-Reply-To: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we were wrongly advertising gigabit features for these 10/100 only
Ethernet PHYs, bcm7xxx_config_init() which is supposed to apply workaround
would have not run since the check would be true, now that we have fixed the
PHY features, remove that check since it has no reasoning to be there anymore.

Fixes: e18556ee3bd83 ("net: phy: bcm7xxx: do not use PHY_BRCM_100MBPS_WAR")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 524806d..568768a 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -250,10 +250,6 @@ static int bcm7xxx_config_init(struct phy_device *phydev)
 	phy_write(phydev, MII_BCM7XXX_AUX_MODE, MII_BCM7XX_64CLK_MDIO);
 	phy_read(phydev, MII_BCM7XXX_AUX_MODE);
 
-	/* Workaround only required for 100Mbits/sec capable PHYs */
-	if (phydev->supported & PHY_GBIT_FEATURES)
-		return 0;
-
 	/* set shadow mode 2 */
 	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
 			MII_BCM7XXX_SHD_MODE_2, MII_BCM7XXX_SHD_MODE_2);
-- 
1.7.1
