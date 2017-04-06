From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 15/19] batman-adv: Use ethtool helper to get link status
Date: Thu,  6 Apr 2017 16:07:37 +0200
Message-ID: <20170406140741.30745-16-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:33000 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935053AbdDFOHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 10:07:54 -0400
In-Reply-To: <20170406140741.30745-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The ethtool_ops of batman-adv never contained more than a stub for the
get_link function pointer. It was always returning that a link exists even
when the devices was not yet up and therefore nothing resampling a link
could have been available.

Instead use the ethtool helper which returns the current carrier state.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Acked-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/soft-interface.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index a9dbcc1590bd..eff23d519c6f 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -69,7 +69,6 @@ static void batadv_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info);
 static u32 batadv_get_msglevel(struct net_device *dev);
 static void batadv_set_msglevel(struct net_device *dev, u32 value);
-static u32 batadv_get_link(struct net_device *dev);
 static void batadv_get_strings(struct net_device *dev, u32 stringset, u8 *data);
 static void batadv_get_ethtool_stats(struct net_device *dev,
 				     struct ethtool_stats *stats, u64 *data);
@@ -80,7 +79,7 @@ static const struct ethtool_ops batadv_ethtool_ops = {
 	.get_drvinfo = batadv_get_drvinfo,
 	.get_msglevel = batadv_get_msglevel,
 	.set_msglevel = batadv_set_msglevel,
-	.get_link = batadv_get_link,
+	.get_link = ethtool_op_get_link,
 	.get_strings = batadv_get_strings,
 	.get_ethtool_stats = batadv_get_ethtool_stats,
 	.get_sset_count = batadv_get_sset_count,
@@ -1119,11 +1118,6 @@ static void batadv_set_msglevel(struct net_device *dev, u32 value)
 {
 }
 
-static u32 batadv_get_link(struct net_device *dev)
-{
-	return 1;
-}
-
 /* Inspired by drivers/net/ethernet/dlink/sundance.c:1702
  * Declare each description string in struct.name[] to get fixed sized buffer
  * and compile time checking for strings longer than ETH_GSTRING_LEN.
-- 
2.11.0
