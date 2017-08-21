From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v2 1/2] net: stmmac: Delete dead code for MDIO registration
Date: Mon, 21 Aug 2017 13:45:29 +0200
Message-ID: <20170821114530.13706-2-romain.perier@collabora.com>
References: <20170821114530.13706-1-romain.perier@collabora.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821114530.13706-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code is no longer used, the logging function was changed by commit
fbca164776e4 ("net: stmmac: Use the right logging functi").

Fixes: fbca164776e4 ("net: stmmac: Use the right logging functi")
Signed-off-by: Romain Perier <romain.perier@collabora.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index 72ec711fcba2..f5f37bfa1d58 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -248,9 +248,6 @@ int stmmac_mdio_register(struct net_device *ndev)
 	found = 0;
 	for (addr = 0; addr < PHY_MAX_ADDR; addr++) {
 		struct phy_device *phydev = mdiobus_get_phy(new_bus, addr);
-		int act = 0;
-		char irq_num[4];
-		char *irq_str;
 
 		if (!phydev)
 			continue;
@@ -273,19 +270,6 @@ int stmmac_mdio_register(struct net_device *ndev)
 		if (priv->plat->phy_addr == -1)
 			priv->plat->phy_addr = addr;
 
-		act = (priv->plat->phy_addr == addr);
-		switch (phydev->irq) {
-		case PHY_POLL:
-			irq_str = "POLL";
-			break;
-		case PHY_IGNORE_INTERRUPT:
-			irq_str = "IGNORE";
-			break;
-		default:
-			sprintf(irq_num, "%d", phydev->irq);
-			irq_str = irq_num;
-			break;
-		}
 		phy_attached_info(phydev);
 		found = 1;
 	}
-- 
2.11.0
