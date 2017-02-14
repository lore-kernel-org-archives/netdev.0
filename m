From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 7/8] net: stmmac: reduce indentation by adding a continue
Date: Tue, 14 Feb 2017 20:54:40 +0100
Message-ID: <20170214195441.30425-8-clabbe.montjoie@gmail.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34255 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754181AbdBNT5X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:57:23 -0500
In-Reply-To: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Joe Perches, replacing the "if phydev" logic permit to
reduce indentation in the for loop.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 82 +++++++++++------------
 1 file changed, 40 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index a695773..db157a4 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -247,50 +247,48 @@ int stmmac_mdio_register(struct net_device *ndev)
 	found = 0;
 	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
 		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
+		int act = 0;
+		char irq_num[4];
+		char *irq_str;
+
+		if (!phydev)
+			continue;
+
+		/*
+		 * If an IRQ was provided to be assigned after
+		 * the bus probe, do it here.
+		 */
+		if (!mdio_bus_data->irqs &&
+		    (mdio_bus_data->probed_phy_irq > 0)) {
+			new_bus->irq[addr] = mdio_bus_data->probed_phy_irq;
+			phydev->irq = mdio_bus_data->probed_phy_irq;
+		}
 
-		if (phydev) {
-			int act = 0;
-			char irq_num[4];
-			char *irq_str;
-
-			/*
-			 * If an IRQ was provided to be assigned after
-			 * the bus probe, do it here.
-			 */
-			if (!mdio_bus_data->irqs &&
-			    (mdio_bus_data->probed_phy_irq > 0)) {
-				new_bus->irq[addr] =
-					mdio_bus_data->probed_phy_irq;
-				phydev->irq = mdio_bus_data->probed_phy_irq;
-			}
-
-			/*
-			 * If we're going to bind the MAC to this PHY bus,
-			 * and no PHY number was provided to the MAC,
-			 * use the one probed here.
-			 */
-			if (priv->plat->phy_addr == -1)
-				priv->plat->phy_addr = addr;
-
-			act = (priv->plat->phy_addr == addr);
-			switch (phydev->irq) {
-			case PHY_POLL:
-				irq_str = "POLL";
-				break;
-			case PHY_IGNORE_INTERRUPT:
-				irq_str = "IGNORE";
-				break;
-			default:
-				sprintf(irq_num, "%d", phydev->irq);
-				irq_str = irq_num;
-				break;
-			}
-			netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
-				    phydev->phy_id, addr,
-				    irq_str, phydev_name(phydev),
-				    act ? " active" : "");
-			found = 1;
+		/*
+		 * If we're going to bind the MAC to this PHY bus,
+		 * and no PHY number was provided to the MAC,
+		 * use the one probed here.
+		 */
+		if (priv->plat->phy_addr == -1)
+			priv->plat->phy_addr = addr;
+
+		act = (priv->plat->phy_addr == addr);
+		switch (phydev->irq) {
+		case PHY_POLL:
+			irq_str = "POLL";
+			break;
+		case PHY_IGNORE_INTERRUPT:
+			irq_str = "IGNORE";
+			break;
+		default:
+			sprintf(irq_num, "%d", phydev->irq);
+			irq_str = irq_num;
+			break;
 		}
+		netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
+			    phydev->phy_id, addr, irq_str, phydev_name(phydev),
+			    act ? " active" : "");
+		found = 1;
 	}
 
 	if (!found && !mdio_node) {
-- 
2.10.2
