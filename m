From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] ipv6: use kcalloc
Date: Mon, 21 Jul 2008 12:28:39 -0700
Message-ID: <20080721192920.315583132@vyatta.com>
References: <20080721192834.221648982@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:38869 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254AbYGUTb1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:31:27 -0400
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

