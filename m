From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (V4) 08/11] ipv6: Introduce rt6_nexthop() to select
 nexthop address.
Date: Fri, 18 Jan 2013 07:53:48 +0900
Message-ID: <50F880FC.2070505@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44775 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754284Ab3AQWxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 17:53:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For RTF_GATEWAY route, return rt->rt6i_gateway.
Otherwise, return 2nd argument (destination address).

This will be used by following patches which remove rt->n
dependency patches in ip6_dst_lookup_tail() and ip6_finish_output2().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_route.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 27d8318..30cbb15 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -23,6 +23,7 @@ struct route_info {
 #include <net/sock.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/route.h>
 
 #define RT6_LOOKUP_F_IFACE		0x00000001
 #define RT6_LOOKUP_F_REACHABLE		0x00000002
@@ -194,4 +195,11 @@ static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 	       skb_dst(skb)->dev->mtu : dst_mtu(skb_dst(skb));
 }
 
+static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr *dest)
+{
+	if (rt->rt6i_flags & RTF_GATEWAY)
+		return &rt->rt6i_gateway;
+	return dest;
+}
+
 #endif
-- 
1.7.9.5
