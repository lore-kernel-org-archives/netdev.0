From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv4: route.c cleanup
Date: Thu, 02 Aug 2012 09:49:13 +0200
Message-ID: <1343893753.9299.13.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39008 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737Ab2HBHtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 03:49:20 -0400
Received: by bkwj10 with SMTP id j10so4107341bkw.19
        for <netdev@vger.kernel.org>; Thu, 02 Aug 2012 00:49:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove some unused includes and sysctls after route cache removal.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
This probably can wait net-next 

 net/ipv4/route.c |   58 ---------------------------------------------
 1 file changed, 1 insertion(+), 57 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c035251..67790ba 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -70,7 +70,6 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
-#include <linux/bootmem.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
@@ -80,7 +79,6 @@
 #include <linux/netdevice.h>
 #include <linux/proc_fs.h>
 #include <linux/init.h>
-#include <linux/workqueue.h>
 #include <linux/skbuff.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
@@ -88,11 +86,9 @@
 #include <linux/mroute.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/random.h>
-#include <linux/jhash.h>
 #include <linux/rcupdate.h>
 #include <linux/times.h>
 #include <linux/slab.h>
-#include <linux/prefetch.h>
 #include <net/dst.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
@@ -118,18 +114,11 @@
 
 #define IP_MAX_MTU	0xFFF0
 
-#define RT_GC_TIMEOUT (300*HZ)
-
-static int ip_rt_max_size;
-static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
-static int ip_rt_gc_interval __read_mostly  = 60 * HZ;
-static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
 static int ip_rt_redirect_number __read_mostly	= 9;
 static int ip_rt_redirect_load __read_mostly	= HZ / 50;
 static int ip_rt_redirect_silence __read_mostly	= ((HZ / 50) << (9 + 1));
 static int ip_rt_error_cost __read_mostly	= HZ;
 static int ip_rt_error_burst __read_mostly	= 5 * HZ;
-static int ip_rt_gc_elasticity __read_mostly	= 8;
 static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
 static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
 static int ip_rt_min_advmss __read_mostly	= 256;
@@ -2382,43 +2371,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "max_size",
-		.data		= &ip_rt_max_size,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
-		/*  Deprecated. Use gc_min_interval_ms */
-
-		.procname	= "gc_min_interval",
-		.data		= &ip_rt_gc_min_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "gc_min_interval_ms",
-		.data		= &ip_rt_gc_min_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_ms_jiffies,
-	},
-	{
-		.procname	= "gc_timeout",
-		.data		= &ip_rt_gc_timeout,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
-		.procname	= "gc_interval",
-		.data		= &ip_rt_gc_interval,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec_jiffies,
-	},
-	{
 		.procname	= "redirect_load",
 		.data		= &ip_rt_redirect_load,
 		.maxlen		= sizeof(int),
@@ -2454,13 +2406,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.procname	= "gc_elasticity",
-		.data		= &ip_rt_gc_elasticity,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
-	},
-	{
 		.procname	= "mtu_expires",
 		.data		= &ip_rt_mtu_expires,
 		.maxlen		= sizeof(int),
@@ -2599,7 +2544,6 @@ int __init ip_rt_init(void)
 		panic("IP: failed to allocate ipv4_dst_blackhole_ops counter\n");
 
 	ipv4_dst_ops.gc_thresh = ~0;
-	ip_rt_max_size = INT_MAX;
 
 	devinet_init();
 	ip_fib_init();
@@ -2608,7 +2552,7 @@ int __init ip_rt_init(void)
 		pr_err("Unable to create route proc files\n");
 #ifdef CONFIG_XFRM
 	xfrm_init();
-	xfrm4_init(ip_rt_max_size);
+	xfrm4_init(INT_MAX);
 #endif
 	rtnl_register(PF_INET, RTM_GETROUTE, inet_rtm_getroute, NULL, NULL);
 
