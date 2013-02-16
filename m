From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: optimize inet6_hash_frag()
Date: Fri, 15 Feb 2013 20:14:48 -0800
Message-ID: <1360988088.19353.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:44994 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab3BPEOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 23:14:51 -0500
Received: by mail-pb0-f42.google.com with SMTP id xb4so870286pbc.15
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 20:14:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Use ipv6_addr_hash() and a single jhash invocation.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/reassembly.c |   15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e354743..9a6428a 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -79,20 +79,7 @@ unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
 {
 	u32 c;
 
-	c = jhash_3words((__force u32)saddr->s6_addr32[0],
-			 (__force u32)saddr->s6_addr32[1],
-			 (__force u32)saddr->s6_addr32[2],
-			 rnd);
-
-	c = jhash_3words((__force u32)saddr->s6_addr32[3],
-			 (__force u32)daddr->s6_addr32[0],
-			 (__force u32)daddr->s6_addr32[1],
-			 c);
-
-	c =  jhash_3words((__force u32)daddr->s6_addr32[2],
-			  (__force u32)daddr->s6_addr32[3],
-			  (__force u32)id,
-			  c);
+	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr), id, rnd);
 
 	return c & (INETFRAGS_HASHSZ - 1);
 }
