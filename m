From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] IPv6 - Add missing initializations of the new nl_info.nl_net
 field
Date: Mon, 25 Feb 2008 10:50:23 +0100
Message-ID: <20080225095039.127441518@theryb.frec.bull.fr>
References: <20080221165219.657302066@theryb.frec.bull.fr>
 <20080223.200257.24167841.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:36395 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753932AbYBYKZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 05:25:42 -0500
In-Reply-To: <20080223.200257.24167841.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is an updated version of the patch without the initializations to 
"zero".


Add some more missing initializations of the new nl_info.nl_net field in 
IPv6 stack. This field will be used when network namespaces are fully 
supported.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/addrconf.c |    3 +++
 net/ipv6/route.c    |    2 ++
 2 files changed, 5 insertions(+)

Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -1557,6 +1557,7 @@ addrconf_prefix_route(struct in6_addr *p
 		.fc_expires = expires,
 		.fc_dst_len = plen,
 		.fc_flags = RTF_UP | flags,
+		.fc_nlinfo.nl_net = &init_net,
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, pfx);
@@ -1583,6 +1584,7 @@ static void addrconf_add_mroute(struct n
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 8,
 		.fc_flags = RTF_UP,
+		.fc_nlinfo.nl_net = &init_net,
 	};
 
 	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
@@ -1599,6 +1601,7 @@ static void sit_route_add(struct net_dev
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 96,
 		.fc_flags = RTF_UP | RTF_NONEXTHOP,
+		.fc_nlinfo.nl_net = &init_net,
 	};
 
 	/* prefix length - 96 bits "::d.d.d.d" */
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -1719,6 +1719,8 @@ static void rtmsg_to_fib6_config(struct 
 	cfg->fc_src_len = rtmsg->rtmsg_src_len;
 	cfg->fc_flags = rtmsg->rtmsg_flags;
 
+	cfg->fc_nlinfo.nl_net = &init_net;
+
 	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
 	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
 	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);

-- 
