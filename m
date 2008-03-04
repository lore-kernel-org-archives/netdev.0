From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 05/12][NETNS][IPV6] route6 - Pass the network namespace parameter to rt6_purge_dflt_routers
Date: Tue, 04 Mar 2008 22:03:31 +0100
Message-ID: <20080304211021.274125254@mai.toulouse-stg.fr.ibm.com>
References: <20080304210326.169013927@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:1972 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106AbYCDVM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 16:12:59 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m24LCwsr061066
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:58 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m24LCwiH2023480
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:58 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m24LCvt0001101
	for <netdev@vger.kernel.org>; Tue, 4 Mar 2008 21:12:58 GMT
Content-Disposition: inline; filename=route6-pass-network-namespace-to-rt6_purge_dflt_routers.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a network namespace parameter to rt6_purge_dflt_routers.
This is needed to call fib6_get_table with the appropriate 
network namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_route.h |    2 +-
 net/ipv6/addrconf.c     |    2 +-
 net/ipv6/route.c        |    4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

Index: net-2.6.26/include/net/ip6_route.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_route.h
+++ net-2.6.26/include/net/ip6_route.h
@@ -95,7 +95,7 @@ extern struct rt6_info *	rt6_add_dflt_ro
 						    struct net_device *dev,
 						    unsigned int pref);
 
-extern void			rt6_purge_dflt_routers(void);
+extern void			rt6_purge_dflt_routers(struct net *net);
 
 extern int			rt6_route_rcv(struct net_device *dev,
 					      u8 *opt, int len,
Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -493,7 +493,7 @@ static void addrconf_fixup_forwarding(st
 		dev_forward_change((struct inet6_dev *)table->extra1);
 
 	if (*p)
-		rt6_purge_dflt_routers();
+		rt6_purge_dflt_routers(net);
 }
 #endif
 
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -1697,13 +1697,13 @@ struct rt6_info *rt6_add_dflt_router(str
 	return rt6_get_dflt_router(gwaddr, dev);
 }
 
-void rt6_purge_dflt_routers(void)
+void rt6_purge_dflt_routers(struct net *net)
 {
 	struct rt6_info *rt;
 	struct fib6_table *table;
 
 	/* NOTE: Keep consistent with rt6_get_dflt_router */
-	table = fib6_get_table(&init_net, RT6_TABLE_DFLT);
+	table = fib6_get_table(net, RT6_TABLE_DFLT);
 	if (table == NULL)
 		return;
 

-- 
