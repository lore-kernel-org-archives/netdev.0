From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/06]: Move EXPORT_SYMBOL next to exported symbol
Date: Tue, 22 Jan 2008 15:56:09 +0100 (MET)
Message-ID: <20080122145543.6862.2046.sendpatchset@localhost.localdomain>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50735 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbYAVO4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:10 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: Move EXPORT_SYMBOL next to exported symbol

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8b868a47c5bedb1daa8534ae60c2d89fcad26781
tree 93ba760730b3b3e74250c984e871840ace8317a3
parent bae4a7effd59ef0d521de2bc97902fa0a243b544
author Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:30 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:30 +0100

 net/sched/act_api.c     |    9 ++++-----
 net/sched/ematch.c      |   11 +++++------
 net/sched/sch_api.c     |    9 ++++-----
 net/sched/sch_fifo.c    |    3 +--
 net/sched/sch_generic.c |   17 ++++++++---------
 5 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 8150647..3825508 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -263,6 +263,7 @@ int tcf_register_action(struct tc_action_ops *act)
 	write_unlock(&act_mod_lock);
 	return 0;
 }
+EXPORT_SYMBOL(tcf_register_action);
 
 int tcf_unregister_action(struct tc_action_ops *act)
 {
@@ -281,6 +282,7 @@ int tcf_unregister_action(struct tc_action_ops *act)
 	write_unlock(&act_mod_lock);
 	return err;
 }
+EXPORT_SYMBOL(tcf_unregister_action);
 
 /* lookup by name */
 static struct tc_action_ops *tc_lookup_action_n(char *kind)
@@ -377,6 +379,7 @@ repeat:
 exec_done:
 	return ret;
 }
+EXPORT_SYMBOL(tcf_action_exec);
 
 void tcf_action_destroy(struct tc_action *act, int bind)
 {
@@ -430,6 +433,7 @@ rtattr_failure:
 	nlmsg_trim(skb, b);
 	return -1;
 }
+EXPORT_SYMBOL(tcf_action_dump_1);
 
 int
 tcf_action_dump(struct sk_buff *skb, struct tc_action *act, int bind, int ref)
@@ -1077,8 +1081,3 @@ static int __init tc_action_init(void)
 }
 
 subsys_initcall(tc_action_init);
-
-EXPORT_SYMBOL(tcf_register_action);
-EXPORT_SYMBOL(tcf_unregister_action);
-EXPORT_SYMBOL(tcf_action_exec);
-EXPORT_SYMBOL(tcf_action_dump_1);
diff --git a/net/sched/ematch.c b/net/sched/ematch.c
index f3a104e..27941cf 100644
--- a/net/sched/ematch.c
+++ b/net/sched/ematch.c
@@ -141,6 +141,7 @@ errout:
 	write_unlock(&ematch_mod_lock);
 	return err;
 }
+EXPORT_SYMBOL(tcf_em_register);
 
 /**
  * tcf_em_unregister - unregster and extended match
@@ -171,6 +172,7 @@ out:
 	write_unlock(&ematch_mod_lock);
 	return err;
 }
+EXPORT_SYMBOL(tcf_em_unregister);
 
 static inline struct tcf_ematch * tcf_em_get_match(struct tcf_ematch_tree *tree,
 						   int index)
@@ -380,6 +382,7 @@ errout_abort:
 	tcf_em_tree_destroy(tp, tree);
 	return err;
 }
+EXPORT_SYMBOL(tcf_em_tree_validate);
 
 /**
  * tcf_em_tree_destroy - destroy an ematch tree
@@ -413,6 +416,7 @@ void tcf_em_tree_destroy(struct tcf_proto *tp, struct tcf_ematch_tree *tree)
 	tree->hdr.nmatches = 0;
 	kfree(tree->matches);
 }
+EXPORT_SYMBOL(tcf_em_tree_destroy);
 
 /**
  * tcf_em_tree_dump - dump ematch tree into a rtnl message
@@ -472,6 +476,7 @@ int tcf_em_tree_dump(struct sk_buff *skb, struct tcf_ematch_tree *tree, int tlv)
 rtattr_failure:
 	return -1;
 }
+EXPORT_SYMBOL(tcf_em_tree_dump);
 
 static inline int tcf_em_match(struct sk_buff *skb, struct tcf_ematch *em,
 			       struct tcf_pkt_info *info)
@@ -529,10 +534,4 @@ stack_overflow:
 		printk("Local stack overflow, increase NET_EMATCH_STACK\n");
 	return -1;
 }
-
-EXPORT_SYMBOL(tcf_em_register);
-EXPORT_SYMBOL(tcf_em_unregister);
-EXPORT_SYMBOL(tcf_em_tree_validate);
-EXPORT_SYMBOL(tcf_em_tree_destroy);
-EXPORT_SYMBOL(tcf_em_tree_dump);
 EXPORT_SYMBOL(__tcf_em_tree_match);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 273c628..dc89a93 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -158,6 +158,7 @@ out:
 	write_unlock(&qdisc_mod_lock);
 	return rc;
 }
+EXPORT_SYMBOL(register_qdisc);
 
 int unregister_qdisc(struct Qdisc_ops *qops)
 {
@@ -176,6 +177,7 @@ int unregister_qdisc(struct Qdisc_ops *qops)
 	write_unlock(&qdisc_mod_lock);
 	return err;
 }
+EXPORT_SYMBOL(unregister_qdisc);
 
 /* We know handle. Find qdisc among all qdisc's attached to device
    (root qdisc, all its children, children of children etc.)
@@ -255,6 +257,7 @@ struct qdisc_rate_table *qdisc_get_rtab(struct tc_ratespec *r, struct rtattr *ta
 	}
 	return rtab;
 }
+EXPORT_SYMBOL(qdisc_get_rtab);
 
 void qdisc_put_rtab(struct qdisc_rate_table *tab)
 {
@@ -271,6 +274,7 @@ void qdisc_put_rtab(struct qdisc_rate_table *tab)
 		}
 	}
 }
+EXPORT_SYMBOL(qdisc_put_rtab);
 
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
@@ -1289,8 +1293,3 @@ static int __init pktsched_init(void)
 }
 
 subsys_initcall(pktsched_init);
-
-EXPORT_SYMBOL(qdisc_get_rtab);
-EXPORT_SYMBOL(qdisc_put_rtab);
-EXPORT_SYMBOL(register_qdisc);
-EXPORT_SYMBOL(unregister_qdisc);
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index d71dbfc..fd05919 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -91,6 +91,7 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.dump		=	fifo_dump,
 	.owner		=	THIS_MODULE,
 };
+EXPORT_SYMBOL(pfifo_qdisc_ops);
 
 struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.id		=	"bfifo",
@@ -105,6 +106,4 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.dump		=	fifo_dump,
 	.owner		=	THIS_MODULE,
 };
-
 EXPORT_SYMBOL(bfifo_qdisc_ops);
-EXPORT_SYMBOL(pfifo_qdisc_ops);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ea5a05b..51e64ac 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -46,6 +46,7 @@ void qdisc_lock_tree(struct net_device *dev)
 	spin_lock_bh(&dev->queue_lock);
 	spin_lock(&dev->ingress_lock);
 }
+EXPORT_SYMBOL(qdisc_lock_tree);
 
 void qdisc_unlock_tree(struct net_device *dev)
 	__releases(dev->ingress_lock)
@@ -54,6 +55,7 @@ void qdisc_unlock_tree(struct net_device *dev)
 	spin_unlock(&dev->ingress_lock);
 	spin_unlock_bh(&dev->queue_lock);
 }
+EXPORT_SYMBOL(qdisc_unlock_tree);
 
 static inline int qdisc_qlen(struct Qdisc *q)
 {
@@ -253,6 +255,7 @@ void netif_carrier_on(struct net_device *dev)
 			__netdev_watchdog_up(dev);
 	}
 }
+EXPORT_SYMBOL(netif_carrier_on);
 
 /**
  *	netif_carrier_off - clear carrier
@@ -265,6 +268,7 @@ void netif_carrier_off(struct net_device *dev)
 	if (!test_and_set_bit(__LINK_STATE_NOCARRIER, &dev->state))
 		linkwatch_fire_event(dev);
 }
+EXPORT_SYMBOL(netif_carrier_off);
 
 /* "NOOP" scheduler: the best scheduler, recommended for all interfaces
    under all circumstances. It is difficult to invent anything faster or
@@ -307,6 +311,7 @@ struct Qdisc noop_qdisc = {
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
 };
+EXPORT_SYMBOL(noop_qdisc);
 
 static struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 	.id		=	"noqueue",
@@ -471,6 +476,7 @@ struct Qdisc * qdisc_create_dflt(struct net_device *dev, struct Qdisc_ops *ops,
 errout:
 	return NULL;
 }
+EXPORT_SYMBOL(qdisc_create_dflt);
 
 /* Under dev->queue_lock and BH! */
 
@@ -481,6 +487,7 @@ void qdisc_reset(struct Qdisc *qdisc)
 	if (ops->reset)
 		ops->reset(qdisc);
 }
+EXPORT_SYMBOL(qdisc_reset);
 
 /* this is the rcu callback function to clean up a qdisc when there
  * are no further references to it */
@@ -512,6 +519,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	dev_put(qdisc->dev);
 	call_rcu(&qdisc->q_rcu, __qdisc_destroy);
 }
+EXPORT_SYMBOL(qdisc_destroy);
 
 void dev_activate(struct net_device *dev)
 {
@@ -626,12 +634,3 @@ void dev_shutdown(struct net_device *dev)
 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
 	qdisc_unlock_tree(dev);
 }
-
-EXPORT_SYMBOL(netif_carrier_on);
-EXPORT_SYMBOL(netif_carrier_off);
-EXPORT_SYMBOL(noop_qdisc);
-EXPORT_SYMBOL(qdisc_create_dflt);
-EXPORT_SYMBOL(qdisc_destroy);
-EXPORT_SYMBOL(qdisc_reset);
-EXPORT_SYMBOL(qdisc_lock_tree);
-EXPORT_SYMBOL(qdisc_unlock_tree);
