From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 5/6] ipv6: Remove __ipv6_prefix_equal().
Date: Tue, 15 Jan 2013 02:10:31 +0900
Message-ID: <50F43C07.3080804@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39846 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757692Ab3ANRKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:10:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_prefix_equal() just casts its arguments and it is the only
user of __ipv6_prefix_equal().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index fb7f7c6..fe95053 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -399,9 +399,12 @@ static inline bool ipv6_addr_equal(const struct in6_addr *a1,
 #endif
 }
 
-static inline bool __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
-				       unsigned int prefixlen)
+static inline bool ipv6_prefix_equal(const struct in6_addr *addr1,
+				     const struct in6_addr *addr2,
+				     unsigned int prefixlen)
 {
+	const __be32 *a1 = addr1->s6_addr32;
+	const __be32 *a2 = addr2->s6_addr32;
 	unsigned int pdw, pbi;
 
 	/* check complete u32 in prefix */
@@ -417,14 +420,6 @@ static inline bool __ipv6_prefix_equal(const __be32 *a1, const __be32 *a2,
 	return true;
 }
 
-static inline bool ipv6_prefix_equal(const struct in6_addr *a1,
-				     const struct in6_addr *a2,
-				     unsigned int prefixlen)
-{
-	return __ipv6_prefix_equal(a1->s6_addr32, a2->s6_addr32,
-				   prefixlen);
-}
-
 struct inet_frag_queue;
 
 enum ip6_defrag_users {
-- 
1.7.9.5
