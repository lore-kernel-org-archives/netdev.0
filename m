From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] ipv4: Simplify iph->daddr overwrite in
 ip_options_rcv_srr().
Date: Thu, 12 May 2011 19:38:59 -0400 (EDT)
Message-ID: <20110512.193859.1614180040999869677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38632 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882Ab1ELXjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 19:39:03 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4CNcxki008078
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 16:39:01 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We already copy the 4-byte nexthop from the options block into
local variable "nexthop" for the route lookup.

Re-use that variable instead of memcpy()'ing again when assigning
to iph->daddr after the route lookup succeeds.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index e82c304..c5c2619 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -635,7 +635,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 		if (rt2->rt_type != RTN_LOCAL)
 			break;
 		/* Superfast 8) loopback forward */
-		memcpy(&iph->daddr, &optptr[srrptr-1], 4);
+		iph->daddr = nexthop;
 		opt->is_changed = 1;
 	}
 	if (srrptr <= srrspace) {
-- 
1.7.4.4

