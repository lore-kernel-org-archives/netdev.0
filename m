From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] ipv6: use spin_trylock_bh
Date: Mon, 21 Jul 2008 12:28:38 -0700
Message-ID: <20080721192920.230187113@vyatta.com>
References: <20080721192834.221648982@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:38865 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754252AbYGUTb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:31:26 -0400
Content-Disposition: inline; filename=ipv6-spin-lock-bh.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now there is spin_trylock_bh, use it rather than open coding.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/ip6_fib.c	2008-07-21 12:11:46.000000000 -0700
+++ b/net/ipv6/ip6_fib.c	2008-07-21 12:17:52.000000000 -0700
@@ -1447,10 +1447,8 @@ void fib6_run_gc(unsigned long expires, 
 		gc_args.timeout = expires ? (int)expires :
 			net->ipv6.sysctl.ip6_rt_gc_interval;
 	} else {
-		local_bh_disable();
-		if (!spin_trylock(&fib6_gc_lock)) {
+		if (!spin_trylock_bh(&fib6_gc_lock)) {
 			mod_timer(&net->ipv6.ip6_fib_timer, jiffies + HZ);
-			local_bh_enable();
 			return;
 		}
 		gc_args.timeout = net->ipv6.sysctl.ip6_rt_gc_interval;

-- 

