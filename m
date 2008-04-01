From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] IPV4: route rekey timer can be deferrable
Date: Mon, 31 Mar 2008 17:47:14 -0700
Message-ID: <20080401004724.826913057@vyatta.com>
References: <20080401004708.009204033@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:40014 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbYDACbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 22:31:34 -0400
Content-Disposition: inline; filename=route-defer
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No urgency on the rehash interval timer, so mark it as deferrable.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/route.c	2008-03-31 11:22:17.000000000 -0700
+++ b/net/ipv4/route.c	2008-03-31 11:22:19.000000000 -0700
@@ -3058,7 +3058,9 @@ int __init ip_rt_init(void)
 	devinet_init();
 	ip_fib_init();
 
-	setup_timer(&rt_secret_timer, rt_secret_rebuild, 0);
+	rt_secret_timer.function = rt_secret_rebuild;
+	rt_secret_timer.data = 0;
+	init_timer_deferrable(&rt_secret_timer);
 
 	/* All the timers, started at system startup tend
 	   to synchronize. Perturb it a bit.

-- 

