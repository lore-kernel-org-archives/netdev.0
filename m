From: Jeff Garzik <jgarzik@pobox.com>
Subject: [patch 2.4][fyi] s/blog_dev/backlog_dev/ in process_backlog
Date: Mon, 1 Sep 2003 15:34:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901193417.GA7519@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Since I was patching this area anyway...  Queued locally.
Patch only for 2.4.x.  See BK description for more.


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1126  -> 1.1127 
#	      net/core/dev.c	1.39    -> 1.40   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/09/01	jgarzik@redhat.com	1.1127
# [NET] s/blog_dev/backlog_dev/ in process_backlog, net/core/dev.c
# 
# This 100% cosmetic change reduces the diff between 2.4 and 2.5.
# --------------------------------------------
#
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Mon Sep  1 15:32:25 2003
+++ b/net/core/dev.c	Mon Sep  1 15:32:25 2003
@@ -1535,10 +1535,10 @@
 	return ret;
 }
 
-static int process_backlog(struct net_device *blog_dev, int *budget)
+static int process_backlog(struct net_device *backlog_dev, int *budget)
 {
 	int work = 0;
-	int quota = min(blog_dev->quota, *budget);
+	int quota = min(backlog_dev->quota, *budget);
 	int this_cpu = smp_processor_id();
 	struct softnet_data *queue = &softnet_data[this_cpu];
 	unsigned long start_time = jiffies;
@@ -1575,17 +1575,17 @@
 #endif
 	}
 
-	blog_dev->quota -= work;
+	backlog_dev->quota -= work;
 	*budget -= work;
 	return -1;
 
 job_done:
-	blog_dev->quota -= work;
+	backlog_dev->quota -= work;
 	*budget -= work;
 
-	list_del(&blog_dev->poll_list);
+	list_del(&backlog_dev->poll_list);
 	smp_mb__before_clear_bit();
-	netif_poll_enable(blog_dev);
+	netif_poll_enable(backlog_dev);
 
 	if (queue->throttle) {
 		queue->throttle = 0;
