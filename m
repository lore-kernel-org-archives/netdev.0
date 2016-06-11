From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ipv6: fix checksum annotation in udp6_csum_init
Date: Sat, 11 Jun 2016 21:15:37 +0200
Message-ID: <1465672537-26131-1-git-send-email-hannes@stressinduktion.org>
References: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35612 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751823AbcFKTSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 15:18:30 -0400
In-Reply-To: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Tom Herbert <tom@herbertland.com>
Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for UDP/IPv6")
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_checksum.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index b2025bf3da4af2..c0cbcb259f5a9a 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -78,9 +78,12 @@ int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 	 * we accept a checksum of zero here. When we find the socket
 	 * for the UDP packet we'll check if that socket allows zero checksum
 	 * for IPv6 (set by socket option).
+	 *
+	 * Note, we are only interested in != 0 or == 0, thus the
+	 * force to int.
 	 */
-	return skb_checksum_init_zero_check(skb, proto, uh->check,
-					   ip6_compute_pseudo);
+	return (__force int)skb_checksum_init_zero_check(skb, proto, uh->check,
+							 ip6_compute_pseudo);
 }
 EXPORT_SYMBOL(udp6_csum_init);
 
-- 
2.5.5
