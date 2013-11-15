From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: phy: use phy_init_hw instead of open-coding it
Date: Fri, 15 Nov 2013 06:09:53 +0000
Message-ID: <1384495793-22534-1-git-send-email-f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:52506 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651Ab3KOGJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 01:09:58 -0500
Received: by mail-oa0-f42.google.com with SMTP id h16so3488964oag.1
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 22:09:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already have a helper function which verifies a PHY device driver
implements a config_init callback, then calls phy_scan_fixups() and
ultimately calls the config_init callback. Use that instead of open
coding it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 36c6994..1e5de8c 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -360,11 +360,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
 			      mii_data->reg_num, val);
 
 		if (mii_data->reg_num == MII_BMCR &&
-		    val & BMCR_RESET &&
-		    phydev->drv->config_init) {
-			phy_scan_fixups(phydev);
-			phydev->drv->config_init(phydev);
-		}
+		    val & BMCR_RESET)
+			phy_init_hw(phydev);
 		break;
 
 	case SIOCSHWTSTAMP:
-- 
1.8.3.2
