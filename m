From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH] net: sched: document attach_default_qdiscs
Date: Mon, 14 Sep 2015 17:31:30 +0200
Message-ID: <1442244690-6672-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:37161 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754239AbbINPbd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2015 11:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The process of selecting an interface's default qdisc is not really
intuitive, at least because there are three different cases to consider.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/sched/sch_generic.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index cb5d4ad..d7eaa51 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -741,6 +741,18 @@ static void attach_one_default_qdisc(struct net_device *dev,
 	dev_queue->qdisc_sleeping = qdisc;
 }
 
+/**
+ *	attach_default_qdiscs - set qdiscs back to default
+ *	@dev: network device to attach to
+ *
+ * This function attaches the (configurable) default qdisc to
+ * an interface.
+ * The actual default depends: Non-MQ, physical interfaces
+ * get whatever default_qdisc_ops has been set to. Multiqueue
+ * interfaces get mq, which uses default_qdisc_ops for it's
+ * leaves. Finally, virtual interfaces unconditionally
+ * default to noqueue.
+ */
 static void attach_default_qdiscs(struct net_device *dev)
 {
 	struct netdev_queue *txq;
-- 
2.1.2
