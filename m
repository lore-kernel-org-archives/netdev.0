From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 18/19] net: Delete all remaining instances of ctl_path
Date: Thu, 19 Apr 2012 16:45:29 -0700
Message-ID: <m1ehrje15y.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:50214 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755699Ab2DSXl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:41:29 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We don't use struct ctl_path anymore so delete the exported constants.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netfilter.h      |    6 ------
 include/net/ip.h               |    3 ---
 include/net/ip_vs.h            |    2 --
 include/net/ipv6.h             |    1 -
 net/core/sysctl_net_core.c     |    6 ------
 net/ipv4/netfilter.c           |   10 ----------
 net/ipv4/sysctl_net_ipv4.c     |    7 -------
 net/ipv6/sysctl_net_ipv6.c     |    7 -------
 net/netfilter/core.c           |    9 ---------
 net/netfilter/ipvs/ip_vs_ctl.c |    7 -------
 10 files changed, 0 insertions(+), 58 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 29734be..ff9c84c 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -154,12 +154,6 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
 int nf_register_sockopt(struct nf_sockopt_ops *reg);
 void nf_unregister_sockopt(struct nf_sockopt_ops *reg);
 
-#ifdef CONFIG_SYSCTL
-/* Sysctl registration */
-extern struct ctl_path nf_net_netfilter_sysctl_path[];
-extern struct ctl_path nf_net_ipv4_netfilter_sysctl_path[];
-#endif /* CONFIG_SYSCTL */
-
 extern struct list_head nf_hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
 
 #if defined(CONFIG_JUMP_LABEL)
diff --git a/include/net/ip.h b/include/net/ip.h
index b53d65f..94ddb69c 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -222,9 +222,6 @@ static inline int inet_is_reserved_local_port(int port)
 
 extern int sysctl_ip_nonlocal_bind;
 
-extern struct ctl_path net_core_path[];
-extern struct ctl_path net_ipv4_ctl_path[];
-
 /* From inetpeer.c */
 extern int inet_peer_threshold;
 extern int inet_peer_minttl;
diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index a903a82..990216d 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -10,7 +10,6 @@
 
 #include <asm/types.h>                  /* for __uXX types */
 
-#include <linux/sysctl.h>               /* for ctl_path */
 #include <linux/list.h>                 /* for struct list_head */
 #include <linux/spinlock.h>             /* for struct rwlock_t */
 #include <linux/atomic.h>                 /* for struct atomic_t */
@@ -1184,7 +1183,6 @@ extern void ip_vs_scheduler_err(struct ip_vs_service *svc, const char *msg);
  *      IPVS control data and functions (from ip_vs_ctl.c)
  */
 extern struct ip_vs_stats ip_vs_stats;
-extern const struct ctl_path net_vs_ctl_path[];
 extern int sysctl_ip_vs_sync_ver;
 
 extern void ip_vs_sync_switch_mode(struct net *net, int mode);
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index e1a85ad..4332e9a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -113,7 +113,6 @@ struct frag_hdr {
 
 /* sysctls */
 extern int sysctl_mld_max_msf;
-extern struct ctl_path net_ipv6_ctl_path[];
 
 #define _DEVINC(net, statname, modifier, idev, field)			\
 ({									\
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 286d739..92d2324 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -202,12 +202,6 @@ static struct ctl_table netns_core_table[] = {
 	{ }
 };
 
-__net_initdata struct ctl_path net_core_path[] = {
-	{ .procname = "net", },
-	{ .procname = "core", },
-	{ },
-};
-
 static __net_init int sysctl_core_net_init(struct net *net)
 {
 	struct ctl_table *tbl;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 3cd8c58..ed1b367 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -237,13 +237,3 @@ static void ipv4_netfilter_fini(void)
 
 module_init(ipv4_netfilter_init);
 module_exit(ipv4_netfilter_fini);
-
-#ifdef CONFIG_SYSCTL
-struct ctl_path nf_net_ipv4_netfilter_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ .procname = "netfilter", },
-	{ }
-};
-EXPORT_SYMBOL_GPL(nf_net_ipv4_netfilter_sysctl_path);
-#endif /* CONFIG_SYSCTL */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 56e64f7..33417f8 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -768,13 +768,6 @@ static struct ctl_table ipv4_net_table[] = {
 	{ }
 };
 
-struct ctl_path net_ipv4_ctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ },
-};
-EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
-
 static __net_init int ipv4_sysctl_init_net(struct net *net)
 {
 	struct ctl_table *table;
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index a52d820..e85c48b 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -38,13 +38,6 @@ static ctl_table ipv6_rotable[] = {
 	{ }
 };
 
-struct ctl_path net_ipv6_ctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv6", },
-	{ },
-};
-EXPORT_SYMBOL_GPL(net_ipv6_ctl_path);
-
 static int __net_init ipv6_sysctl_net_init(struct net *net)
 {
 	struct ctl_table *ipv6_table;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e1b7e05..e19f365 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -290,12 +290,3 @@ void __init netfilter_init(void)
 	if (netfilter_log_init() < 0)
 		panic("cannot initialize nf_log");
 }
-
-#ifdef CONFIG_SYSCTL
-struct ctl_path nf_net_netfilter_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "netfilter", },
-	{ }
-};
-EXPORT_SYMBOL_GPL(nf_net_netfilter_sysctl_path);
-#endif /* CONFIG_SYSCTL */
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index a606d6b..e3707d2 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1846,13 +1846,6 @@ static struct ctl_table vs_vars[] = {
 	{ }
 };
 
-const struct ctl_path net_vs_ctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ .procname = "vs", },
-	{ }
-};
-EXPORT_SYMBOL_GPL(net_vs_ctl_path);
 #endif
 
 #ifdef CONFIG_PROC_FS
-- 
1.7.2.5
