From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: ti: cpsw: use new api ethtool_{get|set}_link_ksettings
Date: Sat,  8 Oct 2016 17:46:15 +0200
Message-ID: <1475941575-26590-1-git-send-email-tremyfr@gmail.com>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index c6cff3d..6d4b8a2 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1967,27 +1967,30 @@ static int cpsw_get_ts_info(struct net_device *ndev,
 	return 0;
 }
 
-static int cpsw_get_settings(struct net_device *ndev,
-			     struct ethtool_cmd *ecmd)
+static int cpsw_get_link_ksettings(struct net_device *ndev,
+				   struct ethtool_link_ksettings *ecmd)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
 	int slave_no = cpsw_slave_index(cpsw, priv);
 
 	if (cpsw->slaves[slave_no].phy)
-		return phy_ethtool_gset(cpsw->slaves[slave_no].phy, ecmd);
+		return phy_ethtool_ksettings_get(cpsw->slaves[slave_no].phy,
+						 ecmd);
 	else
 		return -EOPNOTSUPP;
 }
 
-static int cpsw_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+static int cpsw_set_link_ksettings(struct net_device *ndev,
+				   const struct ethtool_link_ksettings *ecmd)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
 	int slave_no = cpsw_slave_index(cpsw, priv);
 
 	if (cpsw->slaves[slave_no].phy)
-		return phy_ethtool_sset(cpsw->slaves[slave_no].phy, ecmd);
+		return phy_ethtool_ksettings_set(cpsw->slaves[slave_no].phy,
+						 ecmd);
 	else
 		return -EOPNOTSUPP;
 }
@@ -2245,8 +2248,6 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.set_msglevel	= cpsw_set_msglevel,
 	.get_link	= ethtool_op_get_link,
 	.get_ts_info	= cpsw_get_ts_info,
-	.get_settings	= cpsw_get_settings,
-	.set_settings	= cpsw_set_settings,
 	.get_coalesce	= cpsw_get_coalesce,
 	.set_coalesce	= cpsw_set_coalesce,
 	.get_sset_count		= cpsw_get_sset_count,
@@ -2262,6 +2263,8 @@ static const struct ethtool_ops cpsw_ethtool_ops = {
 	.complete	= cpsw_ethtool_op_complete,
 	.get_channels	= cpsw_get_channels,
 	.set_channels	= cpsw_set_channels,
+	.get_link_ksettings	= cpsw_get_link_ksettings,
+	.set_link_ksettings	= cpsw_set_link_ksettings,
 };
 
 static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_common *cpsw,
-- 
1.7.4.4
