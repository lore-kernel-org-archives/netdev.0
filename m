From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.4] PKT_SCHED: Avoid duplicated TCA_STATS TLVs for HTB and HFSC
Date: Fri, 22 Oct 2004 12:05:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022100517.GY21977@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dave,

Backport of the equivalent 2.6 fixes.

Qdiscs are not supposed to dump TCA_STATS, it is done in generic code part.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.4.28-pre4-bk6.orig/net/sched/sch_htb.c	2004-10-22 10:58:23.000000000 +0200
+++ linux-2.4.28-pre4-bk6/net/sched/sch_htb.c	2004-10-22 10:59:30.000000000 +0200
@@ -1287,8 +1287,6 @@
 	RTA_PUT(skb, TCA_OPTIONS, 0, NULL);
 	RTA_PUT(skb, TCA_HTB_INIT, sizeof(gopt), &gopt);
 	rta->rta_len = skb->tail - b;
-	sch->stats.qlen = sch->q.qlen;
-	RTA_PUT(skb, TCA_STATS, sizeof(sch->stats), &sch->stats);
 	HTB_QUNLOCK(sch);
 	return skb->len;
 rtattr_failure:
--- linux-2.4.28-pre4-bk6.orig/net/sched/sch_hfsc.c	2004-10-22 10:58:23.000000000 +0200
+++ linux-2.4.28-pre4-bk6/net/sched/sch_hfsc.c	2004-10-22 11:00:46.000000000 +0200
@@ -1628,10 +1628,6 @@
 	qopt.defcls = q->defcls;
 	RTA_PUT(skb, TCA_OPTIONS, sizeof(qopt), &qopt);
 
-	sch->stats.qlen = sch->q.qlen;
-	if (qdisc_copy_stats(skb, &sch->stats) < 0)
-		goto rtattr_failure;
-
 	return skb->len;
 
  rtattr_failure:
