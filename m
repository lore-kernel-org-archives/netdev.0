From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 1/4] net: phy: bcm7xxx: Fix shadow mode 2 disabling
Date: Sat,  6 Feb 2016 12:58:48 -0800
Message-ID: <1454792331-4435-2-git-send-email-f.fainelli@gmail.com>
References: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	opendmb@gmail.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34358 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbcBFU64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2016 15:58:56 -0500
Received: by mail-pf0-f182.google.com with SMTP id o185so87788310pfb.1
        for <netdev@vger.kernel.org>; Sat, 06 Feb 2016 12:58:56 -0800 (PST)
In-Reply-To: <1454792331-4435-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The clear and set masks in the call to phy_set_clr_bits() called from
bcm7xxx_config_init() are inverted. We need to fix this by swapping the two
arguments, that is, set 0 bits, but clear the shade mode 2 enable bit.

Fixes: b560a58c45c66 ("net: phy: add Broadcom BCM7xxx internal PHY driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/bcm7xxx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/bcm7xxx.c b/drivers/net/phy/bcm7xxx.c
index bf241a3..234a285 100644
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
1.7.1
