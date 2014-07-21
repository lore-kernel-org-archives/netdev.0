From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [RFC 1/2] net: phy: Set the driver when registering an MDIO bus device
Date: Mon, 21 Jul 2014 15:26:09 -0300
Message-ID: <1405967170-19353-2-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55872 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933219AbaGUS1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 14:27:11 -0400
In-Reply-To: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdiobus_register() registers a device which is already bound to a driver.
Hence, the driver pointer should be set properly in order to track down
the driver associated to the MDIO bus.

This will be used to allow ethernet driver to pin down a MDIO bus driver,
preventing it from being unloaded while the PHY device is running.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/phy/mdio_bus.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 4eaadcf..203651e 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -255,6 +255,7 @@ int mdiobus_register(struct mii_bus *bus)
 
 	bus->dev.parent = bus->parent;
 	bus->dev.class = &mdio_bus_class;
+	bus->dev.driver = bus->parent->driver;
 	bus->dev.groups = NULL;
 	dev_set_name(&bus->dev, "%s", bus->id);
 
-- 
2.0.1
