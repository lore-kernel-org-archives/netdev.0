From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] PKT_SCHED: Qdisc are not supposed to dump TCA_STATS themselves
Date: Thu, 7 Oct 2004 03:08:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007010819.GF18621@postel.suug.ch>
References: <20041007010146.GA18621@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041007010146.GA18621@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hfsc and htb qdisc are not supposed to copy TCA_STATS
on their own and queue length statistic is already
updated in generic code part.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_hfsc.c linux-2.6.9-rc3-bk6/net/sched/sch_hfsc.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_hfsc.c	2004-10-07 00:32:25.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_hfsc.c	2004-10-07 00:55:35.000000000 +0200
@@ -1653,11 +1653,6 @@
 
 	qopt.defcls = q->defcls;
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
-
-	sch->stats.qlen = sch->q.qlen;
-	if (qdisc_copy_stats(skb, &sch->stats, sch->stats_lock) < 0)
-		goto rtattr_failure;
-
 	return skb->len;
 
  rtattr_failure:
diff -Nru linux-2.6.9-rc3-bk6.orig/net/sched/sch_htb.c linux-2.6.9-rc3-bk6/net/sched/sch_htb.c
--- linux-2.6.9-rc3-bk6.orig/net/sched/sch_htb.c	2004-10-07 00:32:25.000000000 +0200
+++ linux-2.6.9-rc3-bk6/net/sched/sch_htb.c	2004-10-07 00:55:22.000000000 +0200
@@ -1332,8 +1332,6 @@
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	rta->rta_len = skb->tail - b;
-	sch->stats.qlen = sch->q.qlen;
-	RTA_PUT(skb, TCA_STATS, sizeof(sch->stats), &sch->stats);
 	HTB_QUNLOCK(sch);
 	return skb->len;
 rtattr_failure:
