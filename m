From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC 1/2] ipv6: introdcue __ipv6_addr_needs_scope_id and ipv6_iface_scope_id helper functions
Date: Mon, 11 Feb 2013 12:13:03 +0100
Message-ID: <20130211111303.GA23991@order.stressinduktion.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org> <20130210153230.GA21377@order.stressinduktion.org> <5117EA2D.1020106@linux-ipv6.org> <20130210184918.GB20897@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56721 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755237Ab3BKLNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2013 06:13:05 -0500
Content-Disposition: inline
In-Reply-To: <20130210184918.GB20897@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This strictly a RFC only (I also left out my signed-off). This patch
introduces helper functions to set and check for the need of scope ids.

Suggested-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 851d541..1f61dc9 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -319,6 +319,19 @@ static inline int ipv6_addr_src_scope(const struct in6_addr *addr)
 	return __ipv6_addr_src_scope(__ipv6_addr_type(addr));
 }
 
+static inline bool __ipv6_addr_needs_scope_id(int type)
+{
+	return type != IPV6_ADDR_ANY &&
+	       !(type & IPV6_ADDR_LOOPBACK && type & IPV6_ADDR_UNICAST) &&
+	       __ipv6_addr_src_scope(type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
+}
+
+static inline __u32 ipv6_iface_scope_id(const struct in6_addr *addr,
+					unsigned int iface)
+{
+	return __ipv6_addr_needs_scope_id(__ipv6_addr_type(addr)) ? iface : 0;
+}
+
 static inline int ipv6_addr_cmp(const struct in6_addr *a1, const struct in6_addr *a2)
 {
 	return memcmp(a1, a2, sizeof(struct in6_addr));
-- 
1.8.1.2
