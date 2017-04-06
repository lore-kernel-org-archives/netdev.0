From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 16/19] batman-adv: Remove ethtool msglevel functions
Date: Thu,  6 Apr 2017 16:07:38 +0200
Message-ID: <20170406140741.30745-17-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:32948 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935050AbdDFOHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:54 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batadv devices don't support msglevel. The ethtool stubs therefore returned
that it isn't supported. But instead, the complete function can be dropped
to avoid that bogus values are shown in ethtool.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index eff23d519c6f..3e0ee2afb814 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -67,8 +67,6 @@
 static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
 static void batadv_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info);
-static u32 batadv_get_msglevel(struct net_device *dev);
-static void batadv_set_msglevel(struct net_device *dev, u32 value);
 static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data);
 static void batadv_get_ethtool_stats(struct net_device *dev,
 				     struct ethtool_stats *stats, u64 *data);
@@ -77,8 +75,6 @@ static int batadv_get_sset_count(struct net_device *dev, int stringset);
 static const struct ethtool_ops batadv_ethtool_ops = {
 	.get_settings = batadv_get_settings,
 	.get_drvinfo = batadv_get_drvinfo,
-	.get_msglevel = batadv_get_msglevel,
-	.set_msglevel = batadv_set_msglevel,
 	.get_link = ethtool_op_get_link,
 	.get_strings = batadv_get_strings,
 	.get_ethtool_stats = batadv_get_ethtool_stats,
@@ -1109,15 +1105,6 @@ static void batadv_get_drvinfo(struct net_device *dev,
 	strlcpy(info->bus_info, "batman", sizeof(info->bus_info));
 }
 
-static u32 batadv_get_msglevel(struct net_device *dev)
-{
-	return -EOPNOTSUPP;
-}
-
-static void batadv_set_msglevel(struct net_device *dev, u32 value)
-{
-}
-
 /* Inspired by drivers/net/ethernet/dlink/sundance.c:1702
  * Declare each description string in struct.name[] to get fixed sized buffer
  * and compile time checking for strings longer than ETH_GSTRING_LEN.
-- 
2.11.0
