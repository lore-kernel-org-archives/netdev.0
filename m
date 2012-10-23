From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] ipv6: fix sparse warnings in rt6_info_hash_nhsfn()
Date: Tue, 23 Oct 2012 11:35:06 +0200
Message-ID: <1350984906-24672-1-git-send-email-nicolas.dichtel@6wind.com>
References: <508653b5.7Vy7DCd02KcUpUab%fengguang.wu@intel.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60901 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932753Ab2JWJ0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 05:26:42 -0400
In-Reply-To: <508653b5.7Vy7DCd02KcUpUab%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding by commit 51ebd3181572 which adds the support of ECMP for IPv6.

Spotted-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/route.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 126da56..c42650c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -397,32 +397,32 @@ static int rt6_info_hash_nhsfn(unsigned int candidate_count,
 {
 	unsigned int val = fl6->flowi6_proto;
 
-	val ^= fl6->daddr.s6_addr32[0];
-	val ^= fl6->daddr.s6_addr32[1];
-	val ^= fl6->daddr.s6_addr32[2];
-	val ^= fl6->daddr.s6_addr32[3];
+	val ^= (__force u32)fl6->daddr.s6_addr32[0];
+	val ^= (__force u32)fl6->daddr.s6_addr32[1];
+	val ^= (__force u32)fl6->daddr.s6_addr32[2];
+	val ^= (__force u32)fl6->daddr.s6_addr32[3];
 
-	val ^= fl6->saddr.s6_addr32[0];
-	val ^= fl6->saddr.s6_addr32[1];
-	val ^= fl6->saddr.s6_addr32[2];
-	val ^= fl6->saddr.s6_addr32[3];
+	val ^= (__force u32)fl6->saddr.s6_addr32[0];
+	val ^= (__force u32)fl6->saddr.s6_addr32[1];
+	val ^= (__force u32)fl6->saddr.s6_addr32[2];
+	val ^= (__force u32)fl6->saddr.s6_addr32[3];
 
 	/* Work only if this not encapsulated */
 	switch (fl6->flowi6_proto) {
 	case IPPROTO_UDP:
 	case IPPROTO_TCP:
 	case IPPROTO_SCTP:
-		val ^= fl6->fl6_sport;
-		val ^= fl6->fl6_dport;
+		val ^= (__force u16)fl6->fl6_sport;
+		val ^= (__force u16)fl6->fl6_dport;
 		break;
 
 	case IPPROTO_ICMPV6:
-		val ^= fl6->fl6_icmp_type;
-		val ^= fl6->fl6_icmp_code;
+		val ^= (__force u16)fl6->fl6_icmp_type;
+		val ^= (__force u16)fl6->fl6_icmp_code;
 		break;
 	}
 	/* RFC6438 recommands to use flowlabel */
-	val ^= fl6->flowlabel;
+	val ^= (__force u32)fl6->flowlabel;
 
 	/* Perhaps, we need to tune, this function? */
 	val = val ^ (val >> 7) ^ (val >> 12);
-- 
1.7.12
