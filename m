From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: renesas: sh_eth: use new api ethtool_{get|set}_link_ksettings
Date: Wed, 10 Aug 2016 00:04:49 +0200
Message-ID: <1470780289-27496-2-git-send-email-tremyfr@gmail.com>
References: <1470780289-27496-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net,
	horms+renesas@verge.net.au, geert+renesas@glider.be, andrew@lunn.ch
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1470780289-27496-1-git-send-email-tremyfr@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 901ed36..1f8240a 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1817,8 +1817,8 @@ static int sh_eth_phy_start(struct net_device *ndev)
 	return 0;
 }
 
-static int sh_eth_get_settings(struct net_device *ndev,
-			       struct ethtool_cmd *ecmd)
+static int sh_eth_get_link_ksettings(struct net_device *ndev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	unsigned long flags;
@@ -1828,14 +1828,14 @@ static int sh_eth_get_settings(struct net_device *ndev,
 		return -ENODEV;
 
 	spin_lock_irqsave(&mdp->lock, flags);
-	ret = phy_ethtool_gset(ndev->phydev, ecmd);
+	ret = phy_ethtool_ksettings_get(ndev->phydev, cmd);
 	spin_unlock_irqrestore(&mdp->lock, flags);
 
 	return ret;
 }
 
-static int sh_eth_set_settings(struct net_device *ndev,
-			       struct ethtool_cmd *ecmd)
+static int sh_eth_set_link_ksettings(struct net_device *ndev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	unsigned long flags;
@@ -1849,11 +1849,11 @@ static int sh_eth_set_settings(struct net_device *ndev,
 	/* disable tx and rx */
 	sh_eth_rcv_snd_disable(ndev);
 
-	ret = phy_ethtool_sset(ndev->phydev, ecmd);
+	ret = phy_ethtool_ksettings_set(ndev->phydev, cmd);
 	if (ret)
 		goto error_exit;
 
-	if (ecmd->duplex == DUPLEX_FULL)
+	if (cmd->base.duplex == DUPLEX_FULL)
 		mdp->duplex = 1;
 	else
 		mdp->duplex = 0;
@@ -2195,8 +2195,6 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 }
 
 static const struct ethtool_ops sh_eth_ethtool_ops = {
-	.get_settings	= sh_eth_get_settings,
-	.set_settings	= sh_eth_set_settings,
 	.get_regs_len	= sh_eth_get_regs_len,
 	.get_regs	= sh_eth_get_regs,
 	.nway_reset	= sh_eth_nway_reset,
@@ -2208,6 +2206,8 @@ static const struct ethtool_ops sh_eth_ethtool_ops = {
 	.get_sset_count     = sh_eth_get_sset_count,
 	.get_ringparam	= sh_eth_get_ringparam,
 	.set_ringparam	= sh_eth_set_ringparam,
+	.get_link_ksettings = sh_eth_get_link_ksettings,
+	.set_link_ksettings = sh_eth_set_link_ksettings,
 };
 
 /* network device open function */
-- 
1.7.4.4
