From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] gre: clear IFF_TX_SKB_SHARING
Date: Wed, 17 Feb 2016 15:32:53 +0100
Message-ID: <48849b92d89431da841577f06cfd90a4b4130702.1455719517.git.jbenc@redhat.com>
Cc: Jesse Gross <jesse@kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34141 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030268AbcBQOdK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 09:33:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ether_setup sets IFF_TX_SKB_SHARING but this is not supported by gre as it
modifies the skb on xmit.

Also, clean up whitespace in ipgre_tap_setup when we're already touching it.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/ipv4/ip_gre.c  | 5 +++--
 net/ipv6/ip6_gre.c | 1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 56fdf4e0dce4..41ba68de46d8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1054,8 +1054,9 @@ static const struct net_device_ops gre_tap_netdev_ops = {
 static void ipgre_tap_setup(struct net_device *dev)
 {
 	ether_setup(dev);
-	dev->netdev_ops		= &gre_tap_netdev_ops;
-	dev->priv_flags 	|= IFF_LIVE_ADDR_CHANGE;
+	dev->netdev_ops	= &gre_tap_netdev_ops;
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags	|= IFF_LIVE_ADDR_CHANGE;
 	ip_tunnel_setup(dev, gre_tap_net_id);
 }
 
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index f37f18b6b40c..a69aad1e29d1 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -1512,6 +1512,7 @@ static void ip6gre_tap_setup(struct net_device *dev)
 	dev->destructor = ip6gre_dev_free;
 
 	dev->features |= NETIF_F_NETNS_LOCAL;
+	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 }
 
 static int ip6gre_newlink(struct net *src_net, struct net_device *dev,
-- 
1.8.3.1
