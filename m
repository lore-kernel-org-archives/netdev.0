From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 09/19] ndisc: Remove dev argument for ndisc_send_skb().
Date: Tue, 22 Jan 2013 01:48:34 +0900
Message-ID: <50FD7162.4080301@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50355 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752773Ab3AUQse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have skb->dev, use it.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ed3ba8e..200b2b2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -463,14 +463,14 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	return skb;
 }
 
-static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
+static void ndisc_send_skb(struct sk_buff *skb,
 			   const struct in6_addr *daddr,
 			   const struct in6_addr *saddr,
 			   struct icmp6hdr *icmp6h)
 {
 	struct flowi6 fl6;
 	struct dst_entry *dst;
-	struct net *net = dev_net(dev);
+	struct net *net = dev_net(skb->dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct inet6_dev *idev;
 	int err;
@@ -478,8 +478,8 @@ static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
 
 	type = icmp6h->icmp6_type;
 
-	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
-	dst = icmp6_dst_alloc(dev, &fl6);
+	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
+	dst = icmp6_dst_alloc(skb->dev, &fl6);
 	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
@@ -516,7 +516,7 @@ static void __ndisc_send(struct net_device *dev,
 	if (!skb)
 		return;
 
-	ndisc_send_skb(skb, dev, daddr, saddr, icmp6h);
+	ndisc_send_skb(skb, daddr, saddr, icmp6h);
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-- 
1.7.9.5
