From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 06/14] fec: remove empty MDIO bus function
Date: Wed, 26 Mar 2014 18:07:18 -0700
Message-ID: <1395882446-552-7-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:49427 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbaC0BH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:07:57 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so2608270pdj.40
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:56 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_mdio_reset() does nothing useful and is optional for the MDIO
bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f9f8a589cdef..e19315eaf2dd 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1255,11 +1255,6 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	return 0;
 }
 
-static int fec_enet_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static int fec_enet_mii_probe(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
@@ -1384,7 +1379,6 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 	fep->mii_bus->name = "fec_enet_mii_bus";
 	fep->mii_bus->read = fec_enet_mdio_read;
 	fep->mii_bus->write = fec_enet_mdio_write;
-	fep->mii_bus->reset = fec_enet_mdio_reset;
 	snprintf(fep->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
 		pdev->name, fep->dev_id + 1);
 	fep->mii_bus->priv = fep;
-- 
1.8.3.2
