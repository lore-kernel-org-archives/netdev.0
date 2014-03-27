From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 10/14] net: sun4i: remove empty MDIO bus reset function
Date: Wed, 26 Mar 2014 18:07:22 -0700
Message-ID: <1395882446-552-11-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:53746 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756585AbaC0BIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:11 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so2618186pdj.13
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:11 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sun4i_mdio_reset() does nothing useful and is optional for the MDIO bus
code, so let's just remove it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-sun4i.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/phy/mdio-sun4i.c b/drivers/net/phy/mdio-sun4i.c
index 9367acc84fbb..15bc7f9ea224 100644
--- a/drivers/net/phy/mdio-sun4i.c
+++ b/drivers/net/phy/mdio-sun4i.c
@@ -90,11 +90,6 @@ static int sun4i_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	return 0;
 }
 
-static int sun4i_mdio_reset(struct mii_bus *bus)
-{
-	return 0;
-}
-
 static int sun4i_mdio_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -110,7 +105,6 @@ static int sun4i_mdio_probe(struct platform_device *pdev)
 	bus->name = "sun4i_mii_bus";
 	bus->read = &sun4i_mdio_read;
 	bus->write = &sun4i_mdio_write;
-	bus->reset = &sun4i_mdio_reset;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-mii", dev_name(&pdev->dev));
 	bus->parent = &pdev->dev;
 
-- 
1.8.3.2
