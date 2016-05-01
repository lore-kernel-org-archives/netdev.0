From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 4/4] net: ethernet: fec_mpc52xx: move to new ethtool api {get|set}_link_ksettings
Date: Sun,  1 May 2016 17:08:11 +0200
Message-ID: <1462115291-11372-4-git-send-email-tremyfr@gmail.com>
References: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Philippe Reynes <tremyfr@gmail.com>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	claudiu.manoil@freescale.com, leoli@freescale.com,
	treding@nvidia.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move the fec_mpc52xx driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 25553ee..f444714 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -763,24 +763,28 @@ static void mpc52xx_fec_reset(struct net_device *dev)
 
 /* ethtool interface */
 
-static int mpc52xx_fec_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mpc52xx_fec_get_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
 
 	if (!priv->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_gset(priv->phydev, cmd);
+	return phy_ethtool_ksettings_get(phydev, cmd);
 }
 
-static int mpc52xx_fec_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mpc52xx_fec_set_ksettings(struct net_device *dev,
+				     const struct ethtool_link_ksettings *cmd)
 {
 	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
 
 	if (!priv->phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(priv->phydev, cmd);
+	return phy_ethtool_ksettings_set(phydev, cmd);
 }
 
 static u32 mpc52xx_fec_get_msglevel(struct net_device *dev)
@@ -796,12 +800,12 @@ static void mpc52xx_fec_set_msglevel(struct net_device *dev, u32 level)
 }
 
 static const struct ethtool_ops mpc52xx_fec_ethtool_ops = {
-	.get_settings = mpc52xx_fec_get_settings,
-	.set_settings = mpc52xx_fec_set_settings,
 	.get_link = ethtool_op_get_link,
 	.get_msglevel = mpc52xx_fec_get_msglevel,
 	.set_msglevel = mpc52xx_fec_set_msglevel,
 	.get_ts_info = ethtool_op_get_ts_info,
+	.get_link_ksettings = mpc52xx_fec_get_ksettings,
+	.set_link_ksettings = mpc52xx_fec_set_ksettings,
 };
 
 
-- 
1.7.4.4
