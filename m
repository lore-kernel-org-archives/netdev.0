From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] ipvs: oldlen, newlen should be be16, not be32
Date: Thu, 06 Nov 2008 18:12:05 -0800
Message-ID: <1226023925.5482.2.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:59834 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbYKGCMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 21:12:08 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1073528rvb.1
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2008 18:12:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed by sparse:
net/netfilter/ipvs/ip_vs_proto_tcp.c:195:6: warning: incorrect type in argument 5 (different base types)
net/netfilter/ipvs/ip_vs_proto_tcp.c:195:6:    expected restricted __be16 [usertype] oldlen
net/netfilter/ipvs/ip_vs_proto_tcp.c:195:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_tcp.c:196:6: warning: incorrect type in argument 6 (different base types)
net/netfilter/ipvs/ip_vs_proto_tcp.c:196:6:    expected restricted __be16 [usertype] newlen
net/netfilter/ipvs/ip_vs_proto_tcp.c:196:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_tcp.c:270:6: warning: incorrect type in argument 5 (different base types)
net/netfilter/ipvs/ip_vs_proto_tcp.c:270:6:    expected restricted __be16 [usertype] oldlen
net/netfilter/ipvs/ip_vs_proto_tcp.c:270:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_tcp.c:271:6: warning: incorrect type in argument 6 (different base types)
net/netfilter/ipvs/ip_vs_proto_tcp.c:271:6:    expected restricted __be16 [usertype] newlen
net/netfilter/ipvs/ip_vs_proto_tcp.c:271:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_udp.c:206:6: warning: incorrect type in argument 5 (different base types)
net/netfilter/ipvs/ip_vs_proto_udp.c:206:6:    expected restricted __be16 [usertype] oldlen
net/netfilter/ipvs/ip_vs_proto_udp.c:206:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_udp.c:207:6: warning: incorrect type in argument 6 (different base types)
net/netfilter/ipvs/ip_vs_proto_udp.c:207:6:    expected restricted __be16 [usertype] newlen
net/netfilter/ipvs/ip_vs_proto_udp.c:207:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_udp.c:282:6: warning: incorrect type in argument 5 (different base types)
net/netfilter/ipvs/ip_vs_proto_udp.c:282:6:    expected restricted __be16 [usertype] oldlen
net/netfilter/ipvs/ip_vs_proto_udp.c:282:6:    got restricted __be32 [usertype] <noident>
net/netfilter/ipvs/ip_vs_proto_udp.c:283:6: warning: incorrect type in argument 6 (different base types)
net/netfilter/ipvs/ip_vs_proto_udp.c:283:6:    expected restricted __be16 [usertype] newlen
net/netfilter/ipvs/ip_vs_proto_udp.c:283:6:    got restricted __be32 [usertype] <noident>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 net/netfilter/ipvs/ip_vs_proto_tcp.c |    8 ++++----
 net/netfilter/ipvs/ip_vs_proto_udp.c |    8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_tcp.c b/net/netfilter/ipvs/ip_vs_proto_tcp.c
index dd4566e..8cba418 100644
--- a/net/netfilter/ipvs/ip_vs_proto_tcp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_tcp.c
@@ -192,8 +192,8 @@ tcp_snat_handler(struct sk_buff *skb,
 	/* Adjust TCP checksums */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
-					htonl(skb->len - tcphoff));
+					htons(oldlen),
+					htons(skb->len - tcphoff));
 	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
@@ -267,8 +267,8 @@ tcp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		tcp_partial_csum_update(cp->af, tcph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
-					htonl(skb->len - tcphoff));
+					htons(oldlen),
+					htons(skb->len - tcphoff));
 	} else if (!cp->app) {
 		/* Only port and addr are changed, do fast csum update */
 		tcp_fast_csum_update(cp->af, tcph, &cp->vaddr, &cp->daddr,
diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 6eb6039..d2930a7 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -203,8 +203,8 @@ udp_snat_handler(struct sk_buff *skb,
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
-					htonl(skb->len - udphoff));
+					htons(oldlen),
+					htons(skb->len - udphoff));
 	} else if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
@@ -279,8 +279,8 @@ udp_dnat_handler(struct sk_buff *skb,
 	 */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		udp_partial_csum_update(cp->af, udph, &cp->daddr, &cp->vaddr,
-					htonl(oldlen),
-					htonl(skb->len - udphoff));
+					htons(oldlen),
+					htons(skb->len - udphoff));
 	} else if (!cp->app && (udph->check != 0)) {
 		/* Only port and addr are changed, do fast csum update */
 		udp_fast_csum_update(cp->af, udph, &cp->vaddr, &cp->daddr,
-- 
1.6.0.3.756.gb776d



