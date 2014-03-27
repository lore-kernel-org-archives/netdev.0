From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 07/14] fs_enet: remove empty MDIO bus function
Date: Wed, 26 Mar 2014 18:07:19 -0700
Message-ID: <1395882446-552-8-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:42026 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbaC0BIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:00 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so2709947pad.7
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:07:59 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fs_enet_fec_mii_reset() does nothing useful and is optional for the MDIO
bus code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index 7e69c983d12a..ebf5d6429a8d 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -95,12 +95,6 @@ static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location,
 
 }
 
-static int fs_enet_fec_mii_reset(struct mii_bus *bus)
-{
-	/* nothing here - for now */
-	return 0;
-}
-
 static struct of_device_id fs_enet_mdio_fec_match[];
 static int fs_enet_mdio_probe(struct platform_device *ofdev)
 {
@@ -128,7 +122,6 @@ static int fs_enet_mdio_probe(struct platform_device *ofdev)
 	new_bus->name = "FEC MII Bus";
 	new_bus->read = &fs_enet_fec_mii_read;
 	new_bus->write = &fs_enet_fec_mii_write;
-	new_bus->reset = &fs_enet_fec_mii_reset;
 
 	ret = of_address_to_resource(ofdev->dev.of_node, 0, &res);
 	if (ret)
-- 
1.8.3.2
