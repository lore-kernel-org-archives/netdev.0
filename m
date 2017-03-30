From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: batman-adv: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 30 Mar 2017 23:01:27 +0200
Message-ID: <1490907687-11784-1-git-send-email-tremyfr@gmail.com>
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: mareklindner@neomailbox.ch, sw@simonwunderlich.de, a@unstable.cc,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

I've only compiled this change. If someone may test it,
it would be very nice.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 net/batman-adv/soft-interface.c |   25 ++++++++++++-------------
 1 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index d042c99..07f6627 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -64,7 +64,8 @@
 #include "sysfs.h"
 #include "translation-table.h"
 
-static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
+static int batadv_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd);
 static void batadv_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info);
 static u32 batadv_get_msglevel(struct net_device *dev);
@@ -76,7 +77,6 @@ static void batadv_get_ethtool_stats(struct net_device *dev,
 static int batadv_get_sset_count(struct net_device *dev, int stringset);
 
 static const struct ethtool_ops batadv_ethtool_ops = {
-	.get_settings = batadv_get_settings,
 	.get_drvinfo = batadv_get_drvinfo,
 	.get_msglevel = batadv_get_msglevel,
 	.set_msglevel = batadv_set_msglevel,
@@ -84,6 +84,7 @@ static void batadv_get_ethtool_stats(struct net_device *dev,
 	.get_strings = batadv_get_strings,
 	.get_ethtool_stats = batadv_get_ethtool_stats,
 	.get_sset_count = batadv_get_sset_count,
+	.get_link_ksettings = batadv_get_link_ksettings,
 };
 
 int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
@@ -1085,18 +1086,16 @@ struct rtnl_link_ops batadv_link_ops __read_mostly = {
 };
 
 /* ethtool */
-static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int batadv_get_link_ksettings(struct net_device *dev,
+				     struct ethtool_link_ksettings *cmd)
 {
-	cmd->supported = 0;
-	cmd->advertising = 0;
-	ethtool_cmd_speed_set(cmd, SPEED_10);
-	cmd->duplex = DUPLEX_FULL;
-	cmd->port = PORT_TP;
-	cmd->phy_address = 0;
-	cmd->transceiver = XCVR_INTERNAL;
-	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
+	ethtool_link_ksettings_zero_link_mode(cmd, supported);
+	ethtool_link_ksettings_zero_link_mode(cmd, advertising);
+	cmd->base.speed = SPEED_10;
+	cmd->base.duplex = DUPLEX_FULL;
+	cmd->base.port = PORT_TP;
+	cmd->base.phy_address = 0;
+	cmd->base.autoneg = AUTONEG_DISABLE;
 
 	return 0;
 }
-- 
1.7.4.4
