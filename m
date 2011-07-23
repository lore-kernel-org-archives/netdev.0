From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: use RT_TOS after some rt_tos conversions
Date: Sat, 23 Jul 2011 15:00:41 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1107231455220.1537@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:50504 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730Ab1GWL5B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2011 07:57:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


rt_tos was changed to iph->tos but it must be filtered by RT_TOS

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp v3.0/linux/net/ipv4/ipmr.c linux/net/ipv4/ipmr.c
--- v3.0/linux/net/ipv4/ipmr.c	2011-07-23 14:35:17.551351207 +0300
+++ linux/net/ipv4/ipmr.c	2011-07-23 14:36:05.293350956 +0300
@@ -1796,7 +1796,7 @@ static struct mr_table *ipmr_rt_fib_look
 	struct flowi4 fl4 = {
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
-		.flowi4_tos = iph->tos,
+		.flowi4_tos = RT_TOS(iph->tos),
 		.flowi4_oif = rt->rt_oif,
 		.flowi4_iif = rt->rt_iif,
 		.flowi4_mark = rt->rt_mark,
diff -urp v3.0/linux/net/ipv4/route.c linux/net/ipv4/route.c
--- v3.0/linux/net/ipv4/route.c	2011-07-23 14:35:17.183352539 +0300
+++ linux/net/ipv4/route.c	2011-07-23 14:36:18.488350045 +0300
@@ -1740,7 +1740,7 @@ void ip_rt_get_source(u8 *addr, struct s
 		memset(&fl4, 0, sizeof(fl4));
 		fl4.daddr = iph->daddr;
 		fl4.saddr = iph->saddr;
-		fl4.flowi4_tos = iph->tos;
+		fl4.flowi4_tos = RT_TOS(iph->tos);
 		fl4.flowi4_oif = rt->dst.dev->ifindex;
 		fl4.flowi4_iif = skb->dev->ifindex;
 		fl4.flowi4_mark = skb->mark;
