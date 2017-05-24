From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v3 1/5] net-next: stmmac: Convert new_state to bool
Date: Wed, 24 May 2017 09:16:43 +0200
Message-ID: <20170524071647.7921-2-clabbe.montjoie@gmail.com>
References: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch convert new_state from int to bool since it store only 1 or 0

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b77a56b6ab70..9579592b6b6f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -786,7 +786,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
-	int new_state = 0;
+	bool new_state = false;
 
 	if (!phydev)
 		return;
@@ -799,7 +799,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
-			new_state = 1;
+			new_state = true;
 			if (!(phydev->duplex))
 				ctrl &= ~priv->hw->link.duplex;
 			else
@@ -811,7 +811,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			stmmac_mac_flow_ctrl(priv, phydev->duplex);
 
 		if (phydev->speed != priv->speed) {
-			new_state = 1;
+			new_state = true;
 			switch (phydev->speed) {
 			case 1000:
 				if (priv->plat->has_gmac ||
@@ -850,11 +850,11 @@ static void stmmac_adjust_link(struct net_device *dev)
 		writel(ctrl, priv->ioaddr + MAC_CTRL_REG);
 
 		if (!priv->oldlink) {
-			new_state = 1;
+			new_state = true;
 			priv->oldlink = 1;
 		}
 	} else if (priv->oldlink) {
-		new_state = 1;
+		new_state = true;
 		priv->oldlink = 0;
 		priv->speed = SPEED_UNKNOWN;
 		priv->oldduplex = DUPLEX_UNKNOWN;
-- 
2.13.0
