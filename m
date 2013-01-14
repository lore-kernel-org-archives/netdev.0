From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 3/6] ipv6: 64bit version of ipv6_addr_v4mapped().
Date: Tue, 15 Jan 2013 02:10:14 +0900
Message-ID: <50F43BF6.4050301@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39839 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757243Ab3ANRKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 12:10:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c5049b0..77cef332 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -487,8 +487,13 @@ static inline bool ipv6_addr_loopback(const struct in6_addr *a)
 
 static inline bool ipv6_addr_v4mapped(const struct in6_addr *a)
 {
-	return (a->s6_addr32[0] | a->s6_addr32[1] |
-		 (a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0;
+	return (
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
+		*(__be64 *)a |
+#else
+		(a->s6_addr32[0] | a->s6_addr32[1]) |
+#endif
+		(a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0UL;
 }
 
 /*
-- 
1.7.9.5
