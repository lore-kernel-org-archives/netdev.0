From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/5] ipv6: use spin_trylock_bh
Date: Tue, 22 Jul 2008 14:29:30 -0700
Message-ID: <20080722212951.706497135@vyatta.com>
References: <20080722212927.937523165@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34395 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294AbYGVVbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:31:06 -0400
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

