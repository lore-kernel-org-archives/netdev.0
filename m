From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: fix checksum annotation in udp6_csum_init
Date: Sat, 11 Jun 2016 20:56:41 +0200
Message-ID: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org>
Cc: Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43393 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751883AbcFKS5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 14:57:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Tom Herbert <tom@herbertland.com>
Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for UDP/IPv6")
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip6_checksum.h | 2 +-
 net/ipv6/ip6_checksum.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_checksum.h b/include/net/ip6_checksum.h
index cca840584c8885..8ee93d1fc56a5b 100644
--- a/include/net/ip6_checksum.h
+++ b/include/net/ip6_checksum.h
@@ -101,5 +101,5 @@ void udp6_set_csum(bool nocheck, struct sk_buff *skb,
 		   const struct in6_addr *saddr,
 		   const struct in6_addr *daddr, int len);
 
-int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
+__sum16 udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto);
 #endif
diff --git a/net/ipv6/ip6_checksum.c b/net/ipv6/ip6_checksum.c
index b2025bf3da4af2..9282326e4a0a56 100644
--- a/net/ipv6/ip6_checksum.c
+++ b/net/ipv6/ip6_checksum.c
@@ -61,7 +61,7 @@ __sum16 csum_ipv6_magic(const struct in6_addr *saddr,
 EXPORT_SYMBOL(csum_ipv6_magic);
 #endif
 
-int udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
+__sum16 udp6_csum_init(struct sk_buff *skb, struct udphdr *uh, int proto)
 {
 	int err;
 
-- 
2.5.5
