From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/2] qdisc: make args to qdisc_create_default const
Date: Sat, 31 Aug 2013 10:15:50 -0700
Message-ID: <20130831101550.1f7582e4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:43381 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab3HaRRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 13:17:52 -0400
Received: by mail-pa0-f54.google.com with SMTP id kx10so3567782pab.13
        for <netdev@vger.kernel.org>; Sat, 31 Aug 2013 10:17:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes warnings introduced by the qdisc default patch.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/include/net/sch_generic.h	2013-08-31 09:40:20.933206054 -0700
+++ b/include/net/sch_generic.h	2013-08-31 09:50:18.309178508 -0700
@@ -370,9 +370,9 @@ void qdisc_reset(struct Qdisc *qdisc);
 void qdisc_destroy(struct Qdisc *qdisc);
 void qdisc_tree_decrease_qlen(struct Qdisc *qdisc, unsigned int n);
 struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
-			  struct Qdisc_ops *ops);
+			  const struct Qdisc_ops *ops);
 struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
-				struct Qdisc_ops *ops, u32 parentid);
+				const struct Qdisc_ops *ops, u32 parentid);
 void __qdisc_calculate_pkt_len(struct sk_buff *skb,
 			       const struct qdisc_size_table *stab);
 void tcf_destroy(struct tcf_proto *tp);
--- a/net/sched/sch_generic.c	2013-08-31 09:40:20.949205839 -0700
+++ b/net/sched/sch_generic.c	2013-08-31 09:50:18.313178455 -0700
@@ -534,7 +534,7 @@ struct Qdisc_ops pfifo_fast_ops __read_m
 static struct lock_class_key qdisc_tx_busylock;
 
 struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
-			  struct Qdisc_ops *ops)
+			  const struct Qdisc_ops *ops)
 {
 	void *p;
 	struct Qdisc *sch;
@@ -578,7 +578,8 @@ errout:
 }
 
 struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
-				struct Qdisc_ops *ops, unsigned int parentid)
+				const struct Qdisc_ops *ops,
+				unsigned int parentid)
 {
 	struct Qdisc *sch;
 
