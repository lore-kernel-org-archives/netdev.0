From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/14] pktgen: minor cleanup
Date: Thu, 27 Aug 2009 16:55:07 -0700
Message-ID: <20090827235705.180069973@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:35395 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751545AbZH0X7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:12 -0400
Content-Disposition: inline; filename=pktgen-fseen.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of minor functions can be written more compactly.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/core/pktgen.c |   25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:03:07.270217291 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:14.759765248 -0700
@@ -509,7 +509,7 @@ static const struct file_operations pktg
 
 static int pktgen_if_show(struct seq_file *seq, void *v)
 {
-	struct pktgen_dev *pkt_dev = seq->private;
+	const struct pktgen_dev *pkt_dev = seq->private;
 	__u64 sa;
 	__u64 stopped;
 	__u64 now = getCurUs();
@@ -1670,7 +1670,7 @@ static const struct file_operations pktg
 static int pktgen_thread_show(struct seq_file *seq, void *v)
 {
 	struct pktgen_thread *t = seq->private;
-	struct pktgen_dev *pkt_dev;
+	const struct pktgen_dev *pkt_dev;
 
 	BUG_ON(!t);
 
@@ -2120,13 +2120,9 @@ static inline void set_pkt_overhead(stru
 	pkt_dev->pkt_overhead += SVLAN_TAG_SIZE(pkt_dev);
 }
 
-static inline int f_seen(struct pktgen_dev *pkt_dev, int flow)
+static inline int f_seen(const struct pktgen_dev *pkt_dev, int flow)
 {
-
-	if (pkt_dev->flows[flow].flags & F_INIT)
-		return 1;
-	else
-		return 0;
+	return !!(pkt_dev->flows[flow].flags & F_INIT);
 }
 
 static inline int f_pick(struct pktgen_dev *pkt_dev)
@@ -3101,17 +3097,14 @@ static void pktgen_stop_all_threads_ifs(
 	mutex_unlock(&pktgen_thread_lock);
 }
 
-static int thread_is_running(struct pktgen_thread *t)
+static int thread_is_running(const struct pktgen_thread *t)
 {
-	struct pktgen_dev *pkt_dev;
-	int res = 0;
+	const struct pktgen_dev *pkt_dev;
 
 	list_for_each_entry(pkt_dev, &t->if_list, list)
-		if (pkt_dev->running) {
-			res = 1;
-			break;
-		}
-	return res;
+		if (pkt_dev->running)
+			return 1;
+	return 0;
 }
 
 static int pktgen_wait_thread_run(struct pktgen_thread *t)

-- 

