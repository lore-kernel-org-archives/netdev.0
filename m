From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/4] net: phy: bcm7xxx: Fix shadow mode 2 disabling
Date: Wed,  3 Feb 2016 13:13:46 -0800
Message-ID: <1454534029-585-2-git-send-email-f.fainelli@gmail.com>
References: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, opendmb@gmail.com,
	jaedon.shin@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34168 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932699AbcBCVPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 16:15:52 -0500
Received: by mail-pa0-f52.google.com with SMTP id uo6so19872039pac.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 13:15:52 -0800 (PST)
In-Reply-To: <1454534029-585-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The clear and set masks in the call to phy_set_clr_bits() called from
bcm7xxx_config_init() are inverted. We need to fix this by swapping the two
arguments, that is, set 0 bits, but clear the shade mode 2 enable bit.

Fixes: b560a58c45c66 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index bf241a3ec5e5..234a28502793 100644
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@ -270,7 +270,7 @@ static int bcm7xxx_config_init(struct phy_device *phydev)
 	phy_write(phydev, MII_BCM7XXX_100TX_FALSE_CAR, 0x7555);
 
 	/* reset shadow mode 2 */
-	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, MII_BCM7XXX_SHD_MODE_2, 0);
+	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0, MII_BCM7XXX_SHD_MODE_2);
 	if (ret < 0)
 		return ret;
 
-- 
2.1.0
