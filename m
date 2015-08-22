From: Phil Sutter <phil@nwl.cc>
Subject: [net-next PATCH v2 1/3] net: sched: make noqueue_qdisc non-static
Date: Sat, 22 Aug 2015 02:20:54 +0200
Message-ID: <1440202856-1645-2-git-send-email-phil@nwl.cc>
References: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:45208 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbbHVAU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 20:20:58 -0400
In-Reply-To: <1440202856-1645-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This needs to be referenced from within net/sched/sched_api.c later.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/net/sch_generic.h | 1 +
 net/sched/sch_generic.c   | 3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 2eab08c..4495193 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -337,6 +337,7 @@ static inline void sch_tree_unlock(const struct Qdisc *q)
 #define tcf_tree_unlock(tp)	sch_tree_unlock((tp)->q)
 
 extern struct Qdisc noop_qdisc;
+extern struct Qdisc noqueue_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_fast_ops;
 extern struct Qdisc_ops mq_qdisc_ops;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 942fea8..1fb65f9 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -425,13 +425,12 @@ static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.owner		=	THIS_MODULE,
 };
 
-static struct Qdisc noqueue_qdisc;
 static struct netdev_queue noqueue_netdev_queue = {
 	.qdisc		=	&noqueue_qdisc,
 	.qdisc_sleeping	=	&noqueue_qdisc,
 };
 
-static struct Qdisc noqueue_qdisc = {
+struct Qdisc noqueue_qdisc = {
 	.enqueue	=	NULL,
 	.dequeue	=	noop_dequeue,
 	.flags		=	TCQ_F_BUILTIN,
-- 
2.1.2
