From: Pavel Machek <pavel@ucw.cz>
Subject: [PATCH] stmmac: simple cleanups
Date: Tue, 19 Aug 2014 12:56:46 +0200
Message-ID: <20140819105646.GA27984@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:40742 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaHSK4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 06:56:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This adds simple cleanups for stmmac, removing test we know is always
true, fixing whitespace, and moving code out of if().

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index c62e67f..5041090 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -261,11 +261,11 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 		ethtool_cmd_speed_set(cmd, priv->xstats.pcs_speed);
 
 		/* Get and convert ADV/LP_ADV from the HW AN registers */
-		if (priv->hw->mac->get_adv)
-			priv->hw->mac->get_adv(priv->ioaddr, &adv);
-		else
+		if (!priv->hw->mac->get_adv)
 			return -EOPNOTSUPP;	/* should never happen indeed */
 
+		priv->hw->mac->get_adv(priv->ioaddr, &adv);
+
 		/* Encoding of PSE bits is defined in 802.3z, 37.2.1.4 */
 
 		if (adv.pause & STMMAC_PCS_PAUSE)
@@ -340,20 +340,17 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 		if (cmd->autoneg != AUTONEG_ENABLE)
 			return -EINVAL;
 
-		if (cmd->autoneg == AUTONEG_ENABLE) {
-			mask &= (ADVERTISED_1000baseT_Half |
-			ADVERTISED_1000baseT_Full |
-			ADVERTISED_100baseT_Half |
-			ADVERTISED_100baseT_Full |
-			ADVERTISED_10baseT_Half |
-			ADVERTISED_10baseT_Full);
-
-			spin_lock(&priv->lock);
-			if (priv->hw->mac->ctrl_ane)
-				priv->hw->mac->ctrl_ane(priv->ioaddr, 1);
-			spin_unlock(&priv->lock);
-		}
-
+		mask &= (ADVERTISED_1000baseT_Half |
+			 ADVERTISED_1000baseT_Full |
+			 ADVERTISED_100baseT_Half |
+			 ADVERTISED_100baseT_Full |
+			 ADVERTISED_10baseT_Half |
+			 ADVERTISED_10baseT_Full);
+
+		spin_lock(&priv->lock);
+		if (priv->hw->mac->ctrl_ane)
+			priv->hw->mac->ctrl_ane(priv->ioaddr, 1);
+		spin_unlock(&priv->lock);
 		return 0;
 	}
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 057a120..749d923 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -818,7 +818,7 @@ static int stmmac_init_phy(struct net_device *dev)
 	/* Stop Advertising 1000BASE Capability if interface is not GMII */
 	if ((interface == PHY_INTERFACE_MODE_MII) ||
 	    (interface == PHY_INTERFACE_MODE_RMII) ||
-		(max_speed < 1000 &&  max_speed > 0))
+		(max_speed < 1000 && max_speed > 0))
 		phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
 					 SUPPORTED_1000baseT_Full);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index a5b1e1b..8dd0408 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -253,7 +253,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 			}
 
 			/*
-			 * If we're  going to bind the MAC to this PHY bus,
+			 * If we're going to bind the MAC to this PHY bus,
 			 * and no PHY number was provided to the MAC,
 			 * use the one probed here.
 			 */

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
