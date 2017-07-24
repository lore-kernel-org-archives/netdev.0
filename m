From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 2/2] ftgmac100: Make the MDIO bus a child of the ethernet
 device
Date: Mon, 24 Jul 2017 16:59:07 +1000
Message-ID: <1500879547.10674.63.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joel Stanley <joel.stanley@au1.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39294 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752610AbdGXHuf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Jul 2017 03:50:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populate mii_bus->parent with our own platform device before
registering, which makes it easier to locate the MDIO bus
in sysfs when trying to diagnose problems.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 2b17f7023d91..fce0aa4f78b7 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1682,6 +1682,7 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 	priv->mii_bus->name = "ftgmac100_mdio";
 	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
 		 pdev->name, pdev->id);
+	priv->mii_bus->parent = priv->dev;
 	priv->mii_bus->priv = priv->netdev;
 	priv->mii_bus->read = ftgmac100_mdiobus_read;
 	priv->mii_bus->write = ftgmac100_mdiobus_write;
