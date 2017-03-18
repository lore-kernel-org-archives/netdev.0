From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: veth: use new api ethtool_{get|set}_link_ksettings
Date: Sat, 18 Mar 2017 12:13:26 +0100
Message-ID: <1489835606-23692-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, lucien.xin@gmail.com, jarod@redhat.com,
        stephen@networkplumber.org, dsa@cumulusnetworks.com,
        aduyck@mirantis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/veth.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 8c39d6d..730b133 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -45,18 +45,16 @@ struct veth_priv {
 	{ "peer_ifindex" },
 };
 
-static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int veth_get_link_ksettings(struct net_device *dev,
+				   struct ethtool_link_ksettings *cmd)
 {
-	cmd->supported		= 0;
-	cmd->advertising	= 0;
-	ethtool_cmd_speed_set(cmd, SPEED_10000);
-	cmd->duplex		= DUPLEX_FULL;
-	cmd->port		= PORT_TP;
-	cmd->phy_address	= 0;
-	cmd->transceiver	= XCVR_INTERNAL;
-	cmd->autoneg		= AUTONEG_DISABLE;
-	cmd->maxtxpkt		= 0;
-	cmd->maxrxpkt		= 0;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	cmd->base.speed = SPEED_10000;
+	cmd->base.duplex	= DUPLEX_FULL;
+	cmd->base.port		= PORT_TP;
+	cmd->base.phy_address	= 0;
+	cmd->base.autoneg	= AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -95,12 +93,12 @@ static void veth_get_ethtool_stats(struct net_device *dev,
 }
 
 static const struct ethtool_ops veth_ethtool_ops = {
-	.get_settings		= veth_get_settings,
 	.get_drvinfo		= veth_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_strings		= veth_get_strings,
 	.get_sset_count		= veth_get_sset_count,
 	.get_ethtool_stats	= veth_get_ethtool_stats,
+	.get_link_ksettings	= veth_get_link_ksettings,
 };
 
 static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
-- 
1.7.4.4
