From: benjamin.thery@bull.net
Subject: [PATCH] IPv6  Add more initializations of the new nl_info.nl_net field
Date: Thu, 21 Feb 2008 17:51:50 +0100
Message-ID: <20080221165219.657302066@theryb.frec.bull.fr>
References: <20080221165149.928863399@theryb.frec.bull.fr>
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:60913 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758893AbYBUQwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 11:52:13 -0500
Content-Disposition: inline; filename=ipv6-initialize-new-nl_info.nl_net-field.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add more missing initializations of the new nl_info.nl_net field in 
IPv6 stack. 
This field will be used when network namespaces are fully supported.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/addrconf.c |    9 +++++++++
 net/ipv6/route.c    |    6 ++++++
 2 files changed, 15 insertions(+)

Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -1557,6 +1557,9 @@ addrconf_prefix_route(struct in6_addr *p
 		.fc_expires = expires,
 		.fc_dst_len = plen,
 		.fc_flags = RTF_UP | flags,
+		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.nlh = NULL,
+		.fc_nlinfo.nl_net = &init_net,
 	};
 
 	ipv6_addr_copy(&cfg.fc_dst, pfx);
@@ -1583,6 +1586,9 @@ static void addrconf_add_mroute(struct n
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 8,
 		.fc_flags = RTF_UP,
+		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.nlh = NULL,
+		.fc_nlinfo.nl_net = &init_net,
 	};
 
 	ipv6_addr_set(&cfg.fc_dst, htonl(0xFF000000), 0, 0, 0);
@@ -1599,6 +1605,9 @@ static void sit_route_add(struct net_dev
 		.fc_ifindex = dev->ifindex,
 		.fc_dst_len = 96,
 		.fc_flags = RTF_UP | RTF_NONEXTHOP,
+		.fc_nlinfo.pid = 0,
+		.fc_nlinfo.nlh = NULL,
+		.fc_nlinfo.nl_net = &init_net,
 	};
 
 	/* prefix length - 96 bits "::d.d.d.d" */
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -604,6 +604,8 @@ static int __ip6_ins_rt(struct rt6_info 
 int ip6_ins_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
+		.pid = 0,
+		.nlh = NULL,
 		.nl_net = &init_net,
 	};
 	return __ip6_ins_rt(rt, &info);
@@ -1264,6 +1266,8 @@ static int __ip6_del_rt(struct rt6_info 
 int ip6_del_rt(struct rt6_info *rt)
 {
 	struct nl_info info = {
+		.pid = 0,
+		.nlh = NULL,
 		.nl_net = &init_net,
 	};
 	return __ip6_del_rt(rt, &info);
@@ -1719,6 +1723,8 @@ static void rtmsg_to_fib6_config(struct 
 	cfg->fc_src_len = rtmsg->rtmsg_src_len;
 	cfg->fc_flags = rtmsg->rtmsg_flags;
 
+	cfg->fc_nlinfo.nl_net = &init_net;
+
 	ipv6_addr_copy(&cfg->fc_dst, &rtmsg->rtmsg_dst);
 	ipv6_addr_copy(&cfg->fc_src, &rtmsg->rtmsg_src);
 	ipv6_addr_copy(&cfg->fc_gateway, &rtmsg->rtmsg_gateway);

-- 
