From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 08/14] net: mvmdio: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:20 -0700
Message-ID: <1395882446-552-9-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:43796 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756510AbaC0BID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:03 -0400
Received: by mail-pb0-f52.google.com with SMTP id rr13so2715460pbb.39
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:03 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

orion_mdio_reset() does nothing useful and is optional for the MDIO bus
code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index fd409d76b811..b161a525fc5b 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -167,11 +167,6 @@ out:
 	return ret;
 }
 
-static int orion_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static irqreturn_t orion_mdio_err_irq(int irq, void *dev_id)
 {
 	struct orion_mdio_dev *dev = dev_id;
@@ -209,7 +204,6 @@ static int orion_mdio_probe(struct platform_device *pdev)
 	bus->name = "orion_mdio_bus";
 	bus->read = orion_mdio_read;
 	bus->write = orion_mdio_write;
-	bus->reset = orion_mdio_reset;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii",
 		 dev_name(&pdev->dev));
 	bus->parent = &pdev->dev;
-- 
1.8.3.2
