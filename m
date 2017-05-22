From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v2 1/4] net-next: stmmac: Convert new_state to bool
Date: Mon, 22 May 2017 14:33:44 +0200
Message-ID: <20170522123347.5295-2-clabbe.montjoie@gmail.com>
References: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34883 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753319AbdEVMgl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 08:36:41 -0400
In-Reply-To: <20170522123347.5295-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch convert new_state from int to bool since it store only 1 or 0

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 1da17cd519f6..94b37323844b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -785,7 +785,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 	struct stmmac_priv *priv = netdev_priv(dev);
 	struct phy_device *phydev = dev->phydev;
 	unsigned long flags;
-	int new_state = 0;
+	bool new_state = false;
 
 	if (!phydev)
 		return;
@@ -798,7 +798,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
 		if (phydev->duplex != priv->oldduplex) {
-			new_state = 1;
+			new_state = true;
 			if (!(phydev->duplex))
 				ctrl &= ~priv->hw->link.duplex;
 			else
@@ -810,7 +810,7 @@ static void stmmac_adjust_link(struct net_device *dev)
 			stmmac_mac_flow_ctrl(priv, phydev->duplex);
 
 		if (phydev->speed != priv->speed) {
-			new_state = 1;
+			new_state = true;
 			switch (phydev->speed) {
 			case 1000:
 				if (priv->plat->has_gmac ||
@@ -849,11 +849,11 @@ static void stmmac_adjust_link(struct net_device *dev)
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
