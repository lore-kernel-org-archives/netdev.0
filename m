From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/12] net: netprio: rename config to be more consistent with cgroup configs
Date: Mon,  6 Jan 2014 00:13:05 +0100
Message-ID: <1388963586-5049-12-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56255 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111AbaAEXN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 18:13:28 -0500
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>

While we're at it and introduced CGROUP_NET_CLASSID, lets also make
NETPRIO_CGROUP more consistent with the rest of cgroups and rename it
into CONFIG_CGROUP_NET_PRIO so that for networking, we now have
CONFIG_CGROUP_NET_{PRIO,CLASSID}. This not only makes the CONFIG
option consistent among networking cgroups, but also among cgroups
CONFIG conventions in general as the vast majority has a prefix of
CONFIG_CGROUP_<SUBSYS>.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Zefan Li <lizefan@huawei.com>
Cc: cgroups@vger.kernel.org
Acked-by: Li Zefan <lizefan@huawei.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/cgroup_subsys.h |    2 +-
 include/linux/netdevice.h     |    2 +-
 include/net/netprio_cgroup.h  |   18 ++++++------------
 include/net/sock.h            |    2 +-
 net/Kconfig                   |    4 ++--
 net/core/Makefile             |    2 +-
 net/core/dev.c                |    2 +-
 net/core/sock.c               |    2 +-
 8 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index 58bf94d..7b99d71 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -43,7 +43,7 @@ SUBSYS(blkio)
 SUBSYS(perf)
 #endif
 
-#if IS_SUBSYS_ENABLED(CONFIG_NETPRIO_CGROUP)
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 SUBSYS(net_prio)
 #endif
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5260d2e..45cf681 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1444,7 +1444,7 @@ struct net_device {
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
-#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 	struct netprio_map __rcu *priomap;
 #endif
 	/* phy device may attach itself for hardware timestamping */
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 099d027..dafc09f 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -13,12 +13,12 @@
 
 #ifndef _NETPRIO_CGROUP_H
 #define _NETPRIO_CGROUP_H
+
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
 
-
-#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 struct netprio_map {
 	struct rcu_head rcu;
 	u32 priomap_len;
@@ -27,8 +27,7 @@ struct netprio_map {
 
 void sock_update_netprioidx(struct sock *sk);
 
-#if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
-
+#if IS_BUILTIN(CONFIG_CGROUP_NET_PRIO)
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_subsys_state *css;
@@ -40,9 +39,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	rcu_read_unlock();
 	return idx;
 }
-
-#elif IS_MODULE(CONFIG_NETPRIO_CGROUP)
-
+#elif IS_MODULE(CONFIG_CGROUP_NET_PRIO)
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	struct cgroup_subsys_state *css;
@@ -56,9 +53,7 @@ static inline u32 task_netprioidx(struct task_struct *p)
 	return idx;
 }
 #endif
-
-#else /* !CONFIG_NETPRIO_CGROUP */
-
+#else /* !CONFIG_CGROUP_NET_PRIO */
 static inline u32 task_netprioidx(struct task_struct *p)
 {
 	return 0;
@@ -66,6 +61,5 @@ static inline u32 task_netprioidx(struct task_struct *p)
 
 #define sock_update_netprioidx(sk)
 
-#endif /* CONFIG_NETPRIO_CGROUP */
-
+#endif /* CONFIG_CGROUP_NET_PRIO */
 #endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 2ef3c3e..ef5e2be 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -395,7 +395,7 @@ struct sock {
 	unsigned short		sk_ack_backlog;
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
-#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 	__u32			sk_cgrp_prioidx;
 #endif
 	struct pid		*sk_peer_pid;
diff --git a/net/Kconfig b/net/Kconfig
index 7da10b8..e411046 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -238,12 +238,12 @@ config XPS
 	depends on SMP
 	default y
 
-config NETPRIO_CGROUP
+config CGROUP_NET_PRIO
 	tristate "Network priority cgroup"
 	depends on CGROUPS
 	---help---
 	  Cgroup subsystem for use in assigning processes to network priorities on
-	  a per-interface basis
+	  a per-interface basis.
 
 config CGROUP_NET_CLASSID
 	boolean "Network classid cgroup"
diff --git a/net/core/Makefile b/net/core/Makefile
index 4839a27..9628c20 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -21,5 +21,5 @@ obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
-obj-$(CONFIG_NETPRIO_CGROUP) += netprio_cgroup.o
+obj-$(CONFIG_CGROUP_NET_PRIO) += netprio_cgroup.o
 obj-$(CONFIG_CGROUP_NET_CLASSID) += netclassid_cgroup.o
diff --git a/net/core/dev.c b/net/core/dev.c
index c95d664..888a79b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2747,7 +2747,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	return rc;
 }
 
-#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 static void skb_update_prio(struct sk_buff *skb)
 {
 	struct netprio_map *map = rcu_dereference_bh(skb->dev->priomap);
diff --git a/net/core/sock.c b/net/core/sock.c
index 3f15072..a29735c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1308,7 +1308,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
 	module_put(owner);
 }
 
-#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+#if IS_ENABLED(CONFIG_CGROUP_NET_PRIO)
 void sock_update_netprioidx(struct sock *sk)
 {
 	if (in_interrupt())
-- 
1.7.10.4
