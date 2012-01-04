From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH v2] r6040: use an unique MDIO bus name
Date: Wed,  4 Jan 2012 19:50:40 +0100
Message-ID: <1325703040-15680-1-git-send-email-florian@openwrt.org>
References: <1325497800-21450-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, vova.kolpakov@gmail.com,
	Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:50633 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467Ab2ADSus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jan 2012 13:50:48 -0500
In-Reply-To: <1325497800-21450-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should use an unique MDIO bus name which does not clash with anything
else in the system like the Fixed MDIO bus. The bus is now named:
r6040-<card number> which is unique in the system.

Reported-by: Vladimir Kolpakov <vova.kolpakov@gmail.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v1:
- fixed snprintf arguments formatting

 drivers/net/ethernet/rdc/r6040.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 4bf68cf..a63b23f 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1188,7 +1188,8 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	lp->mii_bus->write = r6040_mdiobus_write;
 	lp->mii_bus->reset = r6040_mdiobus_reset;
 	lp->mii_bus->name = "r6040_eth_mii";
-	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%x", card_idx);
+	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		dev_name(&pdev->dev), card_idx);
 	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
 	if (!lp->mii_bus->irq) {
 		dev_err(&pdev->dev, "mii_bus irq allocation failed\n");
-- 
1.7.5.4
