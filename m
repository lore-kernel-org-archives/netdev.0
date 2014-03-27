From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 04/14] dnet: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:16 -0700
Message-ID: <1395882446-552-5-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:41476 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbaC0BHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:48 -0400
Received: by mail-pb0-f51.google.com with SMTP id uo5so2700287pbc.24
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:48 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dnet_mdio_reset() does nothing useful and is optional for the MDIO bus
code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/dnet.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 8a79a32a5674..e9b0faba3078 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -170,11 +170,6 @@ static int dnet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	return 0;
 }
 
-static int dnet_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static void dnet_handle_link_change(struct net_device *dev)
 {
 	struct dnet *bp = netdev_priv(dev);
@@ -322,7 +317,6 @@ static int dnet_mii_init(struct dnet *bp)
 	bp->mii_bus->name = "dnet_mii_bus";
 	bp->mii_bus->read = &dnet_mdio_read;
 	bp->mii_bus->write = &dnet_mdio_write;
-	bp->mii_bus->reset = &dnet_mdio_reset;
 
 	snprintf(bp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		bp->pdev->name, bp->pdev->id);
-- 
1.8.3.2
