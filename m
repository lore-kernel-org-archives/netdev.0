From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/11] PKT_SCHED: Remove obsolete definitions in pkt_sched.h
Date: Wed, 27 Oct 2004 00:25:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222552.GF12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removes all obsolete definitions in pkt_sched.h now in sch_generic.h
or act_api.h.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_sched.h	2004-10-26 22:57:13.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_sched.h	2004-10-26 23:16:18.000000000 +0200
@@ -1,18 +1,7 @@
 #ifndef __NET_PKT_SCHED_H
 #define __NET_PKT_SCHED_H
 
-#include <linux/config.h>
-#include <linux/netdevice.h>
-#include <linux/types.h>
-#include <linux/pkt_sched.h>
-#include <linux/rcupdate.h>
-#include <net/pkt_cls.h>
-#include <linux/module.h>
-#include <linux/rtnetlink.h>
-#include <net/gen_stats.h>
-
-struct rtattr;
-struct Qdisc;
+#include <net/sch_generic.h>
 
 struct qdisc_walker
 {
@@ -22,86 +11,8 @@
 	int	(*fn)(struct Qdisc *, unsigned long cl, struct qdisc_walker *);
 };
 
-struct Qdisc_class_ops
-{
-	/* Child qdisc manipulation */
-	int			(*graft)(struct Qdisc *, unsigned long cl, struct Qdisc *, struct Qdisc **);
-	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
-
-	/* Class manipulation routines */
-	unsigned long		(*get)(struct Qdisc *, u32 classid);
-	void			(*put)(struct Qdisc *, unsigned long);
-	int			(*change)(struct Qdisc *, u32, u32, struct rtattr **, unsigned long *);
-	int			(*delete)(struct Qdisc *, unsigned long);
-	void			(*walk)(struct Qdisc *, struct qdisc_walker * arg);
-
-	/* Filter manipulation */
-	struct tcf_proto **	(*tcf_chain)(struct Qdisc *, unsigned long);
-	unsigned long		(*bind_tcf)(struct Qdisc *, unsigned long, u32 classid);
-	void			(*unbind_tcf)(struct Qdisc *, unsigned long);
-
-	/* rtnetlink specific */
-	int			(*dump)(struct Qdisc *, unsigned long, struct sk_buff *skb, struct tcmsg*);
-	int			(*dump_stats)(struct Qdisc *, unsigned long, struct gnet_dump *);
-};
-
-struct module;
-
-struct Qdisc_ops
-{
-	struct Qdisc_ops	*next;
-	struct Qdisc_class_ops	*cl_ops;
-	char			id[IFNAMSIZ];
-	int			priv_size;
-
-	int 			(*enqueue)(struct sk_buff *, struct Qdisc *);
-	struct sk_buff *	(*dequeue)(struct Qdisc *);
-	int 			(*requeue)(struct sk_buff *, struct Qdisc *);
-	unsigned int		(*drop)(struct Qdisc *);
-
-	int			(*init)(struct Qdisc *, struct rtattr *arg);
-	void			(*reset)(struct Qdisc *);
-	void			(*destroy)(struct Qdisc *);
-	int			(*change)(struct Qdisc *, struct rtattr *arg);
-
-	int			(*dump)(struct Qdisc *, struct sk_buff *);
-	int			(*dump_stats)(struct Qdisc *, struct gnet_dump *);
-
-	struct module		*owner;
-};
-
 extern rwlock_t qdisc_tree_lock;
 
-struct Qdisc
-{
-	int 			(*enqueue)(struct sk_buff *skb, struct Qdisc *dev);
-	struct sk_buff *	(*dequeue)(struct Qdisc *dev);
-	unsigned		flags;
-#define TCQ_F_BUILTIN	1
-#define TCQ_F_THROTTLED	2
-#define TCQ_F_INGRESS	4
-	int			padded;
-	struct Qdisc_ops	*ops;
-	u32			handle;
-	u32			parent;
-	atomic_t		refcnt;
-	struct sk_buff_head	q;
-	struct net_device	*dev;
-	struct list_head	list;
-
-	struct gnet_stats_basic	bstats;
-	struct gnet_stats_queue	qstats;
-	struct gnet_stats_rate_est	rate_est;
-	spinlock_t		*stats_lock;
-	struct rcu_head 	q_rcu;
-	int			(*reshape_fail)(struct sk_buff *skb, struct Qdisc *q);
-
-	/* This field is deprecated, but it is still used by CBQ
-	 * and it will live until better solution will be invented.
-	 */
-	struct Qdisc		*__parent;
-};
-
 #define	QDISC_ALIGN		32
 #define	QDISC_ALIGN_CONST	(QDISC_ALIGN - 1)
 
@@ -111,22 +22,6 @@
 			      & ~QDISC_ALIGN_CONST);
 }
 
-struct qdisc_rate_table
-{
-	struct tc_ratespec rate;
-	u32		data[256];
-	struct qdisc_rate_table *next;
-	int		refcnt;
-};
-
-extern void qdisc_lock_tree(struct net_device *dev);
-extern void qdisc_unlock_tree(struct net_device *dev);
-
-#define sch_tree_lock(q)	qdisc_lock_tree((q)->dev)
-#define sch_tree_unlock(q)	qdisc_unlock_tree((q)->dev)
-#define tcf_tree_lock(tp)	qdisc_lock_tree((tp)->q->dev)
-#define tcf_tree_unlock(tp)	qdisc_unlock_tree((tp)->q->dev)
-
 #define cls_set_class(tp, clp, cl) tcf_set_class(tp, clp, cl)
 static inline unsigned long
 __cls_set_class(unsigned long *clp, unsigned long cl)
@@ -311,118 +206,6 @@
 
 #endif /* !CONFIG_NET_SCH_CLK_GETTIMEOFDAY */
 
-struct tcf_police
-{
-	struct tcf_police *next;
-	int		refcnt;
-#ifdef CONFIG_NET_CLS_ACT
-	int		bindcnt;
-#endif
-	u32		index;
-	int		action;
-	int		result;
-	u32		ewma_rate;
-	u32		burst;
-	u32		mtu;
-	u32		toks;
-	u32		ptoks;
-	psched_time_t	t_c;
-	spinlock_t	lock;
-	struct qdisc_rate_table *R_tab;
-	struct qdisc_rate_table *P_tab;
-
-	struct tc_stats	stats;
-	spinlock_t	*stats_lock;
-};
-
-#ifdef CONFIG_NET_CLS_ACT
-
-#define ACT_P_CREATED 1
-#define ACT_P_DELETED 1
-#define tca_gen(name) \
-struct tcf_##name *next; \
-	u32 index; \
-	int refcnt; \
-	int bindcnt; \
-	u32 capab; \
-	int action; \
-	struct tcf_t tm; \
-	struct tc_stats stats; \
-	spinlock_t *stats_lock; \
-	spinlock_t lock
-
-
-struct tc_action
-{
-	void *priv;
-	struct tc_action_ops *ops;
-	__u32   type;   /* for backward compat(TCA_OLD_COMPAT) */
-	__u32   order; 
-	struct tc_action *next;
-};
-
-#define TCA_CAP_NONE 0
-struct tc_action_ops
-{
-	struct tc_action_ops *next;
-	char    kind[IFNAMSIZ];
-	__u32   type; /* TBD to match kind */
-	__u32 	capab;  /* capabilities includes 4 bit version */
-	struct module		*owner;
-	int     (*act)(struct sk_buff **, struct tc_action *);
-	int     (*get_stats)(struct sk_buff *, struct tc_action *);
-	int     (*dump)(struct sk_buff *, struct tc_action *,int , int);
-	int     (*cleanup)(struct tc_action *, int bind);
-	int     (*lookup)(struct tc_action *, u32 );
-	int     (*init)(struct rtattr *,struct rtattr *,struct tc_action *, int , int );
-	int     (*walk)(struct sk_buff *, struct netlink_callback *, int , struct tc_action *);
-};
-
-extern int tcf_register_action(struct tc_action_ops *a);
-extern int tcf_unregister_action(struct tc_action_ops *a);
-extern void tcf_action_destroy(struct tc_action *a, int bind);
-extern int tcf_action_exec(struct sk_buff *skb, struct tc_action *a, struct tcf_result *res);
-extern int tcf_action_init(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
-extern int tcf_action_init_1(struct rtattr *rta, struct rtattr *est, struct tc_action *a,char *n, int ovr, int bind);
-extern int tcf_action_dump(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_dump_old(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int, int);
-extern int tcf_action_copy_stats (struct sk_buff *,struct tc_action *);
-extern int tcf_act_police_locate(struct rtattr *rta, struct rtattr *est,struct tc_action *,int , int );
-extern int tcf_act_police_dump(struct sk_buff *, struct tc_action *, int, int);
-extern int tcf_act_police(struct sk_buff **skb, struct tc_action *a);
-#endif
-
-extern unsigned long tcf_set_class(struct tcf_proto *tp, unsigned long *clp, 
-				   unsigned long cl);
-extern int tcf_police(struct sk_buff *skb, struct tcf_police *p);
-extern int qdisc_copy_stats(struct sk_buff *skb, struct tc_stats *st, spinlock_t *lock);
-extern void tcf_police_destroy(struct tcf_police *p);
-extern struct tcf_police * tcf_police_locate(struct rtattr *rta, struct rtattr *est);
-extern int tcf_police_dump(struct sk_buff *skb, struct tcf_police *p);
-
-static inline int tcf_police_release(struct tcf_police *p, int bind)
-{
-	int ret = 0;
-#ifdef CONFIG_NET_CLS_ACT
-	if (p) {
-		if (bind) {
-			 p->bindcnt--;
-		}
-		p->refcnt--;
-		if (p->refcnt <= 0 && !p->bindcnt) {
-			tcf_police_destroy(p);
-			ret = 1;
-		}
-	}
-#else
-	if (p && --p->refcnt == 0)
-		tcf_police_destroy(p);
-
-#endif
-	return ret;
-}
-
 extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_qdisc_ops;
