From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6] sctp: Use ipv6_addr_diff() in sctp_v6_addr_match_len().
Date: Sat, 27 Mar 2010 03:34:30 +0900
Message-ID: <201003261834.o2QIYUhQ009920@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:33655 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931Ab0CZSek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:34:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/sctp/ipv6.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 240dceb..216d88f 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -276,20 +276,7 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 static inline int sctp_v6_addr_match_len(union sctp_addr *s1,
 					 union sctp_addr *s2)
 {
-	struct in6_addr *a1 = &s1->v6.sin6_addr;
-	struct in6_addr *a2 = &s2->v6.sin6_addr;
-	int i, j;
-
-	for (i = 0; i < 4 ; i++) {
-		__be32 a1xora2;
-
-		a1xora2 = a1->s6_addr32[i] ^ a2->s6_addr32[i];
-
-		if ((j = fls(ntohl(a1xora2))))
-			return (i * 32 + 32 - j);
-	}
-
-	return (i*32);
+	return ipv6_addr_diff(&s1->v6.sin6_addr, &s2->v6.sin6_addr);
 }
 
 /* Fills in the source address(saddr) based on the destination address(daddr)
-- 
1.5.6.5

