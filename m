From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: toshiba: spider_net: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  5 Mar 2017 23:46:00 +0100
Message-ID: <1488753960-16452-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: kou.ishizaki@toshiba.co.jp, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/toshiba/spider_net_ethtool.c |   24 ++++++++++++--------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net_ethtool.c b/drivers/net/ethernet/toshiba/spider_net_ethtool.c
index ffe5193..16bd036 100644
--- a/drivers/net/ethernet/toshiba/spider_net_ethtool.c
+++ b/drivers/net/ethernet/toshiba/spider_net_ethtool.c
@@ -47,19 +47,23 @@
 };
 
 static int
-spider_net_ethtool_get_settings(struct net_device *netdev,
-			       struct ethtool_cmd *cmd)
+spider_net_ethtool_get_link_ksettings(struct net_device *netdev,
+				      struct ethtool_link_ksettings *cmd)
 {
 	struct spider_net_card *card;
 	card = netdev_priv(netdev);
 
-	cmd->supported   = (SUPPORTED_1000baseT_Full |
-			     SUPPORTED_FIBRE);
-	cmd->advertising = (ADVERTISED_1000baseT_Full |
-			     ADVERTISED_FIBRE);
-	cmd->port = PORT_FIBRE;
-	ethtool_cmd_speed_set(cmd, card->phy.speed);
-	cmd->duplex = DUPLEX_FULL;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, 1000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, FIBRE);
+
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, 1000baseT_Full);
+	ethtool_link_ksettings_add_link_mode(cmd, advertising, FIBRE);
+
+	cmd->base.port = PORT_FIBRE;
+	cmd->base.speed = card->phy.speed;
+	cmd->base.duplex = DUPLEX_FULL;
 
 	return 0;
 }
@@ -166,7 +170,6 @@ static void spider_net_get_strings(struct net_device *netdev, u32 stringset,
 }
 
 const struct ethtool_ops spider_net_ethtool_ops = {
-	.get_settings		= spider_net_ethtool_get_settings,
 	.get_drvinfo		= spider_net_ethtool_get_drvinfo,
 	.get_wol		= spider_net_ethtool_get_wol,
 	.get_msglevel		= spider_net_ethtool_get_msglevel,
@@ -177,5 +180,6 @@ static void spider_net_get_strings(struct net_device *netdev, u32 stringset,
 	.get_strings		= spider_net_get_strings,
 	.get_sset_count		= spider_net_get_sset_count,
 	.get_ethtool_stats	= spider_net_get_ethtool_stats,
+	.get_link_ksettings	= spider_net_ethtool_get_link_ksettings,
 };
 
-- 
1.7.4.4
