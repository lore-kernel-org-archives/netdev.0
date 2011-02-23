From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] mqprio: cleanups
Date: Wed, 23 Feb 2011 11:06:51 -0800
Message-ID: <20110223190701.144705172@vyatta.com>
References: <20110223190647.482444598@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:44644 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755562Ab1BWTxC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 14:53:02 -0500
Content-Disposition: inline; filename=mqprio-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* make qdisc_ops local 
* add sparse annotation about expected unlock/unlock in dump_class_stats
* fix indentation

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_mqprio.c	2011-02-23 10:22:17.171259588 -0800
+++ b/net/sched/sch_mqprio.c	2011-02-23 10:28:51.955835730 -0800
@@ -311,7 +311,9 @@ static int mqprio_dump_class(struct Qdis
 }
 
 static int mqprio_dump_class_stats(struct Qdisc *sch, unsigned long cl,
-			       struct gnet_dump *d)
+				   struct gnet_dump *d)
+	__releases(d->lock)
+	__acquires(d->lock)
 {
 	struct net_device *dev = qdisc_dev(sch);
 
@@ -389,7 +391,7 @@ static const struct Qdisc_class_ops mqpr
 	.dump_stats	= mqprio_dump_class_stats,
 };
 
-struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
+static struct Qdisc_ops mqprio_qdisc_ops __read_mostly = {
 	.cl_ops		= &mqprio_class_ops,
 	.id		= "mqprio",
 	.priv_size	= sizeof(struct mqprio_sched),


