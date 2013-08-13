From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 2/4] ipv4 tunnels: use net_eq() helper to check netns
Date: Tue, 13 Aug 2013 17:51:10 +0200
Message-ID: <1376409072-6414-3-git-send-email-nicolas.dichtel@6wind.com>
References: <20130704.145621.2060744817757546493.davem@davemloft.net>
 <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35961 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758330Ab3HMPvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 11:51:38 -0400
In-Reply-To: <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's better to use available helpers for these tests.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/ip_tunnel.c | 4 ++--
 net/ipv6/sit.c       | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index fbc1094964bf..a351a003ee6b 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -461,7 +461,7 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		skb->dev = tunnel->dev;
 	}
 
-	if (tunnel->net != dev_net(tunnel->dev))
+	if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
 		skb_scrub_packet(skb);
 
 	gro_cells_receive(&tunnel->gro_cells, skb);
@@ -614,7 +614,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error;
 	}
 
-	if (tunnel->net != dev_net(dev))
+	if (!net_eq(tunnel->net, dev_net(dev)))
 		skb_scrub_packet(skb);
 
 	if (tunnel->err_count > 0) {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a3437a4cd07e..f18f842ac893 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -621,7 +621,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
 
-		if (tunnel->net != dev_net(tunnel->dev))
+		if (!net_eq(tunnel->net, dev_net(tunnel->dev)))
 			skb_scrub_packet(skb);
 		netif_rx(skb);
 
@@ -860,7 +860,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 			tunnel->err_count = 0;
 	}
 
-	if (tunnel->net != dev_net(dev))
+	if (!net_eq(tunnel->net, dev_net(dev)))
 		skb_scrub_packet(skb);
 
 	/*
@@ -1589,7 +1589,7 @@ static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_hea
 				/* If dev is in the same netns, it has already
 				 * been added to the list by the previous loop.
 				 */
-				if (dev_net(t->dev) != net)
+				if (!net_eq(dev_net(t->dev), net))
 					unregister_netdevice_queue(t->dev,
 								   head);
 				t = rtnl_dereference(t->next);
-- 
1.8.2.1
