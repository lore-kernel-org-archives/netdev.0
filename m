From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 12/14] r6040: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:24 -0700
Message-ID: <1395882446-552-13-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:54294 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756609AbaC0BIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:15 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so2690240pbb.5
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:15 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

r6040_mdiobus_reset() does nothing useful and is optional for the MDIO
bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 819b74cefd64..cd045ecb9816 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -270,11 +270,6 @@ static int r6040_mdiobus_write(struct mii_bus *bus, int phy_addr,
 	return r6040_phy_write(ioaddr, phy_addr, reg, value);
 }
 
-static int r6040_mdiobus_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static void r6040_free_txbufs(struct net_device *dev)
 {
 	struct r6040_private *lp = netdev_priv(dev);
@@ -1191,7 +1186,6 @@ static int r6040_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	lp->mii_bus->priv = dev;
 	lp->mii_bus->read = r6040_mdiobus_read;
 	lp->mii_bus->write = r6040_mdiobus_write;
-	lp->mii_bus->reset = r6040_mdiobus_reset;
 	lp->mii_bus->name = "r6040_eth_mii";
 	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		dev_name(&pdev->dev), card_idx);
-- 
1.8.3.2
