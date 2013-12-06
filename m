From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 2/9] net: phy: use phy_init_hw instead of open-coding it
Date: Fri, 6 Dec 2013 13:01:31 -0800
Message-ID: <1386363698-8407-3-git-send-email-f.fainelli@gmail.com>
References: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:56936 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab3LFVB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:01:59 -0500
In-Reply-To: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use phy_init_hw() instead of open-coding it in phy_mii_ioctl(), this
improves consistenty and makes sure that we will not duplicate the same
routine somewhere else.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 05cb8fe..5d7101b 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -361,11 +361,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
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
