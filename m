From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPV4] ip_gre: should take care of CONFIG_IPV6_MODULE
Date: Tue, 22 Jan 2008 08:51:50 +0100
Message-ID: <4795A096.60904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070608070408060401020504"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604003av.neufgp.fr ([84.96.92.124]:54862 "EHLO
	neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751953AbYAVHwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 02:52:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070608070408060401020504
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

If IPV6 is configured as a module, GRE code misses some IPV6 parts.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------070608070408060401020504
Content-Type: text/plain;
 name="gre.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gre.patch"

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 4b93f32..beaf450 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -40,7 +40,7 @@
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
@@ -705,7 +705,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			if ((dst = rt->rt_gateway) == 0)
 				goto tx_error_icmp;
 		}
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
 			struct in6_addr *addr6;
 			int addr_type;
@@ -778,7 +778,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 			goto tx_error;
 		}
 	}
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info*)skb->dst;
 
@@ -851,7 +851,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((iph->ttl = tiph->ttl) == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6))
 			iph->ttl = ((struct ipv6hdr*)old_iph)->hop_limit;
 #endif

--------------070608070408060401020504--
