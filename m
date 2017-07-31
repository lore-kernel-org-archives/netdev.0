From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/7] net: phy: mdio-bcm-unimac: create unique bus names
Date: Mon, 31 Jul 2017 12:04:23 -0700
Message-ID: <20170731190429.24204-3-f.fainelli@gmail.com>
References: <20170731190429.24204-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com, jaedon.shin@gmail.com,
        pgynther@google.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32834 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751114AbdGaTEm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 15:04:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id q189so26005329wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 12:04:41 -0700 (PDT)
In-Reply-To: <20170731190429.24204-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for having multiple GENET instances in a system (up to
3), make sure that we do include the bus instance number in the name of
the MDIO bus such that we change it from "unimac-mdio" to
"unimac-mdio-0" for instance.

So far, the only user of this driver is using Device Tree, which uses a
lookup/parenting based technique to map PHY devices to their respective
MDIO bus controllers, hence causing no additional changes.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/mdio-bcm-unimac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 226fdccfa1a8..97cac10bd0d5 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -197,7 +197,7 @@ static int unimac_mdio_probe(struct platform_device *pdev)
 	bus->read = unimac_mdio_read;
 	bus->write = unimac_mdio_write;
 	bus->reset = unimac_mdio_reset;
-	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+	snprintf(bus->id, MII_BUS_ID_SIZE, "%s-%d", pdev->name, pdev->id);
 
 	ret = of_mdiobus_register(bus, np);
 	if (ret) {
-- 
2.9.3
