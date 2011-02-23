From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 6/6] netem: update version and cleanup
Date: Wed, 23 Feb 2011 15:04:22 -0800
Message-ID: <20110223230534.552847315@vyatta.com>
References: <20110223230416.532009518@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47479 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754278Ab1BWXHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:07:51 -0500
Content-Disposition: inline; filename=netem-update.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of debug message that are not useful, and enable
the log messages in case of error.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/sched/sch_netem.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

--- a/net/sched/sch_netem.c	2011-02-23 15:01:29.159338952 -0800
+++ b/net/sched/sch_netem.c	2011-02-23 15:02:00.451849096 -0800
@@ -24,7 +24,7 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 
-#define VERSION "1.2"
+#define VERSION "1.3"
 
 /*	Network Emulation Queuing algorithm.
 	====================================
@@ -311,8 +311,6 @@ static int netem_enqueue(struct sk_buff
 	int ret;
 	int count = 1;
 
-	pr_debug("netem_enqueue skb=%p\n", skb);
-
 	/* Random duplication */
 	if (q->duplicate && q->duplicate >= get_crandom(&q->dup_cor))
 		++count;
@@ -633,7 +631,7 @@ static int netem_change(struct Qdisc *sc
 
 	ret = fifo_set_limit(q->qdisc, qopt->limit);
 	if (ret) {
-		pr_debug("netem: can't set fifo limit\n");
+		pr_info("netem: can't set fifo limit\n");
 		return ret;
 	}
 
@@ -769,13 +767,13 @@ static int netem_init(struct Qdisc *sch,
 	q->qdisc = qdisc_create_dflt(sch->dev_queue, &tfifo_qdisc_ops,
 				     TC_H_MAKE(sch->handle, 1));
 	if (!q->qdisc) {
-		pr_debug("netem: qdisc create failed\n");
+		pr_notice("netem: qdisc create tfifo qdisc failed\n");
 		return -ENOMEM;
 	}
 
 	ret = netem_change(sch, opt);
 	if (ret) {
-		pr_debug("netem: change failed\n");
+		pr_info("netem: change failed\n");
 		qdisc_destroy(q->qdisc);
 	}
 	return ret;


