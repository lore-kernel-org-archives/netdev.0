From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] gc_min_interval in milleseconds via /proc (fwd)
Date: Thu, 27 Jan 2005 13:13:04 +0100
Message-ID: <16888.56016.608929.340640@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 > David S. Miller wrote:

 > It would, but since this is a user visible API we really can't
 > change it.
 
  Ok! But I haven't heard of any successful use of this paticaul API. :-)

 > We could instead make another sysctl (perhaps name it something
 > like "gc_min_interval_ms") to do what you propose, and then
 > we'd keep the existing one around for compatibility.

 All-right a new patch below. 
					--ro
  

--- net/ipv4/route.c.orig	2005-01-27 11:19:37.551668112 +0100
+++ net/ipv4/route.c	2005-01-27 12:34:14.089130976 +0100
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
+		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL,
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
--- Documentation/filesystems/proc.txt.orig	2005-01-27 12:35:02.460777368 +0100
+++ Documentation/filesystems/proc.txt	2005-01-27 12:46:30.981106368 +0100
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

 
