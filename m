From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 03/20] net-ipv6: extending (hw_/wanted_/vlan_)features fields to a bitmap.
Date: Tue,  5 Apr 2011 17:44:08 -0700
Message-ID: <1302050665-10460-4-git-send-email-maheshb@google.com>
References: <1302050665-10460-1-git-send-email-maheshb@google.com>
 <1302050665-10460-2-git-send-email-maheshb@google.com>
 <1302050665-10460-3-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:28059 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152Ab1DFAoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 20:44:54 -0400
In-Reply-To: <1302050665-10460-3-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Converting current use of (hw_/wanted_/vlan_)features to
legacy_(hw_/wanted_/vlan_)features to differntiate from the proposed usage.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 net/dccp/ipv6.c       |    2 +-
 net/ipv6/ip6_output.c |    6 +++---
 net/ipv6/ip6_tunnel.c |    2 +-
 net/ipv6/ip6mr.c      |    2 +-
 net/ipv6/sit.c        |    4 ++--
 5 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index de1b7e3..254a6df 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -555,7 +555,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	 */
 
 	__ip6_dst_store(newsk, dst, NULL, NULL);
-	newsk->sk_route_caps = dst->dev->features & ~(NETIF_F_IP_CSUM |
+	newsk->sk_route_caps = dst->dev->legacy_features & ~(NETIF_F_IP_CSUM |
 						      NETIF_F_TSO);
 	newdp6 = (struct dccp6_sock *)newsk;
 	newinet = inet_sk(newsk);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1820887..ba1183d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1276,7 +1276,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		}
 
 		if (proto == IPPROTO_UDP &&
-		    (rt->dst.dev->features & NETIF_F_UFO)) {
+		    (rt->dst.dev->legacy_features & NETIF_F_UFO)) {
 
 			err = ip6_ufo_append_data(sk, getfrag, from, length,
 						  hh_len, fragheaderlen,
@@ -1322,7 +1322,7 @@ alloc_new_skb:
 
 			fraglen = datalen + fragheaderlen;
 			if ((flags & MSG_MORE) &&
-			    !(rt->dst.dev->features&NETIF_F_SG))
+			    !(rt->dst.dev->legacy_features & NETIF_F_SG))
 				alloclen = mtu;
 			else
 				alloclen = datalen + fragheaderlen;
@@ -1419,7 +1419,7 @@ alloc_new_skb:
 		if (copy > length)
 			copy = length;
 
-		if (!(rt->dst.dev->features&NETIF_F_SG)) {
+		if (!(rt->dst.dev->legacy_features & NETIF_F_SG)) {
 			unsigned int off;
 
 			off = skb->len;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c1b1bd3..6ae9598 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1385,7 +1385,7 @@ static void ip6_tnl_dev_setup(struct net_device *dev)
 		dev->mtu-=8;
 	dev->flags |= IFF_NOARP;
 	dev->addr_len = sizeof(struct in6_addr);
-	dev->features |= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features |= NETIF_F_NETNS_LOCAL;
 	dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
 }
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 29e4859..d137089 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -719,7 +719,7 @@ static void reg_vif_setup(struct net_device *dev)
 	dev->flags		= IFF_NOARP;
 	dev->netdev_ops		= &reg_vif_netdev_ops;
 	dev->destructor		= free_netdev;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features	|= NETIF_F_NETNS_LOCAL;
 }
 
 static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 43b3337..38aba2f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1139,8 +1139,8 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
-	dev->features		|= NETIF_F_LLTX;
+	dev->legacy_features	|= NETIF_F_NETNS_LOCAL;
+	dev->legacy_features	|= NETIF_F_LLTX;
 }
 
 static int ipip6_tunnel_init(struct net_device *dev)
-- 
1.7.3.1

