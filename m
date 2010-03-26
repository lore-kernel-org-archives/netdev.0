From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] ipv6: Use __fls() instead of fls() in __ipv6_addr_diff().
Date: Fri, 26 Mar 2010 17:01:03 +0900
Message-ID: <201003260801.o2Q8134t023352@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42272 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751567Ab0CZIBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 04:01:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because we have ensured that the argument is non-zero,
it is better to use __fls() and generate better code.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e72fb10..619ab34 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -422,7 +422,7 @@ static inline int __ipv6_addr_diff(const void *token1, const void *token2, int a
 	for (i = 0; i < addrlen; i++) {
 		__be32 xb = a1[i] ^ a2[i];
 		if (xb)
-			return i * 32 + 32 - fls(ntohl(xb));
+			return i * 32 + 32 - __fls(ntohl(xb));
 	}
 
 	/*
-- 
1.5.6.5

