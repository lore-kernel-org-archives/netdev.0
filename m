From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/6] ipv6: 64bit version of ipv6_addr_loopback().
Date: Tue, 15 Jan 2013 02:10:06 +0900
Message-ID: <50F43BEE.1070608@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39835 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757241Ab3ANRKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:10:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ace1113..c5049b0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -475,8 +475,14 @@ static inline u32 ipv6_addr_hash(const struct in6_addr *a)
 
 static inline bool ipv6_addr_loopback(const struct in6_addr *a)
 {
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+	const unsigned long *ul = (const unsigned long *)a;
+
+	return (ul[0] | (ul[1] ^ cpu_to_be64(1))) == 0UL;
+#else
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
 		a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) == 0;
+#endif
 }
 
 static inline bool ipv6_addr_v4mapped(const struct in6_addr *a)
-- 
1.7.9.5
