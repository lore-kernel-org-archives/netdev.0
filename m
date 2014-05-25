From: <Wei.Yang@windriver.com>
Subject: [PATCH v2] net: driver: stmicro: Remove some useless the lock protection
Date: Sun, 25 May 2014 09:53:44 +0800
Message-ID: <1400982824-3871-1-git-send-email-Wei.Yang@windriver.com>
References: <20140523.160945.226886017757584215.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <peppe.cavallaro@st.com>, <wei.yang@windriver.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:36211 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaEYBx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 21:53:56 -0400
In-Reply-To: <20140523.160945.226886017757584215.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Wei <Wei.Yang@windriver.com>

kernel always invokes a pair of rtnl_lock adn rtnl_unlock to
protect dev_ethtool(), so its not neccessary to invoke spin_lock/unlock
in ethtool_ops.

Signed-off-by: Yang Wei <Wei.Yang@windriver.com>
---
Hi David,

   I regenerate this patch based on net/next repo in v2.

Wei
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index c963394..7892666 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -322,9 +322,7 @@ static int stmmac_ethtool_getsettings(struct net_device *dev,
 		return -EBUSY;
 	}
 	cmd->transceiver = XCVR_INTERNAL;
-	spin_lock_irq(&priv->lock);
 	rc = phy_ethtool_gset(phy, cmd);
-	spin_unlock_irq(&priv->lock);
 	return rc;
 }
 
@@ -442,7 +440,6 @@ stmmac_get_pauseparam(struct net_device *netdev,
 	if (priv->flow_ctrl & FLOW_TX)
 		pause->tx_pause = 1;
 
-	spin_unlock(&priv->lock);
 }
 
 static int
@@ -457,8 +454,6 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	if (priv->pcs)	/* FIXME */
 		return -EOPNOTSUPP;
 
-	spin_lock(&priv->lock);
-
 	if (pause->rx_pause)
 		new_pause |= FLOW_RX;
 	if (pause->tx_pause)
@@ -473,7 +468,6 @@ stmmac_set_pauseparam(struct net_device *netdev,
 	} else
 		priv->hw->mac->flow_ctrl(priv->ioaddr, phy->duplex,
 					 priv->flow_ctrl, priv->pause);
-	spin_unlock(&priv->lock);
 	return ret;
 }
 
-- 
1.7.9.5
