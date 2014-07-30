From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: rename __ipv6_addr_jhash()
Date: Wed, 30 Jul 2014 23:38:18 +0200
Message-ID: <1406756298.3178.52.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:59137 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751483AbaG3ViW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 17:38:22 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so1829696wgg.12
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 14:38:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove '__' prefix, it has no purpose.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h          |    2 +-
 net/ipv6/inet6_hashtables.c |    2 +-
 net/ipv6/ip6_output.c       |    4 ++--
 net/ipv6/udp.c              |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a2db816e8461..c956e4ee4aa0 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -540,7 +540,7 @@ static inline u32 ipv6_addr_hash(const struct in6_addr *a)
 }
 
 /* more secured version of ipv6_addr_hash() */
-static inline u32 __ipv6_addr_jhash(const struct in6_addr *a, const u32 initval)
+static inline u32 ipv6_addr_jhash(const struct in6_addr *a, const u32 initval)
 {
 	u32 v = (__force u32)a->s6_addr32[0] ^ (__force u32)a->s6_addr32[1];
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 262e13c02ec2..96f7d07a3267 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -38,7 +38,7 @@ static unsigned int inet6_ehashfn(struct net *net,
 	net_get_random_once(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
 
 	lhash = (__force u32)laddr->s6_addr32[3];
-	fhash = __ipv6_addr_jhash(faddr, ipv6_hash_secret);
+	fhash = ipv6_addr_jhash(faddr, ipv6_hash_secret);
 
 	return __inet6_ehashfn(lhash, lport, fhash, fport,
 			       inet6_ehash_secret + net_hash_mix(net));
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f5dafe609f8b..bbd16185411b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -545,8 +545,8 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 
 	net_get_random_once(&ip6_idents_hashrnd, sizeof(ip6_idents_hashrnd));
 
-	hash = __ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
-	hash = __ipv6_addr_jhash(&rt->rt6i_src.addr, hash);
+	hash = ipv6_addr_jhash(&rt->rt6i_dst.addr, ip6_idents_hashrnd);
+	hash = ipv6_addr_jhash(&rt->rt6i_src.addr, hash);
 
 	id = ip_idents_reserve(hash, 1);
 	fhdr->identification = htonl(id);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5b6091de5868..cbedc59ced26 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -70,7 +70,7 @@ static unsigned int udp6_ehashfn(struct net *net,
 			    sizeof(udp_ipv6_hash_secret));
 
 	lhash = (__force u32)laddr->s6_addr32[3];
-	fhash = __ipv6_addr_jhash(faddr, udp_ipv6_hash_secret);
+	fhash = ipv6_addr_jhash(faddr, udp_ipv6_hash_secret);
 
 	return __inet6_ehashfn(lhash, lport, fhash, fport,
 			       udp_ipv6_hash_secret + net_hash_mix(net));
