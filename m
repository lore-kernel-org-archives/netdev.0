From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/2] net: ethernet: bcmsysport: use phy_ethtool_{get|set}_link_ksettings
Date: Sun, 19 Jun 2016 20:39:09 +0200
Message-ID: <1466361549-6291-2-git-send-email-tremyfr@gmail.com>
References: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466361549-6291-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two generics functions phy_ethtool_{get|set}_link_ksettings,
so we can use them instead of defining the same code in the driver.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 9775c78..834afbb 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -96,24 +96,6 @@ static inline void tdma_port_write_desc_addr(struct bcm_sysport_priv *priv,
 }
 
 /* Ethtool operations */
-static int bcm_sysport_set_settings(struct net_device *dev,
-				    struct ethtool_cmd *cmd)
-{
-	if (!netif_running(dev))
-		return -EINVAL;
-
-	return phy_ethtool_sset(dev->phydev, cmd);
-}
-
-static int bcm_sysport_get_settings(struct net_device *dev,
-				    struct ethtool_cmd *cmd)
-{
-	if (!netif_running(dev))
-		return -EINVAL;
-
-	return phy_ethtool_gset(dev->phydev, cmd);
-}
-
 static int bcm_sysport_set_rx_csum(struct net_device *dev,
 				   netdev_features_t wanted)
 {
@@ -1711,8 +1693,6 @@ static int bcm_sysport_stop(struct net_device *dev)
 }
 
 static struct ethtool_ops bcm_sysport_ethtool_ops = {
-	.get_settings		= bcm_sysport_get_settings,
-	.set_settings		= bcm_sysport_set_settings,
 	.get_drvinfo		= bcm_sysport_get_drvinfo,
 	.get_msglevel		= bcm_sysport_get_msglvl,
 	.set_msglevel		= bcm_sysport_set_msglvl,
@@ -1724,6 +1704,8 @@ static struct ethtool_ops bcm_sysport_ethtool_ops = {
 	.set_wol		= bcm_sysport_set_wol,
 	.get_coalesce		= bcm_sysport_get_coalesce,
 	.set_coalesce		= bcm_sysport_set_coalesce,
+	.get_link_ksettings     = phy_ethtool_get_link_ksettings,
+	.set_link_ksettings     = phy_ethtool_set_link_ksettings,
 };
 
 static const struct net_device_ops bcm_sysport_netdev_ops = {
-- 
1.7.4.4
