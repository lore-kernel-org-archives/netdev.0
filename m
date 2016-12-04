From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: calxeda: xgmac: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  4 Dec 2016 23:37:53 +0100
Message-ID: <1480891073-23166-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, jarod@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/calxeda/xgmac.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 6e72366..ce7de6f 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1530,15 +1530,14 @@ static int xgmac_set_features(struct net_device *dev, netdev_features_t features
 	.ndo_set_features = xgmac_set_features,
 };
 
-static int xgmac_ethtool_getsettings(struct net_device *dev,
-					  struct ethtool_cmd *cmd)
+static int xgmac_ethtool_get_link_ksettings(struct net_device *dev,
+					    struct ethtool_link_ksettings *cmd)
 {
-	cmd->autoneg = 0;
-	cmd->duplex = DUPLEX_FULL;
-	ethtool_cmd_speed_set(cmd, 10000);
-	cmd->supported = 0;
-	cmd->advertising = 0;
-	cmd->transceiver = XCVR_INTERNAL;
+	cmd->base.autoneg = 0;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.speed = 10000;
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported, 0);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising, 0);
 	return 0;
 }
 
@@ -1681,7 +1680,6 @@ static int xgmac_set_wol(struct net_device *dev,
 }
 
 static const struct ethtool_ops xgmac_ethtool_ops = {
-	.get_settings = xgmac_ethtool_getsettings,
 	.get_link = ethtool_op_get_link,
 	.get_pauseparam = xgmac_get_pauseparam,
 	.set_pauseparam = xgmac_set_pauseparam,
@@ -1690,6 +1688,7 @@ static int xgmac_set_wol(struct net_device *dev,
 	.get_wol = xgmac_get_wol,
 	.set_wol = xgmac_set_wol,
 	.get_sset_count = xgmac_get_sset_count,
+	.get_link_ksettings = xgmac_ethtool_get_link_ksettings,
 };
 
 /**
-- 
1.7.4.4
