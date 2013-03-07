From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash table
Date: Thu, 7 Mar 2013 22:42:11 +0100
Message-ID: <20130307214211.GP7941@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49984 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758860Ab3CGVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:42:12 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_addr_hash can yield the exact same hash value for countless ip
addresses from one /64 subnet. Let's make it a bit harder to create a
long list of reassembly queues in the hash table by using a stronger hash.

I spotted this just by looking at the source and did not verify if it
is really the case, so this patch has RFC status. But the jhash change
should not really hurt anyway. This patch is only compile tested.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/reassembly.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 3c6a772..4d39cf3 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -79,7 +79,7 @@ unsigned int inet6_hash_frag(__be32 id, const struct in6_addr *saddr,
 {
 	u32 c;
 
-	c = jhash_3words(ipv6_addr_hash(saddr), ipv6_addr_hash(daddr),
+	c = jhash_3words(ipv6_addr_jhash(saddr), ipv6_addr_hash(daddr),
 			 (__force u32)id, rnd);
 
 	return c & (INETFRAGS_HASHSZ - 1);
-- 
1.8.1.4
