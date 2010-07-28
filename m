From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] vlan: fix u64_stats
Date: Wed, 28 Jul 2010 13:10:33 +0800
Message-ID: <1280293833-8723-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:38974 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab0G1Ift (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 04:35:49 -0400
Received: by pvc7 with SMTP id 7so782768pvc.19
        for <netdev@vger.kernel.org>; Wed, 28 Jul 2010 01:35:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_stats->rx_errors should be under the protection of rx_stats->syncp.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/8021q/vlan_dev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3d59c9b..d70d31a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -211,7 +211,6 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		default:
 			break;
 		}
-		u64_stats_update_end(&rx_stats->syncp);
 	}
 
 	skb_pull_rcsum(skb, VLAN_HLEN);
@@ -221,8 +220,10 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		skb = vlan_check_reorder_header(skb);
 		if (!skb) {
 			rx_stats->rx_errors++;
+			u64_stats_update_end(&rx_stats->syncp);
 			goto err_unlock;
 		}
+		u64_stats_update_end(&rx_stats->syncp);
 	}
 
 	netif_rx(skb);
