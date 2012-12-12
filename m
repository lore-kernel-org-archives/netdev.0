From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] ndisc: Unexport ndisc_{build,send}_skb().
Date: Thu, 13 Dec 2012 02:40:26 +0900
Message-ID: <201212121740.qBCHeQON011433@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52392 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314Ab2LLRkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:40:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These symbols were exported for bonding device by commit 305d552a
("bonding: send IPv6 neighbor advertisement on failover").

It bacame obsolete by commit 7c899432 ("bonding, ipv4, ipv6, vlan: Handle
NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS") and removed by
commit 4f5762ec ("bonding: Remove obsolete source file 'bond_ipv6.c'").

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ndisc.h |   15 ---------------
 net/ipv6/ndisc.c    |   27 +++++++++++----------------
 2 files changed, 11 insertions(+), 31 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 980d263..7af1ea8 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -190,21 +190,6 @@ extern void			ndisc_send_redirect(struct sk_buff *skb,
 extern int			ndisc_mc_map(const struct in6_addr *addr, char *buf,
 					     struct net_device *dev, int dir);
 
-extern struct sk_buff		*ndisc_build_skb(struct net_device *dev,
-						 const struct in6_addr *daddr,
-						 const struct in6_addr *saddr,
-						 struct icmp6hdr *icmp6h,
-						 const struct in6_addr *target,
-						 int llinfo);
-
-extern void			ndisc_send_skb(struct sk_buff *skb,
-					       struct net_device *dev,
-					       struct neighbour *neigh,
-					       const struct in6_addr *daddr,
-					       const struct in6_addr *saddr,
-					       struct icmp6hdr *icmp6h);
-
-
 
 /*
  *	IGMP
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index cf43b65..4c02e6a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -370,12 +370,12 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
-struct sk_buff *ndisc_build_skb(struct net_device *dev,
-				const struct in6_addr *daddr,
-				const struct in6_addr *saddr,
-				struct icmp6hdr *icmp6h,
-				const struct in6_addr *target,
-				int llinfo)
+static struct sk_buff *ndisc_build_skb(struct net_device *dev,
+				       const struct in6_addr *daddr,
+				       const struct in6_addr *saddr,
+				       struct icmp6hdr *icmp6h,
+				       const struct in6_addr *target,
+				       int llinfo)
 {
 	struct net *net = dev_net(dev);
 	struct sock *sk = net->ipv6.ndisc_sk;
@@ -431,14 +431,11 @@ struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	return skb;
 }
 
-EXPORT_SYMBOL(ndisc_build_skb);
-
-void ndisc_send_skb(struct sk_buff *skb,
-		    struct net_device *dev,
-		    struct neighbour *neigh,
-		    const struct in6_addr *daddr,
-		    const struct in6_addr *saddr,
-		    struct icmp6hdr *icmp6h)
+static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
+			   struct neighbour *neigh,
+			   const struct in6_addr *daddr,
+			   const struct in6_addr *saddr,
+			   struct icmp6hdr *icmp6h)
 {
 	struct flowi6 fl6;
 	struct dst_entry *dst;
@@ -473,8 +470,6 @@ void ndisc_send_skb(struct sk_buff *skb,
 	rcu_read_unlock();
 }
 
-EXPORT_SYMBOL(ndisc_send_skb);
-
 /*
  *	Send a Neighbour Discover packet
  */
-- 
1.7.9.5
