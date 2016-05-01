From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 2/4] net: ethernet: ucc: move to new ethtool api {get|set}_link_ksettings
Date: Sun,  1 May 2016 17:08:09 +0200
Message-ID: <1462115291-11372-2-git-send-email-tremyfr@gmail.com>
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
We move the ucc driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c |   17 +++++++----------
 1 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index 89714f5..812a968 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -105,23 +105,20 @@ static const char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 #define UEC_RX_FW_STATS_LEN ARRAY_SIZE(rx_fw_stat_gstrings)
 
 static int
-uec_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+uec_get_ksettings(struct net_device *netdev, struct ethtool_link_ksettings *cmd)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(netdev);
 	struct phy_device *phydev = ugeth->phydev;
-	struct ucc_geth_info *ug_info = ugeth->ug_info;
 
 	if (!phydev)
 		return -ENODEV;
 
-	ecmd->maxtxpkt = 1;
-	ecmd->maxrxpkt = ug_info->interruptcoalescingmaxvalue[0];
-
-	return phy_ethtool_gset(phydev, ecmd);
+	return phy_ethtool_ksettings_get(phydev, cmd);
 }
 
 static int
-uec_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+uec_set_ksettings(struct net_device *netdev,
+		  const struct ethtool_link_ksettings *cmd)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(netdev);
 	struct phy_device *phydev = ugeth->phydev;
@@ -129,7 +126,7 @@ uec_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	if (!phydev)
 		return -ENODEV;
 
-	return phy_ethtool_sset(phydev, ecmd);
+	return phy_ethtool_ksettings_set(phydev, cmd);
 }
 
 static void
@@ -392,8 +389,6 @@ static int uec_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 #endif /* CONFIG_PM */
 
 static const struct ethtool_ops uec_ethtool_ops = {
-	.get_settings           = uec_get_settings,
-	.set_settings           = uec_set_settings,
 	.get_drvinfo            = uec_get_drvinfo,
 	.get_regs_len           = uec_get_regs_len,
 	.get_regs               = uec_get_regs,
@@ -411,6 +406,8 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_wol		= uec_get_wol,
 	.set_wol		= uec_set_wol,
 	.get_ts_info		= ethtool_op_get_ts_info,
+	.get_link_ksettings	= uec_get_ksettings,
+	.set_link_ksettings	= uec_set_ksettings,
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.4.4
