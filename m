From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 3/8] net: stmmac: use SPEED_UNKNOWN/DUPLEX_UNKNOWN
Date: Tue, 14 Feb 2017 20:54:36 +0100
Message-ID: <20170214195441.30425-4-clabbe.montjoie@gmail.com>
References: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35767 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754154AbdBNT5X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:57:23 -0500
In-Reply-To: <20170214195441.30425-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is better to use DUPLEX_UNKNOWN instead of just "-1".
Using 0 for an invalid speed is bad since 0 is a valid value for speed.
So this patch replace 0 by SPEED_UNKNOWN.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 511c47c..a87071d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -754,8 +754,8 @@ static void stmmac_adjust_link(struct net_device *dev)
 	} else if (priv->oldlink) {
 		new_state = 1;
 		priv->oldlink = 0;
-		priv->speed = 0;
-		priv->oldduplex = -1;
+		priv->speed = SPEED_UNKNOWN;
+		priv->oldduplex = DUPLEX_UNKNOWN;
 	}
 
 	if (new_state && netif_msg_link(priv))
@@ -817,8 +817,8 @@ static int stmmac_init_phy(struct net_device *dev)
 	int interface = priv->plat->interface;
 	int max_speed = priv->plat->max_speed;
 	priv->oldlink = 0;
-	priv->speed = 0;
-	priv->oldduplex = -1;
+	priv->speed = SPEED_UNKNOWN;
+	priv->oldduplex = DUPLEX_UNKNOWN;
 
 	if (priv->plat->phy_node) {
 		phydev = of_phy_connect(dev, priv->plat->phy_node,
@@ -3434,8 +3434,8 @@ int stmmac_suspend(struct device *dev)
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	priv->oldlink = 0;
-	priv->speed = 0;
-	priv->oldduplex = -1;
+	priv->speed = SPEED_UNKNOWN;
+	priv->oldduplex = DUPLEX_UNKNOWN;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(stmmac_suspend);
-- 
2.10.2
