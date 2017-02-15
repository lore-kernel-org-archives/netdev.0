From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 7/8] net: stmmac: reduce indentation by adding a continue
Date: Wed, 15 Feb 2017 10:46:44 +0100
Message-ID: <20170215094645.591-8-clabbe.montjoie@gmail.com>
References: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215094645.591-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As suggested by Joe Perches, replacing the "if phydev" logic permit to
reduce indentation in the for loop.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
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
