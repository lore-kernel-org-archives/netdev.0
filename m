From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] gc_min_interval in milleseconds via /proc (fwd)
Date: Mon, 31 Jan 2005 19:01:05 +0100
Message-ID: <16894.29281.293401.832567@robur.slu.se>
References: <16888.56016.608929.340640@robur.slu.se>
	<20050130225627.4feecd2e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050130225627.4feecd2e.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:

 > We must pick a new sysctl number too, for sysctl() system call.
 > If the only access possible were through /proc then yes your
 > change would be valid, but due to sysctl() system call the
 > .ctl_name defines that dimension of the sysctl namespace.

 Ok!
 NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS was added last in list to avoid
 renumbering. Feel free to change.

					--ro

--- include/linux/sysctl.h.orig	2005-01-31 18:36:11.524393024 +0100
+++ include/linux/sysctl.h	2005-01-31 18:37:41.843662408 +0100
@@ -365,6 +365,7 @@
 	NET_IPV4_ROUTE_MIN_PMTU=16,
 	NET_IPV4_ROUTE_MIN_ADVMSS=17,
 	NET_IPV4_ROUTE_SECRET_INTERVAL=18,
+	NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS=19
 };
 
 enum
--- net/ipv4/route.c.orig	2005-01-27 11:19:37.000000000 +0100
+++ net/ipv4/route.c	2005-01-31 18:35:20.552141984 +0100
@@ -2529,6 +2529,8 @@
 		.proc_handler	= &proc_dointvec,
 	},
 	{
+		/*  Deprecated. Use gc_min_interval_ms */
+ 
 		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL,
 		.procname	= "gc_min_interval",
 		.data		= &ip_rt_gc_min_interval,
@@ -2538,6 +2540,15 @@
 		.strategy	= &sysctl_jiffies,
 	},
 	{
+		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS,
+		.procname	= "gc_min_interval_ms",
+		.data		= &ip_rt_gc_min_interval,
+		.maxlen		= sizeof(unsigned long),
+		.mode		= 0644,
+		.proc_handler	= &proc_doulongvec_ms_jiffies_minmax,
+		.strategy	= &sysctl_jiffies,
+	},
+	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_TIMEOUT,
 		.procname	= "gc_timeout",
 		.data		= &ip_rt_gc_timeout,
--- Documentation/filesystems/proc.txt.orig	2005-01-27 12:35:02.000000000 +0100
+++ Documentation/filesystems/proc.txt	2005-01-27 12:46:30.000000000 +0100
@@ -1709,12 +1709,13 @@
 
 Writing to this file results in a flush of the routing cache.
 
-gc_elasticity, gc_interval, gc_min_interval, gc_tresh, gc_timeout,
-gc_thresh, gc_thresh1, gc_thresh2, gc_thresh3
---------------------------------------------------------------
+gc_elasticity, gc_interval, gc_min_interval_ms, gc_timeout, gc_thresh
+---------------------------------------------------------------------
 
 Values to  control  the  frequency  and  behavior  of  the  garbage collection
-algorithm for the routing cache.
+algorithm for the routing cache. gc_min_interval is deprecated and replaced
+by gc_min_interval_ms.
+
 
 max_size
 --------
