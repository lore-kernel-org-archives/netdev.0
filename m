From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next] mdio_bus: Remove unneeded gpiod NULL check
Date: Mon, 17 Jul 2017 18:09:09 -0300
Message-ID: <1500325749-8382-1-git-send-email-festevam@gmail.com>
Cc: andrew@lunn.ch, f.fainelli@gmail.com, netdev@vger.kernel.org,
        Fabio Estevam <fabio.estevam@nxp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34801 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdGQVJX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 17:09:23 -0400
Received: by mail-qk0-f195.google.com with SMTP id q66so235439qki.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 14:09:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@nxp.com>

The gpiod API checks for NULL descriptors, so there is no need to
duplicate the check in the driver.

Signed-off-by: Fabio Estevam <fabio.estevam@nxp.com>
---
 drivers/net/phy/mdio_bus.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 2df7b62c..b6f9fa6 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -399,8 +399,7 @@ int __mdiobus_register(struct mii_bus *bus, struct module *owner)
 	}
 
 	/* Put PHYs in RESET to save power */
-	if (bus->reset_gpiod)
-		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
+	gpiod_set_value_cansleep(bus->reset_gpiod, 1);
 
 	device_del(&bus->dev);
 	return err;
@@ -425,8 +424,7 @@ void mdiobus_unregister(struct mii_bus *bus)
 	}
 
 	/* Put PHYs in RESET to save power */
-	if (bus->reset_gpiod)
-		gpiod_set_value_cansleep(bus->reset_gpiod, 1);
+	gpiod_set_value_cansleep(bus->reset_gpiod, 1);
 
 	device_del(&bus->dev);
 }
-- 
2.7.4
