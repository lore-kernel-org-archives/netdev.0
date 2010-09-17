From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6 2/2] ip_gre: add multiqueue support
Date: Fri, 17 Sep 2010 10:35:36 +0200
Message-ID: <1284712536.3391.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f47.google.com ([74.125.82.47]:45694 "EHLO
	mail-ww0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266Ab0IQIfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 04:35:40 -0400
Received: by wwf26 with SMTP id 26so1038454wwf.4
        for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 01:35:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable multiqueue support for non fallback GRE tunnels.

# ip link add gre34 txqueues 8 type gre remote A.B.C.D

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fc20e68..c708a25 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -664,7 +664,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
-	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
+	int n = skb_get_queue_mapping(skb);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, n);
 	struct iphdr  *old_iph = ip_hdr(skb);
 	struct iphdr  *tiph;
 	u8     tos;
@@ -1490,6 +1491,8 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nla
 	if (!tb[IFLA_MTU])
 		dev->mtu = mtu;
 
+	dev->real_num_tx_queues = dev->num_tx_queues;
+
 	err = register_netdevice(dev);
 	if (err)
 		goto out;


