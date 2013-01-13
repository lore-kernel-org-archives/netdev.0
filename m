From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6 route: Use ipv6_addr_hash() in rt6_info_hash_nhsfn().
Date: Sun, 13 Jan 2013 17:32:03 +0900
Message-ID: <50F27103.7030300@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37807 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751688Ab3AMIcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 03:32:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 621b68e..c408566 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -388,15 +388,8 @@ static int rt6_info_hash_nhsfn(unsigned int candidate_count,
 {
 	unsigned int val = fl6->flowi6_proto;
 
-	val ^= (__force u32)fl6->daddr.s6_addr32[0];
-	val ^= (__force u32)fl6->daddr.s6_addr32[1];
-	val ^= (__force u32)fl6->daddr.s6_addr32[2];
-	val ^= (__force u32)fl6->daddr.s6_addr32[3];
-
-	val ^= (__force u32)fl6->saddr.s6_addr32[0];
-	val ^= (__force u32)fl6->saddr.s6_addr32[1];
-	val ^= (__force u32)fl6->saddr.s6_addr32[2];
-	val ^= (__force u32)fl6->saddr.s6_addr32[3];
+	val ^= ipv6_addr_hash(&fl6->daddr);
+	val ^= ipv6_addr_hash(&fl6->saddr);
 
 	/* Work only if this not encapsulated */
 	switch (fl6->flowi6_proto) {
-- 
1.7.9.5
