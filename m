From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 2/4] ipv6: introdcue __ipv6_addr_needs_scope_id and ipv6_iface_scope_id helper functions
Date: Sat, 16 Feb 2013 20:10:13 +0100
Message-ID: <20130216191013.GA23321@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org, brian.haley@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39309 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972Ab3BPTKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 14:10:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ipv6_addr_needs_scope_id checks if an ipv6 address needs to supply
a 'sin6_scope_id != 0'. 'sin6_scope_id != 0' was enforced in case
of link-local addresses. To support interface-local multicast these
checks had to be enhanced and are now consolidated into these new helper
functions.

v2:
a) unchanged

Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: Brian Haley <brian.haley@hp.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a14700c..73a92ff 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -325,6 +325,18 @@ static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
 	return __ipv6_addr_src_scope(__ipv6_addr_props(addr));
 }
 
+static inline bool __ipv6_addr_needs_scope_id(struct ipv6_addr_props props)
+{
+	return props.type & IPV6_ADDR_LINKLOCAL ||
+	       (props.type & IPV6_ADDR_MULTICAST &&
+		__ipv6_addr_src_scope(props) <= IPV6_ADDR_SCOPE_LINKLOCAL);
+}
+
+static inline __u32 ipv6_iface_scope_id(const struct in6_addr *addr, int iface)
+{
+	return __ipv6_addr_needs_scope_id(__ipv6_addr_props(addr)) ? iface : 0;
+}
+
 static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
 {
 	return memcmp(a1, a2, sizeof(struct in6_addr));
-- 
1.8.1.2
