From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv4: Remove rt->rt_dst reference from
 ip_forward_options().
Date: Fri, 13 May 2011 17:51:47 -0400 (EDT)
Message-ID: <20110513.175147.1769699521454286707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238Ab1EMVvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:51:50 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4DLpmEt021461
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:51:48 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


At this point iph->daddr equals what rt->rt_dst would hold.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index 89268ba..c3118e1 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -567,7 +567,7 @@ void ip_forward_options(struct sk_buff *skb)
 		     ) {
 			if (srrptr + 3 > srrspace)
 				break;
-			if (memcmp(&rt->rt_dst, &optptr[srrptr-1], 4) == 0)
+			if (memcmp(&ip_hdr(skb)->daddr, &optptr[srrptr-1], 4) == 0)
 				break;
 		}
 		if (srrptr + 3 <= srrspace) {
-- 
1.7.4.4

