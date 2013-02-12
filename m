From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/3] ipv6: introdcue __ipv6_addr_needs_scope_id and ipv6_iface_scope_id helper functions
Date: Tue, 12 Feb 2013 23:16:29 +0100
Message-ID: <20130212221629.GA7162@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60011 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757589Ab3BLWQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 17:16:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ipv6.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 851d541..8188d27 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -319,6 +319,18 @@ static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
 	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
 }
 
+static inline bool __ipv6_addr_needs_scope_id(int type)
+{
+	return type & IPV6_ADDR_LINKLOCAL ||
+	       (type & IPV6_ADDR_MULTICAST &&
+		__ipv6_addr_src_scope(type) <= IPV6_ADDR_SCOPE_LINKLOCAL);
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
1.8.1.2
