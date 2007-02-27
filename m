From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] pktgen: use pr_debug
Date: Tue, 27 Feb 2007 12:04:47 -0800
Message-ID: <20070227120447.55a7e39d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52666 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564AbXB0VTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 16:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove private debug macro and replace with standard version

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 net/core/pktgen.c |   34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

--- pktgen.orig/net/core/pktgen.c	2007-02-26 13:21:54.000000000 -0800
+++ pktgen/net/core/pktgen.c	2007-02-26 13:22:04.000000000 -0800
@@ -163,9 +163,6 @@
 
 #define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
 
-/* #define PG_DEBUG(a) a */
-#define PG_DEBUG(a)
-
 /* The buckets are exponential in 'width' */
 #define LAT_BUCKETS_MAX 32
 #define IP_NAME_SZ 32
@@ -1856,8 +1853,7 @@
 	int ret = 0;
 
 	mutex_lock(&pktgen_thread_lock);
-	PG_DEBUG(printk("pktgen: pktgen_mark_device marking %s for removal\n",
-			ifname));
+	pr_debug("pktgen: pktgen_mark_device marking %s for removal\n", ifname);
 
 	while (1) {
 
@@ -1866,8 +1862,8 @@
 			break;	/* success */
 
 		mutex_unlock(&pktgen_thread_lock);
-		PG_DEBUG(printk("pktgen: pktgen_mark_device waiting for %s "
-				"to disappear....\n", ifname));
+		pr_debug("pktgen: pktgen_mark_device waiting for %s "
+				"to disappear....\n", ifname);
 		schedule_timeout_interruptible(msecs_to_jiffies(msec_per_try));
 		mutex_lock(&pktgen_thread_lock);
 
@@ -2847,7 +2843,7 @@
 	struct pktgen_dev *pkt_dev;
 	int started = 0;
 
-	PG_DEBUG(printk("pktgen: entering pktgen_run. %p\n", t));
+	pr_debug("pktgen: entering pktgen_run. %p\n", t);
 
 	if_lock(t);
 	list_for_each_entry(pkt_dev, &t->if_list, list) {
@@ -2879,7 +2875,7 @@
 {
 	struct pktgen_thread *t;
 
-	PG_DEBUG(printk("pktgen: entering pktgen_stop_all_threads_ifs.\n"));
+	pr_debug("pktgen: entering pktgen_stop_all_threads_ifs.\n");
 
 	mutex_lock(&pktgen_thread_lock);
 
@@ -2947,7 +2943,7 @@
 {
 	struct pktgen_thread *t;
 
-	PG_DEBUG(printk("pktgen: entering pktgen_run_all_threads.\n"));
+	pr_debug("pktgen: entering pktgen_run_all_threads.\n");
 
 	mutex_lock(&pktgen_thread_lock);
 
@@ -3039,7 +3035,7 @@
 {
 	struct pktgen_dev *pkt_dev;
 
-	PG_DEBUG(printk("pktgen: entering pktgen_stop\n"));
+	pr_debug("pktgen: entering pktgen_stop\n");
 
 	if_lock(t);
 
@@ -3063,7 +3059,7 @@
 	struct list_head *q, *n;
 	struct pktgen_dev *cur;
 
-	PG_DEBUG(printk("pktgen: entering pktgen_rem_one_if\n"));
+	pr_debug("pktgen: entering pktgen_rem_one_if\n");
 
 	if_lock(t);
 
@@ -3092,7 +3088,7 @@
 
 	/* Remove all devices, free mem */
 
-	PG_DEBUG(printk("pktgen: entering pktgen_rem_all_ifs\n"));
+	pr_debug("pktgen: entering pktgen_rem_all_ifs\n");
 	if_lock(t);
 
 	list_for_each_safe(q, n, &t->if_list) {
@@ -3275,7 +3271,7 @@
 
 	t->pid = current->pid;
 
-	PG_DEBUG(printk("pktgen: starting pktgen/%d:  pid=%d\n", cpu, current->pid));
+	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n", cpu, current->pid);
 
 	max_before_softirq = t->max_before_softirq;
 
@@ -3336,13 +3332,13 @@
 		set_current_state(TASK_INTERRUPTIBLE);
 	}
 
-	PG_DEBUG(printk("pktgen: %s stopping all device\n", t->tsk->comm));
+	pr_debug("pktgen: %s stopping all device\n", t->tsk->comm);
 	pktgen_stop(t);
 
-	PG_DEBUG(printk("pktgen: %s removing all device\n", t->tsk->comm));
+	pr_debug("pktgen: %s removing all device\n", t->tsk->comm);
 	pktgen_rem_all_ifs(t);
 
-	PG_DEBUG(printk("pktgen: %s removing thread.\n", t->tsk->comm));
+	pr_debug("pktgen: %s removing thread.\n", t->tsk->comm);
 	pktgen_rem_thread(t);
 
 	return 0;
@@ -3361,7 +3357,7 @@
 		}
 
 	if_unlock(t);
-	PG_DEBUG(printk("pktgen: find_dev(%s) returning %p\n", ifname, pkt_dev));
+	pr_debug("pktgen: find_dev(%s) returning %p\n", ifname, pkt_dev);
 	return pkt_dev;
 }
 
@@ -3530,7 +3526,7 @@
 				struct pktgen_dev *pkt_dev)
 {
 
-	PG_DEBUG(printk("pktgen: remove_device pkt_dev=%p\n", pkt_dev));
+	pr_debug("pktgen: remove_device pkt_dev=%p\n", pkt_dev);
 
 	if (pkt_dev->running) {
 		printk("pktgen:WARNING: trying to remove a running interface, stopping it now.\n");
