From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/11] PKT_SCHED: Remove obsolete definitions in pkt_cls.h
Date: Wed, 27 Oct 2004 00:24:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222425.GD12289@postel.suug.ch>
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

Removes all obsolete definitions in pkt_cls.h now in sch_generic.h
and includes them via sch_generic.h.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.10-rc1-bk1.orig/include/net/pkt_cls.h	2004-10-26 22:57:15.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/pkt_cls.h	2004-10-26 22:58:45.000000000 +0200
@@ -1,36 +1,11 @@
 #ifndef __NET_PKT_CLS_H
 #define __NET_PKT_CLS_H
 
-
 #include <linux/pkt_cls.h>
-
-struct rtattr;
-struct tcmsg;
+#include <net/sch_generic.h>
 
 /* Basic packet classifier frontend definitions. */
 
-struct tcf_result
-{
-	unsigned long	class;
-	u32		classid;
-};
-
-struct tcf_proto
-{
-	/* Fast access part */
-	struct tcf_proto	*next;
-	void			*root;
-	int			(*classify)(struct sk_buff*, struct tcf_proto*, struct tcf_result *);
-	u32			protocol;
-
-	/* All the rest */
-	u32			prio;
-	u32			classid;
-	struct Qdisc		*q;
-	void			*data;
-	struct tcf_proto_ops	*ops;
-};
-
 struct tcf_walker
 {
 	int	stop;
@@ -39,29 +14,6 @@
 	int	(*fn)(struct tcf_proto *, unsigned long node, struct tcf_walker *);
 };
 
-struct module;
-
-struct tcf_proto_ops
-{
-	struct tcf_proto_ops	*next;
-	char			kind[IFNAMSIZ];
-
-	int			(*classify)(struct sk_buff*, struct tcf_proto*, struct tcf_result *);
-	int			(*init)(struct tcf_proto*);
-	void			(*destroy)(struct tcf_proto*);
-
-	unsigned long		(*get)(struct tcf_proto*, u32 handle);
-	void			(*put)(struct tcf_proto*, unsigned long);
-	int			(*change)(struct tcf_proto*, unsigned long, u32 handle, struct rtattr **, unsigned long *);
-	int			(*delete)(struct tcf_proto*, unsigned long);
-	void			(*walk)(struct tcf_proto*, struct tcf_walker *arg);
-
-	/* rtnetlink specific */
-	int			(*dump)(struct tcf_proto*, unsigned long, struct sk_buff *skb, struct tcmsg*);
-
-	struct module		*owner;
-};
-
 /* Main classifier routine: scans classifier chain attached
    to this qdisc, (optionally) tests for protocol and asks
    specific classifiers.
@@ -107,18 +59,8 @@
 	return -1;
 }
 
-static inline void tcf_destroy(struct tcf_proto *tp)
-{
-	tp->ops->destroy(tp);
-	module_put(tp->ops->owner);
-	kfree(tp);
-}
-
 extern int register_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 extern int ing_filter(struct sk_buff *skb);
 
-
-
-
 #endif
