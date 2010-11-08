From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH 2/2] IPv6:  Warn users when route/max_entries is reached.
Date: Mon,  8 Nov 2010 11:13:49 -0800
Message-ID: <1289243629-20789-2-git-send-email-greearb@candelatech.com>
References: <1289243629-20789-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50718 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab0KHTOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 14:14:08 -0500
In-Reply-To: <1289243629-20789-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 a275c6e... 348b34c... M	net/ipv6/route.c
 net/ipv6/route.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a275c6e..348b34c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1060,8 +1060,12 @@ static int ip6_dst_gc(struct dst_ops *ops)
 	unsigned long rt_last_gc = net->ipv6.ip6_rt_last_gc;
 
 	if (time_after(rt_last_gc + rt_min_interval, now) &&
-	    atomic_read(&ops->entries) <= rt_max_size)
+	    atomic_read(&ops->entries) <= rt_max_size) {
+		if (net_ratelimit())
+			pr_warning("IPv6:  Maximum number of routes reached,"
+				   " consider increasing route/max_size.\n");
 		goto out;
+	}
 
 	net->ipv6.ip6_rt_gc_expire++;
 	fib6_run_gc(net->ipv6.ip6_rt_gc_expire, net);
-- 
1.6.2.5

