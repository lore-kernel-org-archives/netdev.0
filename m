From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/4] net: ethernet: gianfar: move to new ethtool api {get|set}_link_ksettings
Date: Sun,  1 May 2016 17:08:08 +0200
Message-ID: <1462115291-11372-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Philippe Reynes <tremyfr@gmail.com>
To: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	claudiu.manoil@freescale.com, leoli@freescale.com,
	treding@nvidia.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move the gianfar driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c |   25 +++++++---------------
 1 files changed, 8 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 4b0ee85..2c45c80 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -185,7 +185,8 @@ static void gfar_gdrvinfo(struct net_device *dev,
 }
 
 
-static int gfar_ssettings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int gfar_set_ksettings(struct net_device *dev,
+			      const struct ethtool_link_ksettings *cmd)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
@@ -193,29 +194,19 @@ static int gfar_ssettings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (NULL == phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(phydev, cmd);
+	return phy_ethtool_ksettings_set(phydev, cmd);
 }
 
-
-/* Return the current settings in the ethtool_cmd structure */
-static int gfar_gsettings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int gfar_get_ksettings(struct net_device *dev,
+			      struct ethtool_link_ksettings *cmd)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct phy_device *phydev = priv->phydev;
-	struct gfar_priv_rx_q *rx_queue = NULL;
-	struct gfar_priv_tx_q *tx_queue = NULL;
 
 	if (NULL == phydev)
 		return -ENODEV;
-	tx_queue = priv->tx_queue[0];
-	rx_queue = priv->rx_queue[0];
-
-	/* etsec-1.7 and older versions have only one txic
-	 * and rxic regs although they support multiple queues */
-	cmd->maxtxpkt = get_icft_value(tx_queue->txic);
-	cmd->maxrxpkt = get_icft_value(rx_queue->rxic);
 
-	return phy_ethtool_gset(phydev, cmd);
+	return phy_ethtool_ksettings_get(phydev, cmd);
 }
 
 /* Return the length of the register structure */
@@ -1565,8 +1556,6 @@ static int gfar_get_ts_info(struct net_device *dev,
 }
 
 const struct ethtool_ops gfar_ethtool_ops = {
-	.get_settings = gfar_gsettings,
-	.set_settings = gfar_ssettings,
 	.get_drvinfo = gfar_gdrvinfo,
 	.get_regs_len = gfar_reglen,
 	.get_regs = gfar_get_regs,
@@ -1589,4 +1578,6 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.set_rxnfc = gfar_set_nfc,
 	.get_rxnfc = gfar_get_nfc,
 	.get_ts_info = gfar_get_ts_info,
+	.get_link_ksettings = gfar_get_ksettings,
+	.set_link_ksettings = gfar_set_ksettings,
 };
-- 
1.7.4.4
