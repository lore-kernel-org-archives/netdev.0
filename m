From: Jack Steiner <steiner@sgi.com>
Subject: FW: [PATCH] - Incorrect cpumask definition in net/core/flow.c
Date: Fri, 7 Nov 2003 16:37:29 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031107223729.GA20687@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(I sent this to akpm earlier - I think I sent it to the wrong  list)



This fixes a problem in net/core/flow.c. 

The field "cpumap" is defined as a "unsigned long". It 
should be a "cpumask_t".



# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1402  -> 1.1403 
#	     net/core/flow.c	1.15    -> 1.16   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/11/07	steiner@attica.americas.sgi.com	1.1403
# Change cpumap definition from "unsigned long" to "cpumask_t". 
# --------------------------------------------
#



diff -Nru a/net/core/flow.c b/net/core/flow.c
--- a/net/core/flow.c	Fri Nov  7 15:04:08 2003
+++ b/net/core/flow.c	Fri Nov  7 15:04:08 2003
@@ -65,7 +65,7 @@
 
 struct flow_flush_info {
 	atomic_t cpuleft;
-	unsigned long cpumap;
+	cpumask_t cpumap;
 	struct completion completion;
 };
 static DEFINE_PER_CPU(struct tasklet_struct, flow_flush_tasklets) = { NULL };
@@ -73,7 +73,7 @@
 #define flow_flush_tasklet(cpu) (&per_cpu(flow_flush_tasklets, cpu))
 
 static DECLARE_MUTEX(flow_cache_cpu_sem);
-static unsigned long flow_cache_cpu_map;
+static cpumask_t flow_cache_cpu_map;
 static unsigned int flow_cache_cpu_count;
 
 static void flow_cache_new_hashrnd(unsigned long arg)



-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.
