From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 53/53] netns xfrm: per-netns sysctls
Date: Tue, 25 Nov 2008 20:27:25 +0300
Message-ID: <1227634045-27534-53-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-38-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-39-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-40-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-41-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-42-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-43-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-44-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-45-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-46-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-47-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-48-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-49-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-50-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-51-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-52-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:41378 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbYKYRZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:51 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23508eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:50 -0800 (PST)
In-Reply-To: <1227634045-27534-52-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make
	net.core.xfrm_aevent_etime
	net.core.xfrm_acq_expires
	net.core.xfrm_aevent_rseqth
	net.core.xfrm_larval_drop

sysctls per-netns.

For that make net_core_path[] global, register it to prevent two
/proc/net/core antries and change initcall position -- xfrm_init() is called
from fs_initcall, so this one should be fs_initcall at least.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/ip.h           |    1 +
 include/net/netns/xfrm.h   |   10 +++++
 include/net/xfrm.h         |   14 +++++---
 net/core/sysctl_net_core.c |   42 +++-------------------
 net/xfrm/Makefile          |    4 +-
 net/xfrm/xfrm_policy.c     |   10 ++++--
 net/xfrm/xfrm_state.c      |   16 ++------
 net/xfrm/xfrm_sysctl.c     |   85 ++++++++++++++++++++++++++++++++++++++++++++
 net/xfrm/xfrm_user.c       |    4 +-
 9 files changed, 125 insertions(+), 61 deletions(-)
 create mode 100644 net/xfrm/xfrm_sysctl.c

diff --git a/include/net/ip.h b/include/net/ip.h
index bc026ec..406f523 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -187,6 +187,7 @@ extern void inet_get_local_port_range(int *low, int *high);
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
 
+extern struct ctl_path net_core_path[];
 extern struct ctl_path net_ipv4_ctl_path[];
 
 /* From inetpeer.c */
diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 09f3060..1ba9127 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -6,6 +6,8 @@
 #include <linux/workqueue.h>
 #include <linux/xfrm.h>
 
+struct ctl_table_header;
+
 struct xfrm_policy_hash {
 	struct hlist_head	*table;
 	unsigned int		hmask;
@@ -41,6 +43,14 @@ struct netns_xfrm {
 	struct work_struct	policy_hash_work;
 
 	struct sock		*nlsk;
+
+	u32			sysctl_aevent_etime;
+	u32			sysctl_aevent_rseqth;
+	int			sysctl_larval_drop;
+	u32			sysctl_acq_expires;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header	*sysctl_hdr;
+#endif
 };
 
 #endif
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 1554ccd..2e9f5c0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -47,11 +47,6 @@
 #define XFRM_INC_STATS_USER(net, field)	((void)(net))
 #endif
 
-extern u32 sysctl_xfrm_aevent_etime;
-extern u32 sysctl_xfrm_aevent_rseqth;
-extern int sysctl_xfrm_larval_drop;
-extern u32 sysctl_xfrm_acq_expires;
-
 extern struct mutex xfrm_cfg_mutex;
 
 /* Organization of SPD aka "XFRM rules"
@@ -1310,6 +1305,15 @@ extern int xfrm_proc_init(struct net *net);
 extern void xfrm_proc_fini(struct net *net);
 #endif
 
+extern int xfrm_sysctl_init(struct net *net);
+#ifdef CONFIG_SYSCTL
+extern void xfrm_sysctl_fini(struct net *net);
+#else
+static inline void xfrm_sysctl_fini(struct net *net)
+{
+}
+#endif
+
 extern void xfrm_state_walk_init(struct xfrm_state_walk *walk, u8 proto);
 extern int xfrm_state_walk(struct net *net, struct xfrm_state_walk *walk,
 			   int (*func)(struct xfrm_state *, int, void*), void *);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 2bc0384..83d3398 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -12,7 +12,6 @@
 #include <linux/netdevice.h>
 #include <linux/init.h>
 #include <net/sock.h>
-#include <net/xfrm.h>
 
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
@@ -89,40 +88,6 @@ static struct ctl_table net_core_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-#ifdef CONFIG_XFRM
-	{
-		.ctl_name	= NET_CORE_AEVENT_ETIME,
-		.procname	= "xfrm_aevent_etime",
-		.data		= &sysctl_xfrm_aevent_etime,
-		.maxlen		= sizeof(u32),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
-		.ctl_name	= NET_CORE_AEVENT_RSEQTH,
-		.procname	= "xfrm_aevent_rseqth",
-		.data		= &sysctl_xfrm_aevent_rseqth,
-		.maxlen		= sizeof(u32),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "xfrm_larval_drop",
-		.data		= &sysctl_xfrm_larval_drop,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-	{
-		.ctl_name	= CTL_UNNUMBERED,
-		.procname	= "xfrm_acq_expires",
-		.data		= &sysctl_xfrm_acq_expires,
-		.maxlen		= sizeof(int),
-		.mode		= 0644,
-		.proc_handler	= proc_dointvec
-	},
-#endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
 	{
 		.ctl_name	= NET_CORE_BUDGET,
@@ -155,7 +120,7 @@ static struct ctl_table netns_core_table[] = {
 	{ .ctl_name = 0 }
 };
 
-static __net_initdata struct ctl_path net_core_path[] = {
+__net_initdata struct ctl_path net_core_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "core", .ctl_name = NET_CORE, },
 	{ },
@@ -207,8 +172,11 @@ static __net_initdata struct pernet_operations sysctl_core_ops = {
 
 static __init int sysctl_core_init(void)
 {
+	static struct ctl_table empty[1];
+
+	register_sysctl_paths(net_core_path, empty);
 	register_net_sysctl_rotable(net_core_path, net_core_table);
 	return register_pernet_subsys(&sysctl_core_ops);
 }
 
-__initcall(sysctl_core_init);
+fs_initcall(sysctl_core_init);
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index 0f439a7..c631047 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -3,8 +3,8 @@
 #
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
-		      xfrm_input.o xfrm_output.o xfrm_algo.o
+		      xfrm_input.o xfrm_output.o xfrm_algo.o \
+		      xfrm_sysctl.o
 obj-$(CONFIG_XFRM_STATISTICS) += xfrm_proc.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 obj-$(CONFIG_XFRM_IPCOMP) += xfrm_ipcomp.o
-
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 38822b3..393cc65 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -34,8 +34,6 @@
 
 #include "xfrm_hash.h"
 
-int sysctl_xfrm_larval_drop __read_mostly = 1;
-
 DEFINE_MUTEX(xfrm_cfg_mutex);
 EXPORT_SYMBOL(xfrm_cfg_mutex);
 
@@ -1671,7 +1669,7 @@ restart:
 
 		if (unlikely(nx<0)) {
 			err = nx;
-			if (err == -EAGAIN && sysctl_xfrm_larval_drop) {
+			if (err == -EAGAIN && net->xfrm.sysctl_larval_drop) {
 				/* EREMOTE tells the caller to generate
 				 * a one-shot blackhole route.
 				 */
@@ -2504,8 +2502,13 @@ static int __net_init xfrm_net_init(struct net *net)
 	rv = xfrm_policy_init(net);
 	if (rv < 0)
 		goto out_policy;
+	rv = xfrm_sysctl_init(net);
+	if (rv < 0)
+		goto out_sysctl;
 	return 0;
 
+out_sysctl:
+	xfrm_policy_fini(net);
 out_policy:
 	xfrm_state_fini(net);
 out_state:
@@ -2516,6 +2519,7 @@ out_statistics:
 
 static void __net_exit xfrm_net_exit(struct net *net)
 {
+	xfrm_sysctl_fini(net);
 	xfrm_policy_fini(net);
 	xfrm_state_fini(net);
 	xfrm_statistics_fini(net);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 662e47b..2fd57f8 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -24,14 +24,6 @@
 
 #include "xfrm_hash.h"
 
-u32 sysctl_xfrm_aevent_etime __read_mostly = XFRM_AE_ETIME;
-EXPORT_SYMBOL(sysctl_xfrm_aevent_etime);
-
-u32 sysctl_xfrm_aevent_rseqth __read_mostly = XFRM_AE_SEQT_SIZE;
-EXPORT_SYMBOL(sysctl_xfrm_aevent_rseqth);
-
-u32 sysctl_xfrm_acq_expires __read_mostly = 30;
-
 /* Each xfrm_state may be linked to two tables:
 
    1. Hash table by (spi,daddr,ah/esp) to find SA by SPI. (input,ctl)
@@ -851,8 +843,8 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 				h = xfrm_spi_hash(net, &x->id.daddr, x->id.spi, x->id.proto, family);
 				hlist_add_head(&x->byspi, net->xfrm.state_byspi+h);
 			}
-			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
-			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
+			x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
+			x->timer.expires = jiffies + net->xfrm.sysctl_acq_expires*HZ;
 			add_timer(&x->timer);
 			net->xfrm.state_num++;
 			xfrm_hash_grow_check(net, x->bydst.next != NULL);
@@ -1040,9 +1032,9 @@ static struct xfrm_state *__find_acq_core(struct net *net, unsigned short family
 		x->props.family = family;
 		x->props.mode = mode;
 		x->props.reqid = reqid;
-		x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
+		x->lft.hard_add_expires_seconds = net->xfrm.sysctl_acq_expires;
 		xfrm_state_hold(x);
-		x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
+		x->timer.expires = jiffies + net->xfrm.sysctl_acq_expires*HZ;
 		add_timer(&x->timer);
 		list_add(&x->km.all, &net->xfrm.state_all);
 		hlist_add_head(&x->bydst, net->xfrm.state_bydst+h);
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
new file mode 100644
index 0000000..2e6ffb6
--- /dev/null
+++ b/net/xfrm/xfrm_sysctl.c
@@ -0,0 +1,85 @@
+#include <linux/sysctl.h>
+#include <net/net_namespace.h>
+#include <net/xfrm.h>
+
+static void __xfrm_sysctl_init(struct net *net)
+{
+	net->xfrm.sysctl_aevent_etime = XFRM_AE_ETIME;
+	net->xfrm.sysctl_aevent_rseqth = XFRM_AE_SEQT_SIZE;
+	net->xfrm.sysctl_larval_drop = 1;
+	net->xfrm.sysctl_acq_expires = 30;
+}
+
+#ifdef CONFIG_SYSCTL
+static struct ctl_table xfrm_table[] = {
+	{
+		.ctl_name	= NET_CORE_AEVENT_ETIME,
+		.procname	= "xfrm_aevent_etime",
+		.maxlen		= sizeof(u32),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= NET_CORE_AEVENT_RSEQTH,
+		.procname	= "xfrm_aevent_rseqth",
+		.maxlen		= sizeof(u32),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "xfrm_larval_drop",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "xfrm_acq_expires",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+	{}
+};
+
+int __net_init xfrm_sysctl_init(struct net *net)
+{
+	struct ctl_table *table;
+
+	__xfrm_sysctl_init(net);
+
+	table = kmemdup(xfrm_table, sizeof(xfrm_table), GFP_KERNEL);
+	if (!table)
+		goto out_kmemdup;
+	table[0].data = &net->xfrm.sysctl_aevent_etime;
+	table[1].data = &net->xfrm.sysctl_aevent_rseqth;
+	table[2].data = &net->xfrm.sysctl_larval_drop;
+	table[3].data = &net->xfrm.sysctl_acq_expires;
+
+	net->xfrm.sysctl_hdr = register_net_sysctl_table(net, net_core_path, table);
+	if (!net->xfrm.sysctl_hdr)
+		goto out_register;
+	return 0;
+
+out_register:
+	kfree(table);
+out_kmemdup:
+	return -ENOMEM;
+}
+
+void xfrm_sysctl_fini(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->xfrm.sysctl_hdr->ctl_table_arg;
+	unregister_net_sysctl_table(net->xfrm.sysctl_hdr);
+	kfree(table);
+}
+#else
+int __net_init xfrm_sysctl_init(struct net *net)
+{
+	__xfrm_sysctl_init(net);
+	return 0;
+}
+#endif
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index b7240d5..38ffaf3 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -368,9 +368,9 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 		goto error;
 
 	x->km.seq = p->seq;
-	x->replay_maxdiff = sysctl_xfrm_aevent_rseqth;
+	x->replay_maxdiff = net->xfrm.sysctl_aevent_rseqth;
 	/* sysctl_xfrm_aevent_etime is in 100ms units */
-	x->replay_maxage = (sysctl_xfrm_aevent_etime*HZ)/XFRM_AE_ETH_M;
+	x->replay_maxage = (net->xfrm.sysctl_aevent_etime*HZ)/XFRM_AE_ETH_M;
 	x->preplay.bitmap = 0;
 	x->preplay.seq = x->replay.seq+x->replay_maxdiff;
 	x->preplay.oseq = x->replay.oseq +x->replay_maxdiff;
-- 
1.5.6.5

