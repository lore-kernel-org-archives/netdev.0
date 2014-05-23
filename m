From: <Wei.Yang@windriver.com>
Subject: [PATCH v1] net: driver: stmicro: Remove some useless the lock protection
Date: Fri, 23 May 2014 19:05:03 +0800
Message-ID: <1400843103-19433-1-git-send-email-Wei.Yang@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yang Wei <Wei.Yang@windriver.com>

kernel always invokes a pair of rtnl_lock adn rtnl_unlock to
protect dev_ethtool(), so its not neccessary to invoke spin_lock/unlock
in ethtool_ops.

Signed-off-by: Yang Wei <Wei.Yang@windriver.com>
---

 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index a49339d..a2f19e1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -231,9 +231,7 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 		return -EBUSY;
 	}
 	cmd->transceiver = XCVR_INTERNAL;
-	spin_lock_irq(&priv->lock);
 	rc = phy_ethtool_gset(phy, cmd);
-	spin_unlock_irq(&priv->lock);
 	return rc;
 }
 
@@ -244,9 +242,7 @@ static int stmmac_ethtool_setsettings(struct net_device *dev,
 	struct phy_device *phy = priv->phydev;
 	int rc;
 
-	spin_lock(&priv->lock);
 	rc = phy_ethtool_sset(phy, cmd);
-	spin_unlock(&priv->lock);
 
 	return rc;
 }
@@ -313,7 +309,6 @@ stmmac_get_pauseparam(struct net_device *netdev,
 {
 	struct stmmac_priv *priv = netdev_priv(netdev);
 
-	spin_lock(&priv->lock);
 
 	pause->rx_pause = 0;
 	pause->tx_pause = 0;
@@ -324,7 +319,6 @@ stmmac_get_pauseparam(struct net_device *netdev,
 	if (priv->flow_ctrl & FLOW_TX)
 		pause->tx_pause = 1;
 
-	spin_unlock(&priv->lock);
 }
 
 static int
@@ -336,7 +330,6 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	int new_pause = FLOW_OFF;
 	int ret = 0;
 
-	spin_lock(&priv->lock);
 
 	if (pause->rx_pause)
 		new_pause |= FLOW_RX;
@@ -352,7 +345,6 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	} else
 		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
 					 priv->flow_ctrl, priv->pause);
-	spin_unlock(&priv->lock);
 	return ret;
 }
 
-- 
1.7.9.5
