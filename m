From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 05/13] ipv6: Introduce rt6_nexthop() to select
 nexthop address.
Date: Wed, 16 Jan 2013 01:45:03 +0900
Message-ID: <50F5878F.8070200@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41306 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756691Ab3AOQpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:45:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RTF_GATEWAY route, return rt->rt6i_gateway.
Otherwise, return 2nd argument (destination address).

This will be used for rt->n removal.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_route.h |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 27d8318..9af6480 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -23,6 +23,7 @@ struct route_info {
 #include <net/sock.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/route.h>
 
 #define RT6_LOOKUP_F_IFACE		0x00000001
 #define RT6_LOOKUP_F_REACHABLE		0x00000002
@@ -194,4 +195,12 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
+static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr *dest)
+{
+	BUG_ON(rt == NULL);
+	if (rt->rt6i_flags & RTF_GATEWAY)
+		return &rt->rt6i_gateway;
+	return dest;
+}
+
 #endif
-- 
1.7.9.5
