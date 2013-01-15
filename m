From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 11/13] ipv6: Use ip6_route_output() instead of
 icmp6_dst_alloc().
Date: Wed, 16 Jan 2013 01:46:25 +0900
Message-ID: <50F587E1.9020301@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41325 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756394Ab3AOQq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:46:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/mcast.c |    5 ++---
 net/ipv6/ndisc.c |    3 ++-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 8237ee1..e041c39 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1391,9 +1391,8 @@ static void mld_sendpack(struct sk_buff *skb)
 	icmpv6_flow_init(net->ipv6.igmp_sk, &fl6, ICMPV6_MLD2_REPORT,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
-	dst = icmp6_dst_alloc(skb->dev, NULL, &fl6);
-
 	err = 0;
+	dst = ip6_route_output(net, net->ipv6.igmp_sk, &fl6);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		dst = NULL;
@@ -1759,7 +1758,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	icmpv6_flow_init(sk, &fl6, type,
 			 &ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
 			 skb->dev->ifindex);
-	dst = icmp6_dst_alloc(skb->dev, NULL, &fl6);
+	dst = ip6_route_output(net, sk, &fl6);
 	if (IS_ERR(dst)) {
 		err = PTR_ERR(dst);
 		goto err_out;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 5733cd2..f19fe55 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -448,7 +448,8 @@ static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
 	type = icmp6h->icmp6_type;
 
 	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
-	dst = icmp6_dst_alloc(dev, neigh, &fl6);
+
+	dst = ip6_route_output(net, sk, &fl6);
 	if (IS_ERR(dst)) {
 		kfree_skb(skb);
 		return;
-- 
1.7.9.5
