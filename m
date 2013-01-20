From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 4/5] ipv6: Optimize ipv6_addr_is_ll_all_{nodes,routers}().
Date: Mon, 21 Jan 2013 02:38:52 +0900
Message-ID: <50FC2BAC.4070107@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:48878 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752371Ab3ATRiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 12:38:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/addrconf.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 9dc5efc..6c58d50 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -288,16 +288,26 @@ static inline bool ipv6_addr_is_multicast(const struct in6_addr *addr)
 
 static inline bool ipv6_addr_is_ll_all_nodes(const struct in6_addr *addr)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	__u64 *p = (__u64 *)addr;
+	return ((p[0] ^ cpu_to_be64(0xff02000000000000UL)) | (p[1] ^ cpu_to_be64(1))) == 0UL;
+#else
 	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
 		addr->s6_addr32[1] | addr->s6_addr32[2] |
 		(addr->s6_addr32[3] ^ htonl(0x00000001))) == 0;
+#endif
 }
 
 static inline bool ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	__u64 *p = (__u64 *)addr;
+	return ((p[0] ^ cpu_to_be64(0xff02000000000000UL)) | (p[1] ^ cpu_to_be64(2))) == 0UL;
+#else
 	return ((addr->s6_addr32[0] ^ htonl(0xff020000)) |
 		addr->s6_addr32[1] | addr->s6_addr32[2] |
 		(addr->s6_addr32[3] ^ htonl(0x00000002))) == 0;
+#endif
 }
 
 static inline bool ipv6_addr_is_isatap(const struct in6_addr *addr)
-- 
1.7.9.5
