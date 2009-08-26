From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 4/4] pktgen: minor cleanup
Date: Tue, 25 Aug 2009 23:15:17 -0700
Message-ID: <20090826061728.849284290@vyatta.com>
References: <20090826061513.755294685@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36522 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbZHZG0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 02:26:03 -0400
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline; filename=pktgen-fseen.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A couple of minor functions can be written more compactly.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/core/pktgen.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- a/net/core/pktgen.c	2009-08-25 22:51:21.162461840 -0700
+++ b/net/core/pktgen.c	2009-08-25 22:56:01.282586584 -0700
@@ -507,7 +507,7 @@ static const struct file_operations pktg
 
 static int pktgen_if_show(struct seq_file *seq, void *v)
 {
-	struct pktgen_dev *pkt_dev = seq->private;
+	const struct pktgen_dev *pkt_dev = seq->private;
 	ktime_t stopped;
 	struct timeval trun, idle;
 
@@ -1666,7 +1666,7 @@ static const struct file_operations pktg
 static int pktgen_thread_show(struct seq_file *seq, void *v)
 {
 	struct pktgen_thread *t = seq->private;
-	struct pktgen_dev *pkt_dev;
+	const struct pktgen_dev *pkt_dev;
 
 	BUG_ON(!t);
 
@@ -2121,13 +2121,9 @@ static inline void set_pkt_overhead(stru
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
@@ -3102,17 +3098,14 @@ static void pktgen_stop_all_threads_ifs(
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

