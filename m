From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] route: use read_mostly
Date: Wed, 19 Mar 2008 10:11:47 -0700
Message-ID: <20080319101147.2d71238e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58060 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755747AbYCSTcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:32:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The route table parameters are set based on system memory and sysctl
values that almost never change. Also the genid only changes every
10 minutes.

RTprint is defined by never used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
This patch is for net-2.6.26

--- a/net/ipv4/route.c	2008-03-18 11:52:11.000000000 -0700
+++ b/net/ipv4/route.c	2008-03-18 11:54:41.000000000 -0700
@@ -118,21 +118,19 @@
 #define RT_GC_TIMEOUT (300*HZ)
 
 static int ip_rt_max_size;
-static int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
-static int ip_rt_gc_interval		= 60 * HZ;
-static int ip_rt_gc_min_interval	= HZ / 2;
-static int ip_rt_redirect_number	= 9;
-static int ip_rt_redirect_load		= HZ / 50;
-static int ip_rt_redirect_silence	= ((HZ / 50) << (9 + 1));
-static int ip_rt_error_cost		= HZ;
-static int ip_rt_error_burst		= 5 * HZ;
-static int ip_rt_gc_elasticity		= 8;
-static int ip_rt_mtu_expires		= 10 * 60 * HZ;
-static int ip_rt_min_pmtu		= 512 + 20 + 20;
-static int ip_rt_min_advmss		= 256;
-static int ip_rt_secret_interval	= 10 * 60 * HZ;
-
-#define RTprint(a...)	printk(KERN_DEBUG a)
+static int ip_rt_gc_timeout __read_mostly	= RT_GC_TIMEOUT;
+static int ip_rt_gc_interval __read_mostly	= 60 * HZ;
+static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
+static int ip_rt_redirect_number __read_mostly	= 9;
+static int ip_rt_redirect_load __read_mostly	= HZ / 50;
+static int ip_rt_redirect_silence __read_mostly	= ((HZ / 50) << (9 + 1));
+static int ip_rt_error_cost __read_mostly	= HZ;
+static int ip_rt_error_burst __read_mostly	= 5 * HZ;
+static int ip_rt_gc_elasticity __read_mostly	= 8;
+static int ip_rt_mtu_expires __read_mostly	= 10 * 60 * HZ;
+static int ip_rt_min_pmtu __read_mostly		= 512 + 20 + 20;
+static int ip_rt_min_advmss __read_mostly	= 256;
+static int ip_rt_secret_interval __read_mostly	= 10 * 60 * HZ;
 
 static void rt_worker_func(struct work_struct *work);
 static DECLARE_DELAYED_WORK(expires_work, rt_worker_func);
@@ -252,10 +250,10 @@ static inline void rt_hash_lock_init(voi
 }
 #endif
 
-static struct rt_hash_bucket 	*rt_hash_table;
-static unsigned			rt_hash_mask;
-static unsigned int		rt_hash_log;
-static atomic_t			rt_genid;
+static struct rt_hash_bucket 	*rt_hash_table __read_mostly;
+static unsigned			rt_hash_mask __read_mostly;
+static unsigned int		rt_hash_log  __read_mostly;
+static atomic_t			rt_genid __read_mostly;
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) \
