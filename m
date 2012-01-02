From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: use an unique MDIO bus name
Date: Mon,  2 Jan 2012 10:50:00 +0100
Message-ID: <1325497800-21450-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, vova.kolpakov@gmail.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:59633 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009Ab2ABJ7j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jan 2012 04:59:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should use an unique MDIO bus name which does not clash with anything
else in the system like the Fixed MDIO bus. The bus is now named:
<dev_name>-<card number> which is unique in the system.

Reported-by: Vladimir Kolpakov <vova.kolpakov@gmail.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4bf68cf..de5e923 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1188,7 +1188,8 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	lp->mii_bus->write = r6040_mdiobus_write;
 	lp->mii_bus->reset = r6040_mdiobus_reset;
 	lp->mii_bus->name = "r6040_eth_mii";
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%x", card_idx);
+	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+					dev_name(&pdev->dev), card_idx);
 	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!lp->mii_bus->irq) {
 		dev_err(&pdev->dev, "mii_bus irq allocation failed\n");
-- 
1.7.5.4
