From: Ulrich Weber <uweber@astaro.com>
Subject: [PATCH] ipv6: Remove IPV6_ADDR_RESERVED
Date: Fri, 26 Feb 2010 10:28:58 +0100
Message-ID: <20100226092858.GA5986@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-70.dex002.intermedia.net ([64.78.20.36]:20453 "EHLO
	DHOST002-70.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935695Ab0BZJoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 04:44:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4291 section 2.4 states that all uncategorized addresses
should be considered as Global Unicast.

This will remove IPV6_ADDR_RESERVED completely
and return IPV6_ADDR_UNICAST in ipv6_addr_type() instead.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 include/net/ipv6.h       |    1 -
 net/ipv6/addrconf.c      |    3 +--
 net/ipv6/addrconf_core.c |    2 +-
 net/ipv6/route.c         |    2 +-
 4 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ccab594..655e0b6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -73,7 +73,6 @@
 #define IPV6_ADDR_SCOPE_MASK	0x00f0U
 
 #define IPV6_ADDR_MAPPED	0x1000U
-#define IPV6_ADDR_RESERVED	0x2000U	/* reserved address space */
 
 /*
  *	Addr scopes
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 143791d..1a5d2e2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -992,8 +992,7 @@ struct ipv6_saddr_dst {
 
 static inline int ipv6_saddr_preferred(int type)
 {
-	if (type & (IPV6_ADDR_MAPPED|IPV6_ADDR_COMPATv4|
-		    IPV6_ADDR_LOOPBACK|IPV6_ADDR_RESERVED))
+	if (type & (IPV6_ADDR_MAPPED|IPV6_ADDR_COMPATv4|IPV6_ADDR_LOOPBACK))
 		return 1;
 	return 0;
 }
diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 3f82e95..6b03826 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -72,7 +72,7 @@ int __ipv6_addr_type(const struct in6_addr *addr)
 				IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.3 */
 	}
 
-	return (IPV6_ADDR_RESERVED |
+	return (IPV6_ADDR_UNICAST |
 		IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));	/* addr-select 3.4 */
 }
 EXPORT_SYMBOL(__ipv6_addr_type);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c2bd74c..86e72d7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1873,7 +1873,7 @@ static int ip6_pkt_drop(struct sk_buff *skb, u8 code, int ipstats_mib_noroutes)
 	switch (ipstats_mib_noroutes) {
 	case IPSTATS_MIB_INNOROUTES:
 		type = ipv6_addr_type(&ipv6_hdr(skb)->daddr);
-		if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED) {
+		if (type == IPV6_ADDR_ANY) {
 			IP6_INC_STATS(dev_net(dst->dev), ip6_dst_idev(dst),
 				      IPSTATS_MIB_INADDRERRORS);
 			break;
-- 
1.6.3.3

