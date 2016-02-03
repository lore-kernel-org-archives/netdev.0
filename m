From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/4] net: phy: bcm7xxx: Fix bcm7xxx_config_init() check
Date: Wed,  3 Feb 2016 13:13:48 -0800
Message-ID: <1454534029-585-4-git-send-email-f.fainelli@gmail.com>
References: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34888 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933884AbcBCVPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 16:15:53 -0500
Received: by mail-pa0-f46.google.com with SMTP id ho8so19501141pac.2
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 13:15:53 -0800 (PST)
In-Reply-To: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we were wrongly advertising gigabit features for these 10/100 only
Ethernet PHYs, bcm7xxx_config_init() which is supposed to apply workaround
would have not run since the check would be true, now that we have fixed the
PHY features, remove that check since it has no reasoning to be there anymore.

Fixes: e18556ee3bd83 ("net: phy: bcm7xxx: do not use PHY_BRCM_100MBPS_WAR")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index 524806dd0f6b..568768abe3ed 100644
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
2.1.0
