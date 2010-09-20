From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Mon, 20 Sep 2010 15:01:40 +0200
Message-ID: <1284987700.3420.333.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:45694 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab0ITNBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 09:01:44 -0400
Received: by wyf22 with SMTP id 22so4253325wyf.19
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 06:01:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 can be a module, we should test CONFIG_IPV6 and CONFIG_IPV6_MODULE
to enable ipv6 bits in ip_gre.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index fc20e68..2af2fbd 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -46,7 +46,7 @@
 #include <net/rtnetlink.h>
 #include <net/gre.h>
 
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <net/ipv6.h>
 #include <net/ip6_fib.h>
 #include <net/ip6_route.h>
@@ -701,7 +701,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			if ((dst = rt->rt_gateway) == 0)
 				goto tx_error_icmp;
 		}
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6)) {
 			struct in6_addr *addr6;
 			int addr_type;
@@ -776,7 +776,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			goto tx_error;
 		}
 	}
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
 
@@ -852,7 +852,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	if ((iph->ttl = tiph->ttl) == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
-#ifdef CONFIG_IPV6
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 		else if (skb->protocol == htons(ETH_P_IPV6))
 			iph->ttl = ((struct ipv6hdr *)old_iph)->hop_limit;
 #endif


