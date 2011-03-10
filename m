From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] phylib: SIOCGMIIREG/SIOCSMIIREG: allow access to all mdio addresses
Date: Thu, 10 Mar 2011 17:52:13 +0100
Message-ID: <1299775933-26981-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52412 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487Ab1CJQwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 11:52:40 -0500
Received: by wya21 with SMTP id 21so1629238wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 08:52:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phylib would silently ignore the phy_id argument to these ioctls and
perform the read/write with the active phydev address, whereas most
non-phylib drivers seem to allow access to all mdio addresses
(E.G. pcnet_cs).

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/phy/phy.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index a8445c7..f767033 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -319,7 +319,8 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		/* fall through */
 
 	case SIOCGMIIREG:
-		mii_data->val_out = phy_read(phydev, mii_data->reg_num);
+		mii_data->val_out = mdiobus_read(phydev->bus, mii_data->phy_id,
+						 mii_data->reg_num);
 		break;
 
 	case SIOCSMIIREG:
@@ -350,8 +351,9 @@ int phy_mii_ioctl(struct phy_device *phydev,
 			}
 		}
 
-		phy_write(phydev, mii_data->reg_num, val);
-		
+		mdiobus_write(phydev->bus, mii_data->phy_id,
+			      mii_data->reg_num, val);
+
 		if (mii_data->reg_num == MII_BMCR &&
 		    val & BMCR_RESET &&
 		    phydev->drv->config_init) {
-- 
1.7.2.3

