From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 13/14] bfin_mac: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:25 -0700
Message-ID: <1395882446-552-14-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:61927 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756670AbaC0BIR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:17 -0400
Received: by mail-pa0-f50.google.com with SMTP id kq14so2701780pab.37
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:17 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bfin_mdiobus_reset() does nothing useful and is optional for the MDIO
bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/adi/bfin_mac.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index 95779b6b7394..7ae74d450e8f 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -307,11 +307,6 @@ static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 	return bfin_mdio_poll();
 }
 
-static int bfin_mdiobus_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static void bfin_mac_adjust_link(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
@@ -1824,7 +1819,6 @@ static int bfin_mii_bus_probe(struct platform_device *pdev)
 		goto out_err_alloc;
 	miibus->read = bfin_mdiobus_read;
 	miibus->write = bfin_mdiobus_write;
-	miibus->reset = bfin_mdiobus_reset;
 
 	miibus->parent = &pdev->dev;
 	miibus->name = "bfin_mii_bus";
-- 
1.8.3.2
