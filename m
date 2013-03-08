From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v4 1/4] ipv6: introdcue __ipv6_addr_needs_scope_id and ipv6_iface_scope_id helper functions
Date: Fri, 8 Mar 2013 13:07:16 +0100
Message-ID: <20130308120716.GA5028@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51148 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756758Ab3CHMHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 07:07:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__ipv6_addr_needs_scope_id checks if an ipv6 address needs to supply
a 'sin6_scope_id != 0'. 'sin6_scope_id != 0' was enforced in case
of link-local addresses. To support interface-local multicast these
checks had to be enhanced and are now consolidated into these new helper
functions.

v2:
a) migrated to struct ipv6_addr_props

v3:
a) reverted changes for ipv6_addr_props
b) test for address type instead of comparing scope

v4:
a) unchanged

Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 988c9f2..42ef6ab 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -320,6 +320,18 @@ static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
 	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
 }
 
+static inline bool __ipv6_addr_needs_scope_id(int type)
+{
+	return type & IPV6_ADDR_LINKLOCAL ||
+	       (type & IPV6_ADDR_MULTICAST &&
+		(type & (IPV6_ADDR_LOOPBACK|IPV6_ADDR_LINKLOCAL)));
+}
+
+static inline __u32 ipv6_iface_scope_id(const struct in6_addr *addr, int iface)
+{
+	return __ipv6_addr_needs_scope_id(__ipv6_addr_type(addr)) ? iface : 0;
+}
+
 static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
 {
 	return memcmp(a1, a2, sizeof(struct in6_addr));
-- 
1.8.1.4
