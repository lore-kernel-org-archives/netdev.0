From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv6: export IP6_RT_PRIO_* to userland
Date: Mon,  5 Nov 2012 16:28:18 +0100
Message-ID: <1352129298-1104-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51262 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376Ab2KEPRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 10:17:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel uses some default metric when routes are managed. For example, a
static route added with a metric set to 0 is inserted in the kernel with
metric 1024 (IP6_RT_PRIO_USER).
It is useful for routing daemons to know these values, to be able to set routes
without interfering with what the kernel does.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/ip6_route.h         | 3 ---
 include/uapi/linux/ipv6_route.h | 3 +++
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 5fa2af0..27d8318 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -1,9 +1,6 @@
 #ifndef _NET_IP6_ROUTE_H
 #define _NET_IP6_ROUTE_H
 
-#define IP6_RT_PRIO_USER	1024
-#define IP6_RT_PRIO_ADDRCONF	256
-
 struct route_info {
 	__u8			type;
 	__u8			length;
diff --git a/include/uapi/linux/ipv6_route.h b/include/uapi/linux/ipv6_route.h
index 0459664..2be7bd1 100644
--- a/include/uapi/linux/ipv6_route.h
+++ b/include/uapi/linux/ipv6_route.h
@@ -55,4 +55,7 @@ struct in6_rtmsg {
 #define RTMSG_NEWROUTE		0x21
 #define RTMSG_DELROUTE		0x22
 
+#define IP6_RT_PRIO_USER	1024
+#define IP6_RT_PRIO_ADDRCONF	256
+
 #endif /* _UAPI_LINUX_IPV6_ROUTE_H */
-- 
1.7.12
