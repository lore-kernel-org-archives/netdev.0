From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] ipv6: use kcalloc
Date: Tue, 22 Jul 2008 14:29:31 -0700
Message-ID: <20080722212951.798632347@vyatta.com>
References: <20080722212927.937523165@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34398 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbYGVVbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:31:07 -0400
Content-Disposition: inline; filename=ipv6-kcalloc.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Th fib_table_hash is an array, so use kcalloc.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/ip6_fib.c	2008-07-21 12:21:15.000000000 -0700
+++ b/net/ipv6/ip6_fib.c	2008-07-21 12:21:15.000000000 -0700
@@ -1481,9 +1481,9 @@ static int fib6_net_init(struct net *net
 	if (!net->ipv6.rt6_stats)
 		goto out_timer;
 
-	net->ipv6.fib_table_hash =
-		kzalloc(sizeof(*net->ipv6.fib_table_hash)*FIB_TABLE_HASHSZ,
-			GFP_KERNEL);
+	net->ipv6.fib_table_hash = kcalloc(FIB_TABLE_HASHSZ,
+					   sizeof(*net->ipv6.fib_table_hash),
+					   GFP_KERNEL);
 	if (!net->ipv6.fib_table_hash)
 		goto out_rt6_stats;
 

-- 

