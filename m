From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/5] ipv6: use round_jiffies
Date: Tue, 22 Jul 2008 14:29:29 -0700
Message-ID: <20080722212951.629007462@vyatta.com>
References: <20080722212927.937523165@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34392 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbYGVVbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:31:05 -0400
Content-Disposition: inline; filename=ipv6-round.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This timer normally happens once a minute, there is no need to cause an
early wakeup for it, so align it to next second boundary to safe power.
It can't be deferred because then it could take too long on cleanup or DoS.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv6/ip6_fib.c	2008-07-21 12:06:44.000000000 -0700
+++ b/net/ipv6/ip6_fib.c	2008-07-21 12:07:41.000000000 -0700
@@ -1462,8 +1462,9 @@ void fib6_run_gc(unsigned long expires, 
 	fib6_clean_all(net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
-		mod_timer(&net->ipv6.ip6_fib_timer, jiffies +
-			  net->ipv6.sysctl.ip6_rt_gc_interval);
+		mod_timer(&net->ipv6.ip6_fib_timer,
+			  round_jiffies(jiffies
+					+ net->ipv6.sysctl.ip6_rt_gc_interval));
 	else
 		del_timer(&net->ipv6.ip6_fib_timer);
 	spin_unlock_bh(&fib6_gc_lock);

-- 

