From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 09/23] sysctl net: Remove unused binary sysctl code
Date: Sun,  8 Nov 2009 04:21:56 -0800
Message-ID: <1257682930-31401-9-git-send-email-ebiederm@xmission.com>
References: <m14op5jjo4.fsf@fess.ebiederm.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:49537 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbZKHMW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 07:22:29 -0500
In-Reply-To: <m14op5jjo4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

Now that sys_sysctl is a compatiblity wrapper around /proc/sys
all sysctl strategy routines, and all ctl_name and strategy
entries in the sysctl tables are unused, and can be
revmoed.

In addition neigh_sysctl_register has been modified to no longer
take a strategy argument and it's callers have been modified not
to pass one.

Cc: "David Miller" <davem@davemloft.net>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/dn_dev.h                           |    1 -
 include/net/neighbour.h                        |    3 +-
 net/802/tr.c                                   |    7 +-
 net/appletalk/sysctl_net_atalk.c               |   13 +--
 net/ax25/sysctl_net_ax25.c                     |   38 +-----
 net/bridge/br_netfilter.c                      |    6 +-
 net/core/neighbour.c                           |   47 +------
 net/core/sysctl_net_core.c                     |   21 +---
 net/dccp/sysctl.c                              |    8 +-
 net/decnet/dn_dev.c                            |   64 +---------
 net/decnet/sysctl_net_decnet.c                 |  124 +-----------------
 net/ipv4/arp.c                                 |    2 +-
 net/ipv4/devinet.c                             |  111 +++--------------
 net/ipv4/ip_fragment.c                         |    6 -
 net/ipv4/netfilter.c                           |    6 +-
 net/ipv4/netfilter/ip_queue.c                  |    3 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   10 +--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 +-
 net/ipv4/route.c                               |   73 ++---------
 net/ipv4/sysctl_net_ipv4.c                     |  164 +-----------------------
 net/ipv4/xfrm4_policy.c                        |    1 -
 net/ipv6/addrconf.c                            |   90 ++------------
 net/ipv6/icmp.c                                |    4 +-
 net/ipv6/ndisc.c                               |   39 +------
 net/ipv6/netfilter/ip6_queue.c                 |    4 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    4 +-
 net/ipv6/reassembly.c                          |    6 -
 net/ipv6/route.c                               |   18 +---
 net/ipv6/sysctl_net_ipv6.c                     |   12 +-
 net/ipv6/xfrm6_policy.c                        |    1 -
 net/ipx/sysctl_net_ipx.c                       |    7 +-
 net/irda/irsysctl.c                            |   31 +----
 net/llc/sysctl_net_llc.c                       |   25 +---
 net/netfilter/core.c                           |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |    6 +-
 net/netfilter/ipvs/ip_vs_lblc.c                |    2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c               |    2 +-
 net/netfilter/nf_conntrack_acct.c              |    1 -
 net/netfilter/nf_conntrack_ecache.c            |    2 -
 net/netfilter/nf_conntrack_proto_dccp.c        |   12 +--
 net/netfilter/nf_conntrack_proto_generic.c     |    8 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |    8 +-
 net/netfilter/nf_conntrack_proto_tcp.c         |   14 +--
 net/netfilter/nf_conntrack_proto_udp.c         |    8 +-
 net/netfilter/nf_conntrack_proto_udplite.c     |    6 +-
 net/netfilter/nf_conntrack_standalone.c        |   14 +--
 net/netfilter/nf_log.c                         |    7 +-
 net/netrom/sysctl_net_netrom.c                 |   30 +----
 net/phonet/sysctl.c                            |    8 +-
 net/rds/ib_sysctl.c                            |   14 +--
 net/rds/iw_sysctl.c                            |   14 +--
 net/rds/sysctl.c                               |   11 +-
 net/rose/sysctl_net_rose.c                     |   26 +----
 net/sctp/sysctl.c                              |   49 +-------
 net/sunrpc/sysctl.c                            |    5 +-
 net/sunrpc/xprtrdma/svc_rdma.c                 |   16 +--
 net/sunrpc/xprtrdma/transport.c                |   20 +---
 net/sunrpc/xprtsock.c                          |   18 +---
 net/unix/sysctl_net_unix.c                     |    7 +-
 net/x25/sysctl_net_x25.c                       |   15 +--
 net/xfrm/xfrm_sysctl.c                         |    4 -
 62 files changed, 162 insertions(+), 1130 deletions(-)

diff --git a/include/net/dn_dev.h b/include/net/dn_dev.h
index cee4682..3f781a4 100644
--- a/include/net/dn_dev.h
+++ b/include/net/dn_dev.h
@@ -75,7 +75,6 @@ struct dn_dev_parms {
 	unsigned long t3;         /* Default value of t3                */
 	int priority;             /* Priority to be a router            */
 	char *name;               /* Name for sysctl                    */
-	int ctl_name;             /* Index for sysctl                   */
 	int  (*up)(struct net_device *);
 	void (*down)(struct net_device *);
 	void (*timer3)(struct net_device *, struct dn_ifaddr *ifa);
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 3817fda..da99fdd 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -264,8 +264,7 @@ extern int			neigh_sysctl_register(struct net_device *dev,
 						      struct neigh_parms *p,
 						      int p_id, int pdev_id,
 						      char *p_name,
-						      proc_handler *proc_handler,
-						      ctl_handler *strategy);
+						      proc_handler *proc_handler);
 extern void			neigh_sysctl_unregister(struct neigh_parms *p);
 
 static inline void __neigh_parms_put(struct neigh_parms *parms)
diff --git a/net/802/tr.c b/net/802/tr.c
index e874447..44acce4 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -635,19 +635,18 @@ struct net_device *alloc_trdev(int sizeof_priv)
 #ifdef CONFIG_SYSCTL
 static struct ctl_table tr_table[] = {
 	{
-		.ctl_name	= NET_TR_RIF_TIMEOUT,
 		.procname	= "rif_timeout",
 		.data		= &sysctl_tr_rif_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ 0 },
+	{ },
 };
 
 static __initdata struct ctl_path tr_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "token-ring", .ctl_name = NET_TR, },
+	{ .procname = "net", },
+	{ .procname = "token-ring", },
 	{ }
 };
 #endif
diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
index 8d237b1..04e9c0d 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -12,25 +12,20 @@
 
 static struct ctl_table atalk_table[] = {
 	{
-		.ctl_name	= NET_ATALK_AARP_EXPIRY_TIME,
 		.procname	= "aarp-expiry-time",
 		.data		= &sysctl_aarp_expiry_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_ATALK_AARP_TICK_TIME,
 		.procname	= "aarp-tick-time",
 		.data		= &sysctl_aarp_tick_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_ATALK_AARP_RETRANSMIT_LIMIT,
 		.procname	= "aarp-retransmit-limit",
 		.data		= &sysctl_aarp_retransmit_limit,
 		.maxlen		= sizeof(int),
@@ -38,20 +33,18 @@ static struct ctl_table atalk_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_ATALK_AARP_RESOLVE_TIME,
 		.procname	= "aarp-resolve-time",
 		.data		= &sysctl_aarp_resolve_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
-	{ 0 },
+	{ },
 };
 
 static struct ctl_path atalk_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "appletalk", .ctl_name = NET_ATALK, },
+	{ .procname = "net", },
+	{ .procname = "appletalk", },
 	{ }
 };
 
diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index 62ee3fb..5159be6 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -34,156 +34,128 @@ static ctl_table *ax25_table;
 static int ax25_table_size;
 
 static struct ctl_path ax25_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ax25", .ctl_name = NET_AX25, },
+	{ .procname = "net", },
+	{ .procname = "ax25", },
 	{ }
 };
 
 static const ctl_table ax25_param_table[] = {
 	{
-		.ctl_name	= NET_AX25_IP_DEFAULT_MODE,
 		.procname	= "ip_default_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_ipdefmode,
 		.extra2		= &max_ipdefmode
 	},
 	{
-		.ctl_name	= NET_AX25_DEFAULT_MODE,
 		.procname	= "ax25_default_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_axdefmode,
 		.extra2		= &max_axdefmode
 	},
 	{
-		.ctl_name	= NET_AX25_BACKOFF_TYPE,
 		.procname	= "backoff_type",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_backoff,
 		.extra2		= &max_backoff
 	},
 	{
-		.ctl_name	= NET_AX25_CONNECT_MODE,
 		.procname	= "connect_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_conmode,
 		.extra2		= &max_conmode
 	},
 	{
-		.ctl_name	= NET_AX25_STANDARD_WINDOW,
 		.procname	= "standard_window_size",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_window,
 		.extra2		= &max_window
 	},
 	{
-		.ctl_name	= NET_AX25_EXTENDED_WINDOW,
 		.procname	= "extended_window_size",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_ewindow,
 		.extra2		= &max_ewindow
 	},
 	{
-		.ctl_name	= NET_AX25_T1_TIMEOUT,
 		.procname	= "t1_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_t1,
 		.extra2		= &max_t1
 	},
 	{
-		.ctl_name	= NET_AX25_T2_TIMEOUT,
 		.procname	= "t2_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_t2,
 		.extra2		= &max_t2
 	},
 	{
-		.ctl_name	= NET_AX25_T3_TIMEOUT,
 		.procname	= "t3_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_t3,
 		.extra2		= &max_t3
 	},
 	{
-		.ctl_name	= NET_AX25_IDLE_TIMEOUT,
 		.procname	= "idle_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_idle,
 		.extra2		= &max_idle
 	},
 	{
-		.ctl_name	= NET_AX25_N2,
 		.procname	= "maximum_retry_count",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_n2,
 		.extra2		= &max_n2
 	},
 	{
-		.ctl_name	= NET_AX25_PACLEN,
 		.procname	= "maximum_packet_length",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_paclen,
 		.extra2		= &max_paclen
 	},
 	{
-		.ctl_name	= NET_AX25_PROTOCOL,
 		.procname	= "protocol",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_proto,
 		.extra2		= &max_proto
 	},
 #ifdef CONFIG_AX25_DAMA_SLAVE
 	{
-		.ctl_name	= NET_AX25_DAMA_SLAVE_TIMEOUT,
 		.procname	= "dama_slave_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_ds_timeout,
 		.extra2		= &max_ds_timeout
 	},
 #endif
 
-	{ .ctl_name = 0 }	/* that's all, folks! */
+	{ }	/* that's all, folks! */
 };
 
 void ax25_register_sysctl(void)
@@ -212,11 +184,9 @@ void ax25_register_sysctl(void)
 			return;
 		}
 		ax25_table[n].child = ax25_dev->systable = child;
-		ax25_table[n].ctl_name     = n + 1;
 		ax25_table[n].procname     = ax25_dev->dev->name;
 		ax25_table[n].mode         = 0555;
 
-		child[AX25_MAX_VALUES].ctl_name = 0;	/* just in case... */
 
 		for (k = 0; k < AX25_MAX_VALUES; k++)
 			child[k].data = &ax25_dev->values[k];
@@ -233,7 +203,7 @@ void ax25_unregister_sysctl(void)
 	ctl_table *p;
 	unregister_sysctl_table(ax25_table_header);
 
-	for (p = ax25_table; p->ctl_name; p++)
+	for (p = ax25_table; p->procname; p++)
 		kfree(p->child);
 	kfree(ax25_table);
 }
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a16a234..268e2e7 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1013,12 +1013,12 @@ static ctl_table brnf_table[] = {
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path brnf_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "bridge", .ctl_name = NET_BRIDGE, },
+	{ .procname = "net", },
+	{ .procname = "bridge", },
 	{ }
 };
 #endif
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e587e68..2b54e6c 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2566,21 +2566,18 @@ static struct neigh_sysctl_table {
 } neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
 		{
-			.ctl_name	= NET_NEIGH_MCAST_SOLICIT,
 			.procname	= "mcast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.ctl_name	= NET_NEIGH_UCAST_SOLICIT,
 			.procname	= "ucast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.ctl_name	= NET_NEIGH_APP_SOLICIT,
 			.procname	= "app_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
@@ -2593,38 +2590,30 @@ static struct neigh_sysctl_table {
 			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_REACHABLE_TIME,
 			.procname	= "base_reachable_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
-			.strategy	= sysctl_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_DELAY_PROBE_TIME,
 			.procname	= "delay_first_probe_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
-			.strategy	= sysctl_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_GC_STALE_TIME,
 			.procname	= "gc_stale_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
-			.strategy	= sysctl_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_UNRES_QLEN,
 			.procname	= "unres_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.ctl_name	= NET_NEIGH_PROXY_QLEN,
 			.procname	= "proxy_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
@@ -2649,45 +2638,36 @@ static struct neigh_sysctl_table {
 			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_RETRANS_TIME_MS,
 			.procname	= "retrans_time_ms",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_ms_jiffies,
-			.strategy	= sysctl_ms_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_REACHABLE_TIME_MS,
 			.procname	= "base_reachable_time_ms",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_ms_jiffies,
-			.strategy	= sysctl_ms_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_GC_INTERVAL,
 			.procname	= "gc_interval",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec_jiffies,
-			.strategy	= sysctl_jiffies,
 		},
 		{
-			.ctl_name	= NET_NEIGH_GC_THRESH1,
 			.procname	= "gc_thresh1",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.ctl_name	= NET_NEIGH_GC_THRESH2,
 			.procname	= "gc_thresh2",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
 			.proc_handler	= proc_dointvec,
 		},
 		{
-			.ctl_name	= NET_NEIGH_GC_THRESH3,
 			.procname	= "gc_thresh3",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
@@ -2699,7 +2679,7 @@ static struct neigh_sysctl_table {
 
 int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 			  int p_id, int pdev_id, char *p_name,
-			  proc_handler *handler, ctl_handler *strategy)
+			  proc_handler *handler)
 {
 	struct neigh_sysctl_table *t;
 	const char *dev_name_source = NULL;
@@ -2710,10 +2690,10 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 #define NEIGH_CTL_PATH_DEV	3
 
 	struct ctl_path neigh_path[] = {
-		{ .procname = "net",	 .ctl_name = CTL_NET, },
-		{ .procname = "proto",	 .ctl_name = 0, },
-		{ .procname = "neigh",	 .ctl_name = 0, },
-		{ .procname = "default", .ctl_name = NET_PROTO_CONF_DEFAULT, },
+		{ .procname = "net",	 },
+		{ .procname = "proto",	 },
+		{ .procname = "neigh",	 },
+		{ .procname = "default", },
 		{ },
 	};
 
@@ -2738,7 +2718,6 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 
 	if (dev) {
 		dev_name_source = dev->name;
-		neigh_path[NEIGH_CTL_PATH_DEV].ctl_name = dev->ifindex;
 		/* Terminate the table early */
 		memset(&t->neigh_vars[14], 0, sizeof(t->neigh_vars[14]));
 	} else {
@@ -2750,31 +2729,19 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 	}
 
 
-	if (handler || strategy) {
+	if (handler) {
 		/* RetransTime */
 		t->neigh_vars[3].proc_handler = handler;
-		t->neigh_vars[3].strategy = strategy;
 		t->neigh_vars[3].extra1 = dev;
-		if (!strategy)
-			t->neigh_vars[3].ctl_name = CTL_UNNUMBERED;
 		/* ReachableTime */
 		t->neigh_vars[4].proc_handler = handler;
-		t->neigh_vars[4].strategy = strategy;
 		t->neigh_vars[4].extra1 = dev;
-		if (!strategy)
-			t->neigh_vars[4].ctl_name = CTL_UNNUMBERED;
 		/* RetransTime (in milliseconds)*/
 		t->neigh_vars[12].proc_handler = handler;
-		t->neigh_vars[12].strategy = strategy;
 		t->neigh_vars[12].extra1 = dev;
-		if (!strategy)
-			t->neigh_vars[12].ctl_name = CTL_UNNUMBERED;
 		/* ReachableTime (in milliseconds) */
 		t->neigh_vars[13].proc_handler = handler;
-		t->neigh_vars[13].strategy = strategy;
 		t->neigh_vars[13].extra1 = dev;
-		if (!strategy)
-			t->neigh_vars[13].ctl_name = CTL_UNNUMBERED;
 	}
 
 	t->dev_name = kstrdup(dev_name_source, GFP_KERNEL);
@@ -2782,9 +2749,7 @@ int neigh_sysctl_register(struct net_device *dev, struct neigh_parms *p,
 		goto free;
 
 	neigh_path[NEIGH_CTL_PATH_DEV].procname = t->dev_name;
-	neigh_path[NEIGH_CTL_PATH_NEIGH].ctl_name = pdev_id;
 	neigh_path[NEIGH_CTL_PATH_PROTO].procname = p_name;
-	neigh_path[NEIGH_CTL_PATH_PROTO].ctl_name = p_id;
 
 	t->sysctl_header =
 		register_net_sysctl_table(neigh_parms_net(p), neigh_path, t->neigh_vars);
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 7db1de0..1ce4e6e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -17,7 +17,6 @@
 static struct ctl_table net_core_table[] = {
 #ifdef CONFIG_NET
 	{
-		.ctl_name	= NET_CORE_WMEM_MAX,
 		.procname	= "wmem_max",
 		.data		= &sysctl_wmem_max,
 		.maxlen		= sizeof(int),
@@ -25,7 +24,6 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_RMEM_MAX,
 		.procname	= "rmem_max",
 		.data		= &sysctl_rmem_max,
 		.maxlen		= sizeof(int),
@@ -33,7 +31,6 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_WMEM_DEFAULT,
 		.procname	= "wmem_default",
 		.data		= &sysctl_wmem_default,
 		.maxlen		= sizeof(int),
@@ -41,7 +38,6 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_RMEM_DEFAULT,
 		.procname	= "rmem_default",
 		.data		= &sysctl_rmem_default,
 		.maxlen		= sizeof(int),
@@ -49,7 +45,6 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_DEV_WEIGHT,
 		.procname	= "dev_weight",
 		.data		= &weight_p,
 		.maxlen		= sizeof(int),
@@ -57,7 +52,6 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_MAX_BACKLOG,
 		.procname	= "netdev_max_backlog",
 		.data		= &netdev_max_backlog,
 		.maxlen		= sizeof(int),
@@ -65,16 +59,13 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_MSG_COST,
 		.procname	= "message_cost",
 		.data		= &net_ratelimit_state.interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_CORE_MSG_BURST,
 		.procname	= "message_burst",
 		.data		= &net_ratelimit_state.burst,
 		.maxlen		= sizeof(int),
@@ -82,7 +73,6 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_CORE_OPTMEM_MAX,
 		.procname	= "optmem_max",
 		.data		= &sysctl_optmem_max,
 		.maxlen		= sizeof(int),
@@ -91,7 +81,6 @@ static struct ctl_table net_core_table[] = {
 	},
 #endif /* CONFIG_NET */
 	{
-		.ctl_name	= NET_CORE_BUDGET,
 		.procname	= "netdev_budget",
 		.data		= &netdev_budget,
 		.maxlen		= sizeof(int),
@@ -99,31 +88,29 @@ static struct ctl_table net_core_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_WARNINGS,
 		.procname	= "warnings",
 		.data		= &net_msg_warn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_table netns_core_table[] = {
 	{
-		.ctl_name	= NET_CORE_SOMAXCONN,
 		.procname	= "somaxconn",
 		.data		= &init_net.core.sysctl_somaxconn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 __net_initdata struct ctl_path net_core_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "core", .ctl_name = NET_CORE, },
+	{ .procname = "net", },
+	{ .procname = "core", },
 	{ },
 };
 
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index a5a1856..5639438 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -93,13 +93,13 @@ static struct ctl_table dccp_default_table[] = {
 		.proc_handler	= proc_dointvec_ms_jiffies,
 	},
 
-	{ .ctl_name = 0, }
+	{ }
 };
 
 static struct ctl_path dccp_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "dccp", .ctl_name = NET_DCCP, },
-	{ .procname = "default", .ctl_name = NET_DCCP_DEFAULT, },
+	{ .procname = "net", },
+	{ .procname = "dccp", },
+	{ .procname = "default", },
 	{ }
 };
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 6e1f085..1b1daeb 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -89,7 +89,6 @@ static struct dn_dev_parms dn_dev_list[] =  {
 	.t2 =		1,
 	.t3 =		10,
 	.name =		"ethernet",
-	.ctl_name =	NET_DECNET_CONF_ETHER,
 	.up =		dn_eth_up,
 	.down = 	dn_eth_down,
 	.timer3 =	dn_send_brd_hello,
@@ -101,7 +100,6 @@ static struct dn_dev_parms dn_dev_list[] =  {
 	.t2 =		1,
 	.t3 =		10,
 	.name =		"ipgre",
-	.ctl_name =	NET_DECNET_CONF_GRE,
 	.timer3 =	dn_send_brd_hello,
 },
 #if 0
@@ -112,7 +110,6 @@ static struct dn_dev_parms dn_dev_list[] =  {
 	.t2 =		1,
 	.t3 =		120,
 	.name =		"x25",
-	.ctl_name =	NET_DECNET_CONF_X25,
 	.timer3 =	dn_send_ptp_hello,
 },
 #endif
@@ -124,7 +121,6 @@ static struct dn_dev_parms dn_dev_list[] =  {
 	.t2 =		1,
 	.t3 =		10,
 	.name =		"ppp",
-	.ctl_name =	NET_DECNET_CONF_PPP,
 	.timer3 =	dn_send_brd_hello,
 },
 #endif
@@ -135,7 +131,6 @@ static struct dn_dev_parms dn_dev_list[] =  {
 	.t2 =		1,
 	.t3 =		120,
 	.name =		"ddcmp",
-	.ctl_name =	NET_DECNET_CONF_DDCMP,
 	.timer3 =	dn_send_ptp_hello,
 },
 {
@@ -145,7 +140,6 @@ static struct dn_dev_parms dn_dev_list[] =  {
 	.t2 =		1,
 	.t3 =		10,
 	.name =		"loopback",
-	.ctl_name =	NET_DECNET_CONF_LOOPBACK,
 	.timer3 =	dn_send_brd_hello,
 }
 };
@@ -166,10 +160,6 @@ static int max_priority[] = { 127 }; /* From DECnet spec */
 
 static int dn_forwarding_proc(ctl_table *, int,
 			void __user *, size_t *, loff_t *);
-static int dn_forwarding_sysctl(ctl_table *table,
-			void __user *oldval, size_t __user *oldlenp,
-			void __user *newval, size_t newlen);
-
 static struct dn_dev_sysctl_table {
 	struct ctl_table_header *sysctl_header;
 	ctl_table dn_dev_vars[5];
@@ -177,44 +167,36 @@ static struct dn_dev_sysctl_table {
 	NULL,
 	{
 	{
-		.ctl_name = NET_DECNET_CONF_DEV_FORWARDING,
 		.procname = "forwarding",
 		.data = (void *)DN_DEV_PARMS_OFFSET(forwarding),
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = dn_forwarding_proc,
-		.strategy = dn_forwarding_sysctl,
 	},
 	{
-		.ctl_name = NET_DECNET_CONF_DEV_PRIORITY,
 		.procname = "priority",
 		.data = (void *)DN_DEV_PARMS_OFFSET(priority),
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_priority,
 		.extra2 = &max_priority
 	},
 	{
-		.ctl_name = NET_DECNET_CONF_DEV_T2,
 		.procname = "t2",
 		.data = (void *)DN_DEV_PARMS_OFFSET(t2),
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_t2,
 		.extra2 = &max_t2
 	},
 	{
-		.ctl_name = NET_DECNET_CONF_DEV_T3,
 		.procname = "t3",
 		.data = (void *)DN_DEV_PARMS_OFFSET(t3),
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_t3,
 		.extra2 = &max_t3
 	},
@@ -230,9 +212,9 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 #define DN_CTL_PATH_DEV	3
 
 	struct ctl_path dn_ctl_path[] = {
-		{ .procname = "net", .ctl_name = CTL_NET, },
-		{ .procname = "decnet", .ctl_name = NET_DECNET, },
-		{ .procname = "conf", .ctl_name = NET_DECNET_CONF, },
+		{ .procname = "net",  },
+		{ .procname = "decnet",  },
+		{ .procname = "conf",  },
 		{ /* to be set */ },
 		{ },
 	};
@@ -248,10 +230,8 @@ static void dn_dev_sysctl_register(struct net_device *dev, struct dn_dev_parms *
 
 	if (dev) {
 		dn_ctl_path[DN_CTL_PATH_DEV].procname = dev->name;
-		dn_ctl_path[DN_CTL_PATH_DEV].ctl_name = dev->ifindex;
 	} else {
 		dn_ctl_path[DN_CTL_PATH_DEV].procname = parms->name;
-		dn_ctl_path[DN_CTL_PATH_DEV].ctl_name = parms->ctl_name;
 	}
 
 	t->dn_dev_vars[0].extra1 = (void *)dev;
@@ -317,44 +297,6 @@ static int dn_forwarding_proc(ctl_table *table, int write,
 #endif
 }
 
-static int dn_forwarding_sysctl(ctl_table *table,
-			void __user *oldval, size_t __user *oldlenp,
-			void __user *newval, size_t newlen)
-{
-#ifdef CONFIG_DECNET_ROUTER
-	struct net_device *dev = table->extra1;
-	struct dn_dev *dn_db;
-	int value;
-
-	if (table->extra1 == NULL)
-		return -EINVAL;
-
-	dn_db = dev->dn_ptr;
-
-	if (newval && newlen) {
-		if (newlen != sizeof(int))
-			return -EINVAL;
-
-		if (get_user(value, (int __user *)newval))
-			return -EFAULT;
-		if (value < 0)
-			return -EINVAL;
-		if (value > 2)
-			return -EINVAL;
-
-		if (dn_db->parms.down)
-			dn_db->parms.down(dev);
-		dn_db->parms.forwarding = value;
-		if (dn_db->parms.up)
-			dn_db->parms.up(dev);
-	}
-
-	return 0;
-#else
-	return -EINVAL;
-#endif
-}
-
 #else /* CONFIG_SYSCTL */
 static void dn_dev_sysctl_unregister(struct dn_dev_parms *parms)
 {
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index 26b0ab1..be3eb8e 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -131,39 +131,6 @@ static int parse_addr(__le16 *addr, char *str)
 	return 0;
 }
 
-
-static int dn_node_address_strategy(ctl_table *table,
-				void __user *oldval, size_t __user *oldlenp,
-				void __user *newval, size_t newlen)
-{
-	size_t len;
-	__le16 addr;
-
-	if (oldval && oldlenp) {
-		if (get_user(len, oldlenp))
-			return -EFAULT;
-		if (len) {
-			if (len != sizeof(unsigned short))
-				return -EINVAL;
-			if (put_user(decnet_address, (__le16 __user *)oldval))
-				return -EFAULT;
-		}
-	}
-	if (newval && newlen) {
-		if (newlen != sizeof(unsigned short))
-			return -EINVAL;
-		if (get_user(addr, (__le16 __user *)newval))
-			return -EFAULT;
-
-		dn_dev_devices_off();
-
-		decnet_address = addr;
-
-		dn_dev_devices_on();
-	}
-	return 0;
-}
-
 static int dn_node_address_handler(ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
@@ -215,65 +182,6 @@ static int dn_node_address_handler(ctl_table *table, int write,
 	return 0;
 }
 
-
-static int dn_def_dev_strategy(ctl_table *table,
-				void __user *oldval, size_t __user *oldlenp,
-				void __user *newval, size_t newlen)
-{
-	size_t len;
-	struct net_device *dev;
-	char devname[17];
-	size_t namel;
-	int rv = 0;
-
-	devname[0] = 0;
-
-	if (oldval && oldlenp) {
-		if (get_user(len, oldlenp))
-			return -EFAULT;
-		if (len) {
-			dev = dn_dev_get_default();
-			if (dev) {
-				strcpy(devname, dev->name);
-				dev_put(dev);
-			}
-
-			namel = strlen(devname) + 1;
-			if (len > namel) len = namel;
-
-			if (copy_to_user(oldval, devname, len))
-				return -EFAULT;
-
-			if (put_user(len, oldlenp))
-				return -EFAULT;
-		}
-	}
-
-	if (newval && newlen) {
-		if (newlen > 16)
-			return -E2BIG;
-
-		if (copy_from_user(devname, newval, newlen))
-			return -EFAULT;
-
-		devname[newlen] = 0;
-
-		dev = dev_get_by_name(&init_net, devname);
-		if (dev == NULL)
-			return -ENODEV;
-
-		rv = -ENODEV;
-		if (dev->dn_ptr != NULL) {
-			rv = dn_dev_set_default(dev, 1);
-			if (rv)
-				dev_put(dev);
-		}
-	}
-
-	return rv;
-}
-
-
 static int dn_def_dev_handler(ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
@@ -339,138 +247,112 @@ static int dn_def_dev_handler(ctl_table *table, int write,
 
 static ctl_table dn_table[] = {
 	{
-		.ctl_name = NET_DECNET_NODE_ADDRESS,
 		.procname = "node_address",
 		.maxlen = 7,
 		.mode = 0644,
 		.proc_handler = dn_node_address_handler,
-		.strategy = dn_node_address_strategy,
 	},
 	{
-		.ctl_name = NET_DECNET_NODE_NAME,
 		.procname = "node_name",
 		.data = node_name,
 		.maxlen = 7,
 		.mode = 0644,
 		.proc_handler = proc_dostring,
-		.strategy = sysctl_string,
 	},
 	{
-		.ctl_name = NET_DECNET_DEFAULT_DEVICE,
 		.procname = "default_device",
 		.maxlen = 16,
 		.mode = 0644,
 		.proc_handler = dn_def_dev_handler,
-		.strategy = dn_def_dev_strategy,
 	},
 	{
-		.ctl_name = NET_DECNET_TIME_WAIT,
 		.procname = "time_wait",
 		.data = &decnet_time_wait,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_decnet_time_wait,
 		.extra2 = &max_decnet_time_wait
 	},
 	{
-		.ctl_name = NET_DECNET_DN_COUNT,
 		.procname = "dn_count",
 		.data = &decnet_dn_count,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_state_count,
 		.extra2 = &max_state_count
 	},
 	{
-		.ctl_name = NET_DECNET_DI_COUNT,
 		.procname = "di_count",
 		.data = &decnet_di_count,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_state_count,
 		.extra2 = &max_state_count
 	},
 	{
-		.ctl_name = NET_DECNET_DR_COUNT,
 		.procname = "dr_count",
 		.data = &decnet_dr_count,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_state_count,
 		.extra2 = &max_state_count
 	},
 	{
-		.ctl_name = NET_DECNET_DST_GC_INTERVAL,
 		.procname = "dst_gc_interval",
 		.data = &decnet_dst_gc_interval,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_decnet_dst_gc_interval,
 		.extra2 = &max_decnet_dst_gc_interval
 	},
 	{
-		.ctl_name = NET_DECNET_NO_FC_MAX_CWND,
 		.procname = "no_fc_max_cwnd",
 		.data = &decnet_no_fc_max_cwnd,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec_minmax,
-		.strategy = sysctl_intvec,
 		.extra1 = &min_decnet_no_fc_max_cwnd,
 		.extra2 = &max_decnet_no_fc_max_cwnd
 	},
        {
-		.ctl_name = NET_DECNET_MEM,
 		.procname = "decnet_mem",
 		.data = &sysctl_decnet_mem,
 		.maxlen = sizeof(sysctl_decnet_mem),
 		.mode = 0644,
 		.proc_handler = proc_dointvec,
-		.strategy = sysctl_intvec,
 	},
 	{
-		.ctl_name = NET_DECNET_RMEM,
 		.procname = "decnet_rmem",
 		.data = &sysctl_decnet_rmem,
 		.maxlen = sizeof(sysctl_decnet_rmem),
 		.mode = 0644,
 		.proc_handler = proc_dointvec,
-		.strategy = sysctl_intvec,
 	},
 	{
-		.ctl_name = NET_DECNET_WMEM,
 		.procname = "decnet_wmem",
 		.data = &sysctl_decnet_wmem,
 		.maxlen = sizeof(sysctl_decnet_wmem),
 		.mode = 0644,
 		.proc_handler = proc_dointvec,
-		.strategy = sysctl_intvec,
 	},
 	{
-		.ctl_name = NET_DECNET_DEBUG_LEVEL,
 		.procname = "debug",
 		.data = &decnet_debug_level,
 		.maxlen = sizeof(int),
 		.mode = 0644,
 		.proc_handler = proc_dointvec,
-		.strategy = sysctl_intvec,
 	},
-	{0}
+	{ }
 };
 
 static struct ctl_path dn_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "decnet", .ctl_name = NET_DECNET, },
+	{ .procname = "net", },
+	{ .procname = "decnet", },
 	{ }
 };
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 4e80f33..c95cd93 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1240,7 +1240,7 @@ void __init arp_init(void)
 	arp_proc_init();
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+			      NET_IPV4_NEIGH, "ipv4", NULL);
 #endif
 	register_netdevice_notifier(&arp_netdev_notifier);
 }
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5df2f6a..e049da8 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1293,58 +1293,6 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int devinet_conf_sysctl(ctl_table *table,
-			       void __user *oldval, size_t __user *oldlenp,
-			       void __user *newval, size_t newlen)
-{
-	struct ipv4_devconf *cnf;
-	struct net *net;
-	int *valp = table->data;
-	int new;
-	int i;
-
-	if (!newval || !newlen)
-		return 0;
-
-	if (newlen != sizeof(int))
-		return -EINVAL;
-
-	if (get_user(new, (int __user *)newval))
-		return -EFAULT;
-
-	if (new == *valp)
-		return 0;
-
-	if (oldval && oldlenp) {
-		size_t len;
-
-		if (get_user(len, oldlenp))
-			return -EFAULT;
-
-		if (len) {
-			if (len > table->maxlen)
-				len = table->maxlen;
-			if (copy_to_user(oldval, valp, len))
-				return -EFAULT;
-			if (put_user(len, oldlenp))
-				return -EFAULT;
-		}
-	}
-
-	*valp = new;
-
-	cnf = table->extra1;
-	net = table->extra2;
-	i = (int *)table->data - cnf->data;
-
-	set_bit(i, cnf->state);
-
-	if (cnf == net->ipv4.devconf_dflt)
-		devinet_copy_dflt_conf(net, i);
-
-	return 1;
-}
-
 static int devinet_sysctl_forward(ctl_table *ctl, int write,
 				  void __user *buffer,
 				  size_t *lenp, loff_t *ppos)
@@ -1390,47 +1338,28 @@ int ipv4_doint_and_flush(ctl_table *ctl, int write,
 	return ret;
 }
 
-int ipv4_doint_and_flush_strategy(ctl_table *table,
-				  void __user *oldval, size_t __user *oldlenp,
-				  void __user *newval, size_t newlen)
-{
-	int ret = devinet_conf_sysctl(table, oldval, oldlenp, newval, newlen);
-	struct net *net = table->extra2;
-
-	if (ret == 1)
-		rt_cache_flush(net, 0);
-
-	return ret;
-}
-
-
-#define DEVINET_SYSCTL_ENTRY(attr, name, mval, proc, sysctl) \
+#define DEVINET_SYSCTL_ENTRY(attr, name, mval, proc) \
 	{ \
-		.ctl_name	= NET_IPV4_CONF_ ## attr, \
 		.procname	= name, \
 		.data		= ipv4_devconf.data + \
 				  NET_IPV4_CONF_ ## attr - 1, \
 		.maxlen		= sizeof(int), \
 		.mode		= mval, \
 		.proc_handler	= proc, \
-		.strategy	= sysctl, \
 		.extra1		= &ipv4_devconf, \
 	}
 
 #define DEVINET_SYSCTL_RW_ENTRY(attr, name) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0644, devinet_conf_proc, \
-			     devinet_conf_sysctl)
+	DEVINET_SYSCTL_ENTRY(attr, name, 0644, devinet_conf_proc)
 
 #define DEVINET_SYSCTL_RO_ENTRY(attr, name) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0444, devinet_conf_proc, \
-			     devinet_conf_sysctl)
+	DEVINET_SYSCTL_ENTRY(attr, name, 0444, devinet_conf_proc)
 
-#define DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, proc, sysctl) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0644, proc, sysctl)
+#define DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, proc) \
+	DEVINET_SYSCTL_ENTRY(attr, name, 0644, proc)
 
 #define DEVINET_SYSCTL_FLUSHING_ENTRY(attr, name) \
-	DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, ipv4_doint_and_flush, \
-				     ipv4_doint_and_flush_strategy)
+	DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, ipv4_doint_and_flush)
 
 static struct devinet_sysctl_table {
 	struct ctl_table_header *sysctl_header;
@@ -1439,8 +1368,7 @@ static struct devinet_sysctl_table {
 } devinet_sysctl = {
 	.devinet_vars = {
 		DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
-					     devinet_sysctl_forward,
-					     devinet_conf_sysctl),
+					     devinet_sysctl_forward),
 		DEVINET_SYSCTL_RO_ENTRY(MC_FORWARDING, "mc_forwarding"),
 
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_REDIRECTS, "accept_redirects"),
@@ -1471,7 +1399,7 @@ static struct devinet_sysctl_table {
 };
 
 static int __devinet_sysctl_register(struct net *net, char *dev_name,
-		int ctl_name, struct ipv4_devconf *p)
+					struct ipv4_devconf *p)
 {
 	int i;
 	struct devinet_sysctl_table *t;
@@ -1479,9 +1407,9 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 #define DEVINET_CTL_PATH_DEV	3
 
 	struct ctl_path devinet_ctl_path[] = {
-		{ .procname = "net", .ctl_name = CTL_NET, },
-		{ .procname = "ipv4", .ctl_name = NET_IPV4, },
-		{ .procname = "conf", .ctl_name = NET_IPV4_CONF, },
+		{ .procname = "net",  },
+		{ .procname = "ipv4", },
+		{ .procname = "conf", },
 		{ /* to be set */ },
 		{ },
 	};
@@ -1506,7 +1434,6 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		goto free;
 
 	devinet_ctl_path[DEVINET_CTL_PATH_DEV].procname = t->dev_name;
-	devinet_ctl_path[DEVINET_CTL_PATH_DEV].ctl_name = ctl_name;
 
 	t->sysctl_header = register_net_sysctl_table(net, devinet_ctl_path,
 			t->devinet_vars);
@@ -1540,9 +1467,9 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 static void devinet_sysctl_register(struct in_device *idev)
 {
 	neigh_sysctl_register(idev->dev, idev->arp_parms, NET_IPV4,
-			NET_IPV4_NEIGH, "ipv4", NULL, NULL);
+			NET_IPV4_NEIGH, "ipv4", NULL);
 	__devinet_sysctl_register(dev_net(idev->dev), idev->dev->name,
-			idev->dev->ifindex, &idev->cnf);
+					&idev->cnf);
 }
 
 static void devinet_sysctl_unregister(struct in_device *idev)
@@ -1553,14 +1480,12 @@ static void devinet_sysctl_unregister(struct in_device *idev)
 
 static struct ctl_table ctl_forward_entry[] = {
 	{
-		.ctl_name	= NET_IPV4_FORWARD,
 		.procname	= "ip_forward",
 		.data		= &ipv4_devconf.data[
 					NET_IPV4_CONF_FORWARDING - 1],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= devinet_sysctl_forward,
-		.strategy	= devinet_conf_sysctl,
 		.extra1		= &ipv4_devconf,
 		.extra2		= &init_net,
 	},
@@ -1568,8 +1493,8 @@ static struct ctl_table ctl_forward_entry[] = {
 };
 
 static __net_initdata struct ctl_path net_ipv4_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
 	{ },
 };
 #endif
@@ -1608,13 +1533,11 @@ static __net_init int devinet_init_net(struct net *net)
 	}
 
 #ifdef CONFIG_SYSCTL
-	err = __devinet_sysctl_register(net, "all",
-			NET_PROTO_CONF_ALL, all);
+	err = __devinet_sysctl_register(net, "all", all);
 	if (err < 0)
 		goto err_reg_all;
 
-	err = __devinet_sysctl_register(net, "default",
-			NET_PROTO_CONF_DEFAULT, dflt);
+	err = __devinet_sysctl_register(net, "default", dflt);
 	if (err < 0)
 		goto err_reg_dflt;
 
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 575f9bd..ef24497 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -603,7 +603,6 @@ static int zero;
 
 static struct ctl_table ip4_frags_ns_ctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_IPFRAG_HIGH_THRESH,
 		.procname	= "ipfrag_high_thresh",
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
@@ -611,7 +610,6 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
 		.procname	= "ipfrag_low_thresh",
 		.data		= &init_net.ipv4.frags.low_thresh,
 		.maxlen		= sizeof(int),
@@ -619,26 +617,22 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_IPFRAG_TIME,
 		.procname	= "ipfrag_time",
 		.data		= &init_net.ipv4.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{ }
 };
 
 static struct ctl_table ip4_frags_ctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_IPFRAG_SECRET_INTERVAL,
 		.procname	= "ipfrag_secret_interval",
 		.data		= &ip4_frags.secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
 		.procname	= "ipfrag_max_dist",
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 1725dc0..db52c0c 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -248,9 +248,9 @@ module_exit(ipv4_netfilter_fini);
 
 #ifdef CONFIG_SYSCTL
 struct ctl_path nf_net_ipv4_netfilter_sysctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
-	{ .procname = "netfilter", .ctl_name = NET_IPV4_NETFILTER, },
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
+	{ .procname = "netfilter", },
 	{ }
 };
 EXPORT_SYMBOL_GPL(nf_net_ipv4_netfilter_sysctl_path);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index c156db2..c9f90e8 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -516,14 +516,13 @@ static struct ctl_table_header *ipq_sysctl_header;
 
 static ctl_table ipq_table[] = {
 	{
-		.ctl_name	= NET_IPQ_QMAX,
 		.procname	= NET_IPQ_QMAX_NAME,
 		.data		= &queue_maxlen,
 		.maxlen		= sizeof(queue_maxlen),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 #endif
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index aa95bb8..092d68f 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -195,7 +195,6 @@ static int log_invalid_proto_max = 255;
 
 static ctl_table ip_ct_sysctl_table[] = {
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_MAX,
 		.procname	= "ip_conntrack_max",
 		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
@@ -203,7 +202,6 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_COUNT,
 		.procname	= "ip_conntrack_count",
 		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
@@ -211,7 +209,6 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_BUCKETS,
 		.procname	= "ip_conntrack_buckets",
 		.data		= &nf_conntrack_htable_size,
 		.maxlen		= sizeof(unsigned int),
@@ -219,7 +216,6 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_CHECKSUM,
 		.procname	= "ip_conntrack_checksum",
 		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(int),
@@ -227,19 +223,15 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_LOG_INVALID,
 		.procname	= "ip_conntrack_log_invalid",
 		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &log_invalid_proto_min,
 		.extra2		= &log_invalid_proto_max,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #endif /* CONFIG_SYSCTL && CONFIG_NF_CONNTRACK_PROC_COMPAT */
 
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index d71ba76..9072058 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -270,9 +270,7 @@ static struct ctl_table icmp_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name = 0
-	}
+	{ }
 };
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table icmp_compat_sysctl_table[] = {
@@ -283,9 +281,7 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name = 0
-	}
+	{ }
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 5b1050a..0d9f584 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3056,23 +3056,6 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 	return -EINVAL;
 }
 
-static int ipv4_sysctl_rtcache_flush_strategy(ctl_table *table,
-						void __user *oldval,
-						size_t __user *oldlenp,
-						void __user *newval,
-						size_t newlen)
-{
-	int delay;
-	struct net *net;
-	if (newlen != sizeof(int))
-		return -EINVAL;
-	if (get_user(delay, (int __user *)newval))
-		return -EFAULT;
-	net = (struct net *)table->extra1;
-	rt_cache_flush(net, delay);
-	return 0;
-}
-
 static void rt_secret_reschedule(int old)
 {
 	struct net *net;
@@ -3117,23 +3100,8 @@ static int ipv4_sysctl_rt_secret_interval(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int ipv4_sysctl_rt_secret_interval_strategy(ctl_table *table,
-						   void __user *oldval,
-						   size_t __user *oldlenp,
-						   void __user *newval,
-						   size_t newlen)
-{
-	int old = ip_rt_secret_interval;
-	int ret = sysctl_jiffies(table, oldval, oldlenp, newval, newlen);
-
-	rt_secret_reschedule(old);
-
-	return ret;
-}
-
 static ctl_table ipv4_route_table[] = {
 	{
-		.ctl_name	= NET_IPV4_ROUTE_GC_THRESH,
 		.procname	= "gc_thresh",
 		.data		= &ipv4_dst_ops.gc_thresh,
 		.maxlen		= sizeof(int),
@@ -3141,7 +3109,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_MAX_SIZE,
 		.procname	= "max_size",
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
@@ -3151,43 +3118,34 @@ static ctl_table ipv4_route_table[] = {
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
 
-		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL,
 		.procname	= "gc_min_interval",
 		.data		= &ip_rt_gc_min_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS,
 		.procname	= "gc_min_interval_ms",
 		.data		= &ip_rt_gc_min_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
-		.strategy	= sysctl_ms_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_GC_TIMEOUT,
 		.procname	= "gc_timeout",
 		.data		= &ip_rt_gc_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_GC_INTERVAL,
 		.procname	= "gc_interval",
 		.data		= &ip_rt_gc_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_LOAD,
 		.procname	= "redirect_load",
 		.data		= &ip_rt_redirect_load,
 		.maxlen		= sizeof(int),
@@ -3195,7 +3153,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_NUMBER,
 		.procname	= "redirect_number",
 		.data		= &ip_rt_redirect_number,
 		.maxlen		= sizeof(int),
@@ -3203,7 +3160,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_SILENCE,
 		.procname	= "redirect_silence",
 		.data		= &ip_rt_redirect_silence,
 		.maxlen		= sizeof(int),
@@ -3211,7 +3167,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_ERROR_COST,
 		.procname	= "error_cost",
 		.data		= &ip_rt_error_cost,
 		.maxlen		= sizeof(int),
@@ -3219,7 +3174,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_ERROR_BURST,
 		.procname	= "error_burst",
 		.data		= &ip_rt_error_burst,
 		.maxlen		= sizeof(int),
@@ -3227,7 +3181,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_GC_ELASTICITY,
 		.procname	= "gc_elasticity",
 		.data		= &ip_rt_gc_elasticity,
 		.maxlen		= sizeof(int),
@@ -3235,16 +3188,13 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_MTU_EXPIRES,
 		.procname	= "mtu_expires",
 		.data		= &ip_rt_mtu_expires,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_MIN_PMTU,
 		.procname	= "min_pmtu",
 		.data		= &ip_rt_min_pmtu,
 		.maxlen		= sizeof(int),
@@ -3252,7 +3202,6 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_MIN_ADVMSS,
 		.procname	= "min_adv_mss",
 		.data		= &ip_rt_min_advmss,
 		.maxlen		= sizeof(int),
@@ -3260,50 +3209,46 @@ static ctl_table ipv4_route_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_ROUTE_SECRET_INTERVAL,
 		.procname	= "secret_interval",
 		.data		= &ip_rt_secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= ipv4_sysctl_rt_secret_interval,
-		.strategy	= ipv4_sysctl_rt_secret_interval_strategy,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_table empty[1];
 
 static struct ctl_table ipv4_skeleton[] =
 {
-	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE,
+	{ .procname = "route", 
 	  .mode = 0555, .child = ipv4_route_table},
-	{ .procname = "neigh", .ctl_name = NET_IPV4_NEIGH,
+	{ .procname = "neigh", 
 	  .mode = 0555, .child = empty},
 	{ }
 };
 
 static __net_initdata struct ctl_path ipv4_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
 	{ },
 };
 
 static struct ctl_table ipv4_route_flush_table[] = {
 	{
-		.ctl_name 	= NET_IPV4_ROUTE_FLUSH,
 		.procname	= "flush",
 		.maxlen		= sizeof(int),
 		.mode		= 0200,
 		.proc_handler	= ipv4_sysctl_rtcache_flush,
-		.strategy	= ipv4_sysctl_rtcache_flush_strategy,
 	},
-	{ .ctl_name = 0 },
+	{ },
 };
 
 static __net_initdata struct ctl_path ipv4_route_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
-	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE, },
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
+	{ .procname = "route", },
 	{ },
 };
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 2dcf04d..3000567 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -63,34 +63,6 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 	return ret;
 }
 
-/* Validate changes from sysctl interface. */
-static int ipv4_sysctl_local_port_range(ctl_table *table,
-					 void __user *oldval,
-					 size_t __user *oldlenp,
-					void __user *newval, size_t newlen)
-{
-	int ret;
-	int range[2];
-	ctl_table tmp = {
-		.data = &range,
-		.maxlen = sizeof(range),
-		.mode = table->mode,
-		.extra1 = &ip_local_port_range_min,
-		.extra2 = &ip_local_port_range_max,
-	};
-
-	inet_get_local_port_range(range, range + 1);
-	ret = sysctl_intvec(&tmp, oldval, oldlenp, newval, newlen);
-	if (ret == 0 && newval && newlen) {
-		if (range[1] < range[0])
-			ret = -EINVAL;
-		else
-			set_local_port_range(range);
-	}
-	return ret;
-}
-
-
 static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -109,25 +81,6 @@ static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int sysctl_tcp_congestion_control(ctl_table *table,
-					 void __user *oldval,
-					 size_t __user *oldlenp,
-					 void __user *newval, size_t newlen)
-{
-	char val[TCP_CA_NAME_MAX];
-	ctl_table tbl = {
-		.data = val,
-		.maxlen = TCP_CA_NAME_MAX,
-	};
-	int ret;
-
-	tcp_get_default_congestion_control(val);
-	ret = sysctl_string(&tbl, oldval, oldlenp, newval, newlen);
-	if (ret == 1 && newval && newlen)
-		ret = tcp_set_default_congestion_control(val);
-	return ret;
-}
-
 static int proc_tcp_available_congestion_control(ctl_table *ctl,
 						 int write,
 						 void __user *buffer, size_t *lenp,
@@ -165,32 +118,8 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
 	return ret;
 }
 
-static int strategy_allowed_congestion_control(ctl_table *table,
-					       void __user *oldval,
-					       size_t __user *oldlenp,
-					       void __user *newval,
-					       size_t newlen)
-{
-	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX };
-	int ret;
-
-	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
-	if (!tbl.data)
-		return -ENOMEM;
-
-	tcp_get_available_congestion_control(tbl.data, tbl.maxlen);
-	ret = sysctl_string(&tbl, oldval, oldlenp, newval, newlen);
-	if (ret == 1 && newval && newlen)
-		ret = tcp_set_allowed_congestion_control(tbl.data);
-	kfree(tbl.data);
-
-	return ret;
-
-}
-
 static struct ctl_table ipv4_table[] = {
 	{
-		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
 		.procname	= "tcp_timestamps",
 		.data		= &sysctl_tcp_timestamps,
 		.maxlen		= sizeof(int),
@@ -198,7 +127,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_WINDOW_SCALING,
 		.procname	= "tcp_window_scaling",
 		.data		= &sysctl_tcp_window_scaling,
 		.maxlen		= sizeof(int),
@@ -206,7 +134,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_SACK,
 		.procname	= "tcp_sack",
 		.data		= &sysctl_tcp_sack,
 		.maxlen		= sizeof(int),
@@ -214,7 +141,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_RETRANS_COLLAPSE,
 		.procname	= "tcp_retrans_collapse",
 		.data		= &sysctl_tcp_retrans_collapse,
 		.maxlen		= sizeof(int),
@@ -222,17 +148,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_DEFAULT_TTL,
 		.procname	= "ip_default_ttl",
 		.data		= &sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= ipv4_doint_and_flush,
-		.strategy	= ipv4_doint_and_flush_strategy,
 		.extra2		= &init_net,
 	},
 	{
-		.ctl_name	= NET_IPV4_NO_PMTU_DISC,
 		.procname	= "ip_no_pmtu_disc",
 		.data		= &ipv4_config.no_pmtu_disc,
 		.maxlen		= sizeof(int),
@@ -240,7 +163,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_NONLOCAL_BIND,
 		.procname	= "ip_nonlocal_bind",
 		.data		= &sysctl_ip_nonlocal_bind,
 		.maxlen		= sizeof(int),
@@ -248,7 +170,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_SYN_RETRIES,
 		.procname	= "tcp_syn_retries",
 		.data		= &sysctl_tcp_syn_retries,
 		.maxlen		= sizeof(int),
@@ -256,7 +177,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_SYNACK_RETRIES,
 		.procname	= "tcp_synack_retries",
 		.data		= &sysctl_tcp_synack_retries,
 		.maxlen		= sizeof(int),
@@ -264,7 +184,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_MAX_ORPHANS,
 		.procname	= "tcp_max_orphans",
 		.data		= &sysctl_tcp_max_orphans,
 		.maxlen		= sizeof(int),
@@ -272,7 +191,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_MAX_TW_BUCKETS,
 		.procname	= "tcp_max_tw_buckets",
 		.data		= &tcp_death_row.sysctl_max_tw_buckets,
 		.maxlen		= sizeof(int),
@@ -280,7 +198,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_DYNADDR,
 		.procname	= "ip_dynaddr",
 		.data		= &sysctl_ip_dynaddr,
 		.maxlen		= sizeof(int),
@@ -288,16 +205,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_TIME,
 		.procname	= "tcp_keepalive_time",
 		.data		= &sysctl_tcp_keepalive_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_PROBES,
 		.procname	= "tcp_keepalive_probes",
 		.data		= &sysctl_tcp_keepalive_probes,
 		.maxlen		= sizeof(int),
@@ -305,26 +219,21 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_INTVL,
 		.procname	= "tcp_keepalive_intvl",
 		.data		= &sysctl_tcp_keepalive_intvl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_RETRIES1,
 		.procname	= "tcp_retries1",
 		.data		= &sysctl_tcp_retries1,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra2		= &tcp_retr1_max
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_RETRIES2,
 		.procname	= "tcp_retries2",
 		.data		= &sysctl_tcp_retries2,
 		.maxlen		= sizeof(int),
@@ -332,17 +241,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_FIN_TIMEOUT,
 		.procname	= "tcp_fin_timeout",
 		.data		= &sysctl_tcp_fin_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 #ifdef CONFIG_SYN_COOKIES
 	{
-		.ctl_name	= NET_TCP_SYNCOOKIES,
 		.procname	= "tcp_syncookies",
 		.data		= &sysctl_tcp_syncookies,
 		.maxlen		= sizeof(int),
@@ -351,7 +257,6 @@ static struct ctl_table ipv4_table[] = {
 	},
 #endif
 	{
-		.ctl_name	= NET_TCP_TW_RECYCLE,
 		.procname	= "tcp_tw_recycle",
 		.data		= &tcp_death_row.sysctl_tw_recycle,
 		.maxlen		= sizeof(int),
@@ -359,7 +264,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_ABORT_ON_OVERFLOW,
 		.procname	= "tcp_abort_on_overflow",
 		.data		= &sysctl_tcp_abort_on_overflow,
 		.maxlen		= sizeof(int),
@@ -367,7 +271,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_STDURG,
 		.procname	= "tcp_stdurg",
 		.data		= &sysctl_tcp_stdurg,
 		.maxlen		= sizeof(int),
@@ -375,7 +278,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_RFC1337,
 		.procname	= "tcp_rfc1337",
 		.data		= &sysctl_tcp_rfc1337,
 		.maxlen		= sizeof(int),
@@ -383,7 +285,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_MAX_SYN_BACKLOG,
 		.procname	= "tcp_max_syn_backlog",
 		.data		= &sysctl_max_syn_backlog,
 		.maxlen		= sizeof(int),
@@ -391,17 +292,14 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_LOCAL_PORT_RANGE,
 		.procname	= "ip_local_port_range",
 		.data		= &sysctl_local_ports.range,
 		.maxlen		= sizeof(sysctl_local_ports.range),
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
-		.strategy	= ipv4_sysctl_local_port_range,
 	},
 #ifdef CONFIG_IP_MULTICAST
 	{
-		.ctl_name	= NET_IPV4_IGMP_MAX_MEMBERSHIPS,
 		.procname	= "igmp_max_memberships",
 		.data		= &sysctl_igmp_max_memberships,
 		.maxlen		= sizeof(int),
@@ -411,7 +309,6 @@ static struct ctl_table ipv4_table[] = {
 
 #endif
 	{
-		.ctl_name	= NET_IPV4_IGMP_MAX_MSF,
 		.procname	= "igmp_max_msf",
 		.data		= &sysctl_igmp_max_msf,
 		.maxlen		= sizeof(int),
@@ -419,7 +316,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_INET_PEER_THRESHOLD,
 		.procname	= "inet_peer_threshold",
 		.data		= &inet_peer_threshold,
 		.maxlen		= sizeof(int),
@@ -427,43 +323,34 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_INET_PEER_MINTTL,
 		.procname	= "inet_peer_minttl",
 		.data		= &inet_peer_minttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_INET_PEER_MAXTTL,
 		.procname	= "inet_peer_maxttl",
 		.data		= &inet_peer_maxttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_INET_PEER_GC_MINTIME,
 		.procname	= "inet_peer_gc_mintime",
 		.data		= &inet_peer_gc_mintime,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_INET_PEER_GC_MAXTIME,
 		.procname	= "inet_peer_gc_maxtime",
 		.data		= &inet_peer_gc_maxtime,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{
-		.ctl_name	= NET_TCP_ORPHAN_RETRIES,
 		.procname	= "tcp_orphan_retries",
 		.data		= &sysctl_tcp_orphan_retries,
 		.maxlen		= sizeof(int),
@@ -471,7 +358,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_FACK,
 		.procname	= "tcp_fack",
 		.data		= &sysctl_tcp_fack,
 		.maxlen		= sizeof(int),
@@ -479,7 +365,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_REORDERING,
 		.procname	= "tcp_reordering",
 		.data		= &sysctl_tcp_reordering,
 		.maxlen		= sizeof(int),
@@ -487,7 +372,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_ECN,
 		.procname	= "tcp_ecn",
 		.data		= &sysctl_tcp_ecn,
 		.maxlen		= sizeof(int),
@@ -495,7 +379,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_DSACK,
 		.procname	= "tcp_dsack",
 		.data		= &sysctl_tcp_dsack,
 		.maxlen		= sizeof(int),
@@ -503,7 +386,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_MEM,
 		.procname	= "tcp_mem",
 		.data		= &sysctl_tcp_mem,
 		.maxlen		= sizeof(sysctl_tcp_mem),
@@ -511,7 +393,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_WMEM,
 		.procname	= "tcp_wmem",
 		.data		= &sysctl_tcp_wmem,
 		.maxlen		= sizeof(sysctl_tcp_wmem),
@@ -519,7 +400,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_RMEM,
 		.procname	= "tcp_rmem",
 		.data		= &sysctl_tcp_rmem,
 		.maxlen		= sizeof(sysctl_tcp_rmem),
@@ -527,7 +407,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_APP_WIN,
 		.procname	= "tcp_app_win",
 		.data		= &sysctl_tcp_app_win,
 		.maxlen		= sizeof(int),
@@ -535,7 +414,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_ADV_WIN_SCALE,
 		.procname	= "tcp_adv_win_scale",
 		.data		= &sysctl_tcp_adv_win_scale,
 		.maxlen		= sizeof(int),
@@ -543,7 +421,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_TW_REUSE,
 		.procname	= "tcp_tw_reuse",
 		.data		= &sysctl_tcp_tw_reuse,
 		.maxlen		= sizeof(int),
@@ -551,7 +428,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_FRTO,
 		.procname	= "tcp_frto",
 		.data		= &sysctl_tcp_frto,
 		.maxlen		= sizeof(int),
@@ -559,7 +435,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_FRTO_RESPONSE,
 		.procname	= "tcp_frto_response",
 		.data		= &sysctl_tcp_frto_response,
 		.maxlen		= sizeof(int),
@@ -567,7 +442,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_LOW_LATENCY,
 		.procname	= "tcp_low_latency",
 		.data		= &sysctl_tcp_low_latency,
 		.maxlen		= sizeof(int),
@@ -575,7 +449,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_TCP_NO_METRICS_SAVE,
 		.procname	= "tcp_no_metrics_save",
 		.data		= &sysctl_tcp_nometrics_save,
 		.maxlen		= sizeof(int),
@@ -583,7 +456,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_MODERATE_RCVBUF,
 		.procname	= "tcp_moderate_rcvbuf",
 		.data		= &sysctl_tcp_moderate_rcvbuf,
 		.maxlen		= sizeof(int),
@@ -591,7 +463,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_TSO_WIN_DIVISOR,
 		.procname	= "tcp_tso_win_divisor",
 		.data		= &sysctl_tcp_tso_win_divisor,
 		.maxlen		= sizeof(int),
@@ -599,15 +470,12 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_CONG_CONTROL,
 		.procname	= "tcp_congestion_control",
 		.mode		= 0644,
 		.maxlen		= TCP_CA_NAME_MAX,
 		.proc_handler	= proc_tcp_congestion_control,
-		.strategy	= sysctl_tcp_congestion_control,
 	},
 	{
-		.ctl_name	= NET_TCP_ABC,
 		.procname	= "tcp_abc",
 		.data		= &sysctl_tcp_abc,
 		.maxlen		= sizeof(int),
@@ -615,7 +483,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_MTU_PROBING,
 		.procname	= "tcp_mtu_probing",
 		.data		= &sysctl_tcp_mtu_probing,
 		.maxlen		= sizeof(int),
@@ -623,7 +490,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_TCP_BASE_MSS,
 		.procname	= "tcp_base_mss",
 		.data		= &sysctl_tcp_base_mss,
 		.maxlen		= sizeof(int),
@@ -631,7 +497,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS,
 		.procname	= "tcp_workaround_signed_windows",
 		.data		= &sysctl_tcp_workaround_signed_windows,
 		.maxlen		= sizeof(int),
@@ -640,7 +505,6 @@ static struct ctl_table ipv4_table[] = {
 	},
 #ifdef CONFIG_NET_DMA
 	{
-		.ctl_name	= NET_TCP_DMA_COPYBREAK,
 		.procname	= "tcp_dma_copybreak",
 		.data		= &sysctl_tcp_dma_copybreak,
 		.maxlen		= sizeof(int),
@@ -649,7 +513,6 @@ static struct ctl_table ipv4_table[] = {
 	},
 #endif
 	{
-		.ctl_name	= NET_TCP_SLOW_START_AFTER_IDLE,
 		.procname	= "tcp_slow_start_after_idle",
 		.data		= &sysctl_tcp_slow_start_after_idle,
 		.maxlen		= sizeof(int),
@@ -658,7 +521,6 @@ static struct ctl_table ipv4_table[] = {
 	},
 #ifdef CONFIG_NETLABEL
 	{
-		.ctl_name	= NET_CIPSOV4_CACHE_ENABLE,
 		.procname	= "cipso_cache_enable",
 		.data		= &cipso_v4_cache_enabled,
 		.maxlen		= sizeof(int),
@@ -666,7 +528,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_CIPSOV4_CACHE_BUCKET_SIZE,
 		.procname	= "cipso_cache_bucket_size",
 		.data		= &cipso_v4_cache_bucketsize,
 		.maxlen		= sizeof(int),
@@ -674,7 +535,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_CIPSOV4_RBM_OPTFMT,
 		.procname	= "cipso_rbm_optfmt",
 		.data		= &cipso_v4_rbm_optfmt,
 		.maxlen		= sizeof(int),
@@ -682,7 +542,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_CIPSOV4_RBM_STRICTVALID,
 		.procname	= "cipso_rbm_strictvalid",
 		.data		= &cipso_v4_rbm_strictvalid,
 		.maxlen		= sizeof(int),
@@ -697,15 +556,12 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler   = proc_tcp_available_congestion_control,
 	},
 	{
-		.ctl_name	= NET_TCP_ALLOWED_CONG_CONTROL,
 		.procname	= "tcp_allowed_congestion_control",
 		.maxlen		= TCP_CA_BUF_MAX,
 		.mode		= 0644,
 		.proc_handler   = proc_allowed_congestion_control,
-		.strategy	= strategy_allowed_congestion_control,
 	},
 	{
-		.ctl_name	= NET_TCP_MAX_SSTHRESH,
 		.procname	= "tcp_max_ssthresh",
 		.data		= &sysctl_tcp_max_ssthresh,
 		.maxlen		= sizeof(int),
@@ -713,41 +569,34 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_mem",
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_rmem_min",
 		.data		= &sysctl_udp_rmem_min,
 		.maxlen		= sizeof(sysctl_udp_rmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "udp_wmem_min",
 		.data		= &sysctl_udp_wmem_min,
 		.maxlen		= sizeof(sysctl_udp_wmem_min),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_table ipv4_net_table[] = {
 	{
-		.ctl_name	= NET_IPV4_ICMP_ECHO_IGNORE_ALL,
 		.procname	= "icmp_echo_ignore_all",
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_all,
 		.maxlen		= sizeof(int),
@@ -755,7 +604,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_ICMP_ECHO_IGNORE_BROADCASTS,
 		.procname	= "icmp_echo_ignore_broadcasts",
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_broadcasts,
 		.maxlen		= sizeof(int),
@@ -763,7 +611,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_ICMP_IGNORE_BOGUS_ERROR_RESPONSES,
 		.procname	= "icmp_ignore_bogus_error_responses",
 		.data		= &init_net.ipv4.sysctl_icmp_ignore_bogus_error_responses,
 		.maxlen		= sizeof(int),
@@ -771,7 +618,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_ICMP_ERRORS_USE_INBOUND_IFADDR,
 		.procname	= "icmp_errors_use_inbound_ifaddr",
 		.data		= &init_net.ipv4.sysctl_icmp_errors_use_inbound_ifaddr,
 		.maxlen		= sizeof(int),
@@ -779,16 +625,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV4_ICMP_RATELIMIT,
 		.procname	= "icmp_ratelimit",
 		.data		= &init_net.ipv4.sysctl_icmp_ratelimit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
-		.strategy	= sysctl_ms_jiffies
 	},
 	{
-		.ctl_name	= NET_IPV4_ICMP_RATEMASK,
 		.procname	= "icmp_ratemask",
 		.data		= &init_net.ipv4.sysctl_icmp_ratemask,
 		.maxlen		= sizeof(int),
@@ -796,7 +639,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "rt_cache_rebuild_count",
 		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
 		.maxlen		= sizeof(int),
@@ -807,8 +649,8 @@ static struct ctl_table ipv4_net_table[] = {
 };
 
 struct ctl_path net_ipv4_ctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
 	{ },
 };
 EXPORT_SYMBOL_GPL(net_ipv4_ctl_path);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 74fb2eb..8c08a28 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -267,7 +267,6 @@ static struct xfrm_policy_afinfo xfrm4_policy_afinfo = {
 #ifdef CONFIG_SYSCTL
 static struct ctl_table xfrm4_policy_table[] = {
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "xfrm4_gc_thresh",
 		.data           = &xfrm4_dst_ops.gc_thresh,
 		.maxlen         = sizeof(int),
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1fd0a3d..f918399 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4000,41 +4000,6 @@ int addrconf_sysctl_forward(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int addrconf_sysctl_forward_strategy(ctl_table *table,
-					    void __user *oldval,
-					    size_t __user *oldlenp,
-					    void __user *newval, size_t newlen)
-{
-	int *valp = table->data;
-	int val = *valp;
-	int new;
-
-	if (!newval || !newlen)
-		return 0;
-	if (newlen != sizeof(int))
-		return -EINVAL;
-	if (get_user(new, (int __user *)newval))
-		return -EFAULT;
-	if (new == *valp)
-		return 0;
-	if (oldval && oldlenp) {
-		size_t len;
-		if (get_user(len, oldlenp))
-			return -EFAULT;
-		if (len) {
-			if (len > table->maxlen)
-				len = table->maxlen;
-			if (copy_to_user(oldval, valp, len))
-				return -EFAULT;
-			if (put_user(len, oldlenp))
-				return -EFAULT;
-		}
-	}
-
-	*valp = new;
-	return addrconf_fixup_forwarding(table, valp, val);
-}
-
 static void dev_disable_change(struct inet6_dev *idev)
 {
 	if (!idev || !idev->dev)
@@ -4113,16 +4078,13 @@ static struct addrconf_sysctl_table
 	.sysctl_header = NULL,
 	.addrconf_vars = {
 		{
-			.ctl_name	=	NET_IPV6_FORWARDING,
 			.procname	=	"forwarding",
 			.data		=	&ipv6_devconf.forwarding,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
 			.proc_handler	=	addrconf_sysctl_forward,
-			.strategy	=	addrconf_sysctl_forward_strategy,
 		},
 		{
-			.ctl_name	=	NET_IPV6_HOP_LIMIT,
 			.procname	=	"hop_limit",
 			.data		=	&ipv6_devconf.hop_limit,
 			.maxlen		=	sizeof(int),
@@ -4130,7 +4092,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_MTU,
 			.procname	=	"mtu",
 			.data		=	&ipv6_devconf.mtu6,
 			.maxlen		=	sizeof(int),
@@ -4138,7 +4099,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_RA,
 			.procname	=	"accept_ra",
 			.data		=	&ipv6_devconf.accept_ra,
 			.maxlen		=	sizeof(int),
@@ -4146,7 +4106,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_REDIRECTS,
 			.procname	=	"accept_redirects",
 			.data		=	&ipv6_devconf.accept_redirects,
 			.maxlen		=	sizeof(int),
@@ -4154,7 +4113,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_AUTOCONF,
 			.procname	=	"autoconf",
 			.data		=	&ipv6_devconf.autoconf,
 			.maxlen		=	sizeof(int),
@@ -4162,7 +4120,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_DAD_TRANSMITS,
 			.procname	=	"dad_transmits",
 			.data		=	&ipv6_devconf.dad_transmits,
 			.maxlen		=	sizeof(int),
@@ -4170,7 +4127,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_RTR_SOLICITS,
 			.procname	=	"router_solicitations",
 			.data		=	&ipv6_devconf.rtr_solicits,
 			.maxlen		=	sizeof(int),
@@ -4178,25 +4134,20 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_RTR_SOLICIT_INTERVAL,
 			.procname	=	"router_solicitation_interval",
 			.data		=	&ipv6_devconf.rtr_solicit_interval,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
 			.proc_handler	=	proc_dointvec_jiffies,
-			.strategy	=	sysctl_jiffies,
 		},
 		{
-			.ctl_name	=	NET_IPV6_RTR_SOLICIT_DELAY,
 			.procname	=	"router_solicitation_delay",
 			.data		=	&ipv6_devconf.rtr_solicit_delay,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
 			.proc_handler	=	proc_dointvec_jiffies,
-			.strategy	=	sysctl_jiffies,
 		},
 		{
-			.ctl_name	=	NET_IPV6_FORCE_MLD_VERSION,
 			.procname	=	"force_mld_version",
 			.data		=	&ipv6_devconf.force_mld_version,
 			.maxlen		=	sizeof(int),
@@ -4205,7 +4156,6 @@ static struct addrconf_sysctl_table
 		},
 #ifdef CONFIG_IPV6_PRIVACY
 		{
-			.ctl_name	=	NET_IPV6_USE_TEMPADDR,
 			.procname	=	"use_tempaddr",
 			.data		=	&ipv6_devconf.use_tempaddr,
 			.maxlen		=	sizeof(int),
@@ -4213,7 +4163,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_TEMP_VALID_LFT,
 			.procname	=	"temp_valid_lft",
 			.data		=	&ipv6_devconf.temp_valid_lft,
 			.maxlen		=	sizeof(int),
@@ -4221,7 +4170,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_TEMP_PREFERED_LFT,
 			.procname	=	"temp_prefered_lft",
 			.data		=	&ipv6_devconf.temp_prefered_lft,
 			.maxlen		=	sizeof(int),
@@ -4229,7 +4177,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_REGEN_MAX_RETRY,
 			.procname	=	"regen_max_retry",
 			.data		=	&ipv6_devconf.regen_max_retry,
 			.maxlen		=	sizeof(int),
@@ -4237,7 +4184,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_MAX_DESYNC_FACTOR,
 			.procname	=	"max_desync_factor",
 			.data		=	&ipv6_devconf.max_desync_factor,
 			.maxlen		=	sizeof(int),
@@ -4246,7 +4192,6 @@ static struct addrconf_sysctl_table
 		},
 #endif
 		{
-			.ctl_name	=	NET_IPV6_MAX_ADDRESSES,
 			.procname	=	"max_addresses",
 			.data		=	&ipv6_devconf.max_addresses,
 			.maxlen		=	sizeof(int),
@@ -4254,7 +4199,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_RA_DEFRTR,
 			.procname	=	"accept_ra_defrtr",
 			.data		=	&ipv6_devconf.accept_ra_defrtr,
 			.maxlen		=	sizeof(int),
@@ -4262,7 +4206,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_RA_PINFO,
 			.procname	=	"accept_ra_pinfo",
 			.data		=	&ipv6_devconf.accept_ra_pinfo,
 			.maxlen		=	sizeof(int),
@@ -4271,7 +4214,6 @@ static struct addrconf_sysctl_table
 		},
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_RA_RTR_PREF,
 			.procname	=	"accept_ra_rtr_pref",
 			.data		=	&ipv6_devconf.accept_ra_rtr_pref,
 			.maxlen		=	sizeof(int),
@@ -4279,17 +4221,14 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_RTR_PROBE_INTERVAL,
 			.procname	=	"router_probe_interval",
 			.data		=	&ipv6_devconf.rtr_probe_interval,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
 			.proc_handler	=	proc_dointvec_jiffies,
-			.strategy	=	sysctl_jiffies,
 		},
 #ifdef CONFIG_IPV6_ROUTE_INFO
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_RA_RT_INFO_MAX_PLEN,
 			.procname	=	"accept_ra_rt_info_max_plen",
 			.data		=	&ipv6_devconf.accept_ra_rt_info_max_plen,
 			.maxlen		=	sizeof(int),
@@ -4299,7 +4238,6 @@ static struct addrconf_sysctl_table
 #endif
 #endif
 		{
-			.ctl_name	=	NET_IPV6_PROXY_NDP,
 			.procname	=	"proxy_ndp",
 			.data		=	&ipv6_devconf.proxy_ndp,
 			.maxlen		=	sizeof(int),
@@ -4307,7 +4245,6 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	NET_IPV6_ACCEPT_SOURCE_ROUTE,
 			.procname	=	"accept_source_route",
 			.data		=	&ipv6_devconf.accept_source_route,
 			.maxlen		=	sizeof(int),
@@ -4316,7 +4253,6 @@ static struct addrconf_sysctl_table
 		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
-			.ctl_name	=	CTL_UNNUMBERED,
 			.procname       =       "optimistic_dad",
 			.data           =       &ipv6_devconf.optimistic_dad,
 			.maxlen         =       sizeof(int),
@@ -4327,7 +4263,6 @@ static struct addrconf_sysctl_table
 #endif
 #ifdef CONFIG_IPV6_MROUTE
 		{
-			.ctl_name	=	CTL_UNNUMBERED,
 			.procname	=	"mc_forwarding",
 			.data		=	&ipv6_devconf.mc_forwarding,
 			.maxlen		=	sizeof(int),
@@ -4336,16 +4271,13 @@ static struct addrconf_sysctl_table
 		},
 #endif
 		{
-			.ctl_name	=	CTL_UNNUMBERED,
 			.procname	=	"disable_ipv6",
 			.data		=	&ipv6_devconf.disable_ipv6,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
 			.proc_handler	=	addrconf_sysctl_disable,
-			.strategy	=	sysctl_intvec,
 		},
 		{
-			.ctl_name	=	CTL_UNNUMBERED,
 			.procname	=	"accept_dad",
 			.data		=	&ipv6_devconf.accept_dad,
 			.maxlen		=	sizeof(int),
@@ -4353,13 +4285,13 @@ static struct addrconf_sysctl_table
 			.proc_handler	=	proc_dointvec,
 		},
 		{
-			.ctl_name	=	0,	/* sentinel */
+			/* sentinel */
 		}
 	},
 };
 
 static int __addrconf_sysctl_register(struct net *net, char *dev_name,
-		int ctl_name, struct inet6_dev *idev, struct ipv6_devconf *p)
+		struct inet6_dev *idev, struct ipv6_devconf *p)
 {
 	int i;
 	struct addrconf_sysctl_table *t;
@@ -4367,9 +4299,9 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 #define ADDRCONF_CTL_PATH_DEV	3
 
 	struct ctl_path addrconf_ctl_path[] = {
-		{ .procname = "net", .ctl_name = CTL_NET, },
-		{ .procname = "ipv6", .ctl_name = NET_IPV6, },
-		{ .procname = "conf", .ctl_name = NET_IPV6_CONF, },
+		{ .procname = "net", },
+		{ .procname = "ipv6", },
+		{ .procname = "conf", },
 		{ /* to be set */ },
 		{ },
 	};
@@ -4395,7 +4327,6 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		goto free;
 
 	addrconf_ctl_path[ADDRCONF_CTL_PATH_DEV].procname = t->dev_name;
-	addrconf_ctl_path[ADDRCONF_CTL_PATH_DEV].ctl_name = ctl_name;
 
 	t->sysctl_header = register_net_sysctl_table(net, addrconf_ctl_path,
 			t->addrconf_vars);
@@ -4431,10 +4362,9 @@ static void addrconf_sysctl_register(struct inet6_dev *idev)
 {
 	neigh_sysctl_register(idev->dev, idev->nd_parms, NET_IPV6,
 			      NET_IPV6_NEIGH, "ipv6",
-			      &ndisc_ifinfo_sysctl_change,
-			      ndisc_ifinfo_sysctl_strategy);
+			      &ndisc_ifinfo_sysctl_change);
 	__addrconf_sysctl_register(dev_net(idev->dev), idev->dev->name,
-			idev->dev->ifindex, idev, &idev->cnf);
+					idev, &idev->cnf);
 }
 
 static void addrconf_sysctl_unregister(struct inet6_dev *idev)
@@ -4473,13 +4403,11 @@ static int addrconf_init_net(struct net *net)
 	net->ipv6.devconf_dflt = dflt;
 
 #ifdef CONFIG_SYSCTL
-	err = __addrconf_sysctl_register(net, "all", NET_PROTO_CONF_ALL,
-			NULL, all);
+	err = __addrconf_sysctl_register(net, "all", NULL, all);
 	if (err < 0)
 		goto err_reg_all;
 
-	err = __addrconf_sysctl_register(net, "default", NET_PROTO_CONF_DEFAULT,
-			NULL, dflt);
+	err = __addrconf_sysctl_register(net, "default", NULL, dflt);
 	if (err < 0)
 		goto err_reg_dflt;
 #endif
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index f23ebbe..4ae661b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -942,15 +942,13 @@ EXPORT_SYMBOL(icmpv6_err_convert);
 #ifdef CONFIG_SYSCTL
 ctl_table ipv6_icmp_table_template[] = {
 	{
-		.ctl_name	= NET_IPV6_ICMP_RATELIMIT,
 		.procname	= "ratelimit",
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_ms_jiffies,
-		.strategy	= sysctl_ms_jiffies
 	},
-	{ .ctl_name = 0 },
+	{ },
 };
 
 struct ctl_table *ipv6_icmp_sysctl_init(struct net *net)
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f74e4e2..3d0520e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1768,42 +1768,6 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 	return ret;
 }
 
-int ndisc_ifinfo_sysctl_strategy(ctl_table *ctl,
-				 void __user *oldval, size_t __user *oldlenp,
-				 void __user *newval, size_t newlen)
-{
-	struct net_device *dev = ctl->extra1;
-	struct inet6_dev *idev;
-	int ret;
-
-	if (ctl->ctl_name == NET_NEIGH_RETRANS_TIME ||
-	    ctl->ctl_name == NET_NEIGH_REACHABLE_TIME)
-		ndisc_warn_deprecated_sysctl(ctl, "procfs", dev ? dev->name : "default");
-
-	switch (ctl->ctl_name) {
-	case NET_NEIGH_REACHABLE_TIME:
-		ret = sysctl_jiffies(ctl, oldval, oldlenp, newval, newlen);
-		break;
-	case NET_NEIGH_RETRANS_TIME_MS:
-	case NET_NEIGH_REACHABLE_TIME_MS:
-		 ret = sysctl_ms_jiffies(ctl, oldval, oldlenp, newval, newlen);
-		 break;
-	default:
-		ret = 0;
-	}
-
-	if (newval && newlen && ret > 0 &&
-	    dev && (idev = in6_dev_get(dev)) != NULL) {
-		if (ctl->ctl_name == NET_NEIGH_REACHABLE_TIME ||
-		    ctl->ctl_name == NET_NEIGH_REACHABLE_TIME_MS)
-			idev->nd_parms->reachable_time = neigh_rand_reach_time(idev->nd_parms->base_reachable_time);
-		idev->tstamp = jiffies;
-		inet6_ifinfo_notify(RTM_NEWLINK, idev);
-		in6_dev_put(idev);
-	}
-
-	return ret;
-}
 
 #endif
 
@@ -1857,8 +1821,7 @@ int __init ndisc_init(void)
 #ifdef CONFIG_SYSCTL
 	err = neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6,
 				    NET_IPV6_NEIGH, "ipv6",
-				    &ndisc_ifinfo_sysctl_change,
-				    &ndisc_ifinfo_sysctl_strategy);
+				    &ndisc_ifinfo_sysctl_change);
 	if (err)
 		goto out_unregister_pernet;
 #endif
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 1cf3f0c..14e52aa 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -36,7 +36,6 @@
 
 #define IPQ_QMAX_DEFAULT 1024
 #define IPQ_PROC_FS_NAME "ip6_queue"
-#define NET_IPQ_QMAX 2088
 #define NET_IPQ_QMAX_NAME "ip6_queue_maxlen"
 
 typedef int (*ipq_cmpfn)(struct nf_queue_entry *, unsigned long);
@@ -518,14 +517,13 @@ static struct ctl_table_header *ipq_sysctl_header;
 
 static ctl_table ipq_table[] = {
 	{
-		.ctl_name	= NET_IPQ_QMAX,
 		.procname	= NET_IPQ_QMAX_NAME,
 		.data		= &queue_maxlen,
 		.maxlen		= sizeof(queue_maxlen),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 #endif
 
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 642dcb1..2acadc8 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -277,9 +277,7 @@ static struct ctl_table icmpv6_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index f3aba25..e0b9424 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -83,7 +83,6 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_FRAG6_LOW_THRESH,
 		.procname	= "nf_conntrack_frag6_low_thresh",
 		.data		= &nf_init_frags.low_thresh,
 		.maxlen		= sizeof(unsigned int),
@@ -91,14 +90,13 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_FRAG6_HIGH_THRESH,
 		.procname	= "nf_conntrack_frag6_high_thresh",
 		.data		= &nf_init_frags.high_thresh,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 #endif
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index da5bd0e..2499e97 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -636,7 +636,6 @@ static const struct inet6_protocol frag_protocol =
 #ifdef CONFIG_SYSCTL
 static struct ctl_table ip6_frags_ns_ctl_table[] = {
 	{
-		.ctl_name	= NET_IPV6_IP6FRAG_HIGH_THRESH,
 		.procname	= "ip6frag_high_thresh",
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
@@ -644,7 +643,6 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
 		.procname	= "ip6frag_low_thresh",
 		.data		= &init_net.ipv6.frags.low_thresh,
 		.maxlen		= sizeof(int),
@@ -652,26 +650,22 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IPV6_IP6FRAG_TIME,
 		.procname	= "ip6frag_time",
 		.data		= &init_net.ipv6.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies,
 	},
 	{ }
 };
 
 static struct ctl_table ip6_frags_ctl_table[] = {
 	{
-		.ctl_name	= NET_IPV6_IP6FRAG_SECRET_INTERVAL,
 		.procname	= "ip6frag_secret_interval",
 		.data		= &ip6_frags.secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
 	},
 	{ }
 };
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index d6fe764..6aa202e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2546,7 +2546,6 @@ ctl_table ipv6_route_table_template[] = {
 		.proc_handler	=	ipv6_sysctl_rtcache_flush
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_GC_THRESH,
 		.procname	=	"gc_thresh",
 		.data		=	&ip6_dst_ops_template.gc_thresh,
 		.maxlen		=	sizeof(int),
@@ -2554,7 +2553,6 @@ ctl_table ipv6_route_table_template[] = {
 		.proc_handler	=	proc_dointvec,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_MAX_SIZE,
 		.procname	=	"max_size",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
@@ -2562,69 +2560,55 @@ ctl_table ipv6_route_table_template[] = {
 		.proc_handler	=	proc_dointvec,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
 		.procname	=	"gc_min_interval",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_jiffies,
-		.strategy	=	sysctl_jiffies,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_GC_TIMEOUT,
 		.procname	=	"gc_timeout",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_timeout,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_jiffies,
-		.strategy	=	sysctl_jiffies,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_GC_INTERVAL,
 		.procname	=	"gc_interval",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_jiffies,
-		.strategy	=	sysctl_jiffies,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_GC_ELASTICITY,
 		.procname	=	"gc_elasticity",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_jiffies,
-		.strategy	=	sysctl_jiffies,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_MTU_EXPIRES,
 		.procname	=	"mtu_expires",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_mtu_expires,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_jiffies,
-		.strategy	=	sysctl_jiffies,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_MIN_ADVMSS,
 		.procname	=	"min_adv_mss",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_min_advmss,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_jiffies,
-		.strategy	=	sysctl_jiffies,
 	},
 	{
-		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL_MS,
 		.procname	=	"gc_min_interval_ms",
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
 		.proc_handler	=	proc_dointvec_ms_jiffies,
-		.strategy	=	sysctl_ms_jiffies,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 struct ctl_table *ipv6_route_sysctl_init(struct net *net)
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 0dc6a4e..c690736 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -16,45 +16,41 @@
 
 static ctl_table ipv6_table_template[] = {
 	{
-		.ctl_name	= NET_IPV6_ROUTE,
 		.procname	= "route",
 		.maxlen		= 0,
 		.mode		= 0555,
 		.child		= ipv6_route_table_template
 	},
 	{
-		.ctl_name	= NET_IPV6_ICMP,
 		.procname	= "icmp",
 		.maxlen		= 0,
 		.mode		= 0555,
 		.child		= ipv6_icmp_table_template
 	},
 	{
-		.ctl_name	= NET_IPV6_BINDV6ONLY,
 		.procname	= "bindv6only",
 		.data		= &init_net.ipv6.sysctl.bindv6only,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static ctl_table ipv6_rotable[] = {
 	{
-		.ctl_name	= NET_IPV6_MLD_MAX_MSF,
 		.procname	= "mld_max_msf",
 		.data		= &sysctl_mld_max_msf,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 struct ctl_path net_ipv6_ctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv6", .ctl_name = NET_IPV6, },
+	{ .procname = "net", },
+	{ .procname = "ipv6", },
 	{ },
 };
 EXPORT_SYMBOL_GPL(net_ipv6_ctl_path);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8ec3d45..7254e3f 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -309,7 +309,6 @@ static void xfrm6_policy_fini(void)
 #ifdef CONFIG_SYSCTL
 static struct ctl_table xfrm6_policy_table[] = {
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "xfrm6_gc_thresh",
 		.data	   	= &xfrm6_dst_ops.gc_thresh,
 		.maxlen	 	= sizeof(int),
diff --git a/net/ipx/sysctl_net_ipx.c b/net/ipx/sysctl_net_ipx.c
index 633fcab..bd6dca0 100644
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -18,19 +18,18 @@ extern int sysctl_ipx_pprop_broadcasting;
 
 static struct ctl_table ipx_table[] = {
 	{
-		.ctl_name	= NET_IPX_PPROP_BROADCASTING,
 		.procname	= "ipx_pprop_broadcasting",
 		.data		= &sysctl_ipx_pprop_broadcasting,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{ 0 },
+	{ },
 };
 
 static struct ctl_path ipx_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipx", .ctl_name = NET_IPX, },
+	{ .procname = "net", },
+	{ .procname = "ipx", },
 	{ }
 };
 
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index 5c86567..d0b70da 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -113,26 +113,21 @@ static int do_discovery(ctl_table *table, int write,
 /* One file */
 static ctl_table irda_table[] = {
 	{
-		.ctl_name	= NET_IRDA_DISCOVERY,
 		.procname	= "discovery",
 		.data		= &sysctl_discovery,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= do_discovery,
-		.strategy       = sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_IRDA_DEVNAME,
 		.procname	= "devname",
 		.data		= sysctl_devname,
 		.maxlen		= 65,
 		.mode		= 0644,
 		.proc_handler	= do_devname,
-		.strategy	= sysctl_string
 	},
 #ifdef CONFIG_IRDA_DEBUG
 	{
-		.ctl_name	= NET_IRDA_DEBUG,
 		.procname	= "debug",
 		.data		= &irda_debug,
 		.maxlen		= sizeof(int),
@@ -142,7 +137,6 @@ static ctl_table irda_table[] = {
 #endif
 #ifdef CONFIG_IRDA_FAST_RR
 	{
-		.ctl_name	= NET_IRDA_FAST_POLL,
 		.procname	= "fast_poll_increase",
 		.data		= &sysctl_fast_poll_increase,
 		.maxlen		= sizeof(int),
@@ -151,18 +145,15 @@ static ctl_table irda_table[] = {
 	},
 #endif
 	{
-		.ctl_name	= NET_IRDA_DISCOVERY_SLOTS,
 		.procname	= "discovery_slots",
 		.data		= &sysctl_discovery_slots,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_discovery_slots,
 		.extra2		= &max_discovery_slots
 	},
 	{
-		.ctl_name	= NET_IRDA_DISCOVERY_TIMEOUT,
 		.procname	= "discovery_timeout",
 		.data		= &sysctl_discovery_timeout,
 		.maxlen		= sizeof(int),
@@ -170,99 +161,83 @@ static ctl_table irda_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_IRDA_SLOT_TIMEOUT,
 		.procname	= "slot_timeout",
 		.data		= &sysctl_slot_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_slot_timeout,
 		.extra2		= &max_slot_timeout
 	},
 	{
-		.ctl_name	= NET_IRDA_MAX_BAUD_RATE,
 		.procname	= "max_baud_rate",
 		.data		= &sysctl_max_baud_rate,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_baud_rate,
 		.extra2		= &max_max_baud_rate
 	},
 	{
-		.ctl_name	= NET_IRDA_MIN_TX_TURN_TIME,
 		.procname	= "min_tx_turn_time",
 		.data		= &sysctl_min_tx_turn_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_min_tx_turn_time,
 		.extra2		= &max_min_tx_turn_time
 	},
 	{
-		.ctl_name	= NET_IRDA_MAX_TX_DATA_SIZE,
 		.procname	= "max_tx_data_size",
 		.data		= &sysctl_max_tx_data_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_tx_data_size,
 		.extra2		= &max_max_tx_data_size
 	},
 	{
-		.ctl_name	= NET_IRDA_MAX_TX_WINDOW,
 		.procname	= "max_tx_window",
 		.data		= &sysctl_max_tx_window,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_tx_window,
 		.extra2		= &max_max_tx_window
 	},
 	{
-		.ctl_name	= NET_IRDA_MAX_NOREPLY_TIME,
 		.procname	= "max_noreply_time",
 		.data		= &sysctl_max_noreply_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_noreply_time,
 		.extra2		= &max_max_noreply_time
 	},
 	{
-		.ctl_name	= NET_IRDA_WARN_NOREPLY_TIME,
 		.procname	= "warn_noreply_time",
 		.data		= &sysctl_warn_noreply_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_warn_noreply_time,
 		.extra2		= &max_warn_noreply_time
 	},
 	{
-		.ctl_name	= NET_IRDA_LAP_KEEPALIVE_TIME,
 		.procname	= "lap_keepalive_time",
 		.data		= &sysctl_lap_keepalive_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_lap_keepalive_time,
 		.extra2		= &max_lap_keepalive_time
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path irda_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "irda", .ctl_name = NET_IRDA, },
+	{ .procname = "net", },
+	{ .procname = "irda", },
 	{ }
 };
 
diff --git a/net/llc/sysctl_net_llc.c b/net/llc/sysctl_net_llc.c
index 57b9304..e2ebe35 100644
--- a/net/llc/sysctl_net_llc.c
+++ b/net/llc/sysctl_net_llc.c
@@ -15,86 +15,73 @@
 
 static struct ctl_table llc2_timeout_table[] = {
 	{
-		.ctl_name	= NET_LLC2_ACK_TIMEOUT,
 		.procname	= "ack",
 		.data		= &sysctl_llc2_ack_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
 		.proc_handler   = proc_dointvec_jiffies,
-		.strategy       = sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_LLC2_BUSY_TIMEOUT,
 		.procname	= "busy",
 		.data		= &sysctl_llc2_busy_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
 		.proc_handler   = proc_dointvec_jiffies,
-		.strategy       = sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_LLC2_P_TIMEOUT,
 		.procname	= "p",
 		.data		= &sysctl_llc2_p_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
 		.proc_handler   = proc_dointvec_jiffies,
-		.strategy       = sysctl_jiffies,
 	},
 	{
-		.ctl_name	= NET_LLC2_REJ_TIMEOUT,
 		.procname	= "rej",
 		.data		= &sysctl_llc2_rej_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
 		.proc_handler   = proc_dointvec_jiffies,
-		.strategy       = sysctl_jiffies,
 	},
-	{ 0 },
+	{ },
 };
 
 static struct ctl_table llc_station_table[] = {
 	{
-		.ctl_name	= NET_LLC_STATION_ACK_TIMEOUT,
 		.procname	= "ack_timeout",
 		.data		= &sysctl_llc_station_ack_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
 		.proc_handler   = proc_dointvec_jiffies,
-		.strategy       = sysctl_jiffies,
 	},
-	{ 0 },
+	{ },
 };
 
 static struct ctl_table llc2_dir_timeout_table[] = {
 	{
-		.ctl_name	= NET_LLC2,
 		.procname	= "timeout",
 		.mode		= 0555,
 		.child		= llc2_timeout_table,
 	},
-	{ 0 },
+	{ },
 };
 
 static struct ctl_table llc_table[] = {
 	{
-		.ctl_name	= NET_LLC2,
 		.procname	= "llc2",
 		.mode		= 0555,
 		.child		= llc2_dir_timeout_table,
 	},
 	{
-		.ctl_name       = NET_LLC_STATION,
 		.procname       = "station",
 		.mode           = 0555,
 		.child          = llc_station_table,
 	},
-	{ 0 },
+	{ },
 };
 
 static struct ctl_path llc_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "llc", .ctl_name = NET_LLC, },
+	{ .procname = "net", },
+	{ .procname = "llc", },
 	{ }
 };
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 5bb3473..60ec4e4 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -273,8 +273,8 @@ void __init netfilter_init(void)
 
 #ifdef CONFIG_SYSCTL
 struct ctl_path nf_net_netfilter_sysctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "netfilter", .ctl_name = NET_NETFILTER, },
+	{ .procname = "net", },
+	{ .procname = "netfilter", },
 	{ }
 };
 EXPORT_SYMBOL_GPL(nf_net_netfilter_sysctl_path);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 446e9bd..e55a686 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1706,12 +1706,12 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 const struct ctl_path net_vs_ctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "ipv4", .ctl_name = NET_IPV4, },
+	{ .procname = "net", },
+	{ .procname = "ipv4", },
 	{ .procname = "vs", },
 	{ }
 };
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index c1757f3..1b9370d 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -121,7 +121,7 @@ static ctl_table vs_vars_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_table_header * sysctl_header;
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 715b57f..f7476b9 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -302,7 +302,7 @@ static ctl_table vs_vars_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_table_header * sysctl_header;
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 4a1d94a..018f90d 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -30,7 +30,6 @@ MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
 #ifdef CONFIG_SYSCTL
 static struct ctl_table acct_sysctl_table[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_acct",
 		.data		= &init_net.ct.sysctl_acct,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index aee560b..d5a9bcd 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -151,7 +151,6 @@ static int nf_ct_events_retry_timeout __read_mostly = 15*HZ;
 #ifdef CONFIG_SYSCTL
 static struct ctl_table event_sysctl_table[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_events",
 		.data		= &init_net.ct.sysctl_events,
 		.maxlen		= sizeof(unsigned int),
@@ -159,7 +158,6 @@ static struct ctl_table event_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_events_retry_timeout",
 		.data		= &init_net.ct.sysctl_events_retry_timeout,
 		.maxlen		= sizeof(unsigned int),
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 1b816a2..7bf1395 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -703,64 +703,54 @@ static int dccp_nlattr_size(void)
 /* template, data assigned later */
 static struct ctl_table dccp_sysctl_table[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_request",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_respond",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_partopen",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_open",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_closereq",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_closing",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_timewait",
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_loose",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{
-		.ctl_name	= 0,
-	}
+	{ }
 };
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 829374f..e2091d0 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -69,9 +69,7 @@ static struct ctl_table generic_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table generic_compat_sysctl_table[] = {
@@ -82,9 +80,7 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c10e6f3..f9d930f 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -595,9 +595,7 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name = 0
-	}
+	{ }
 };
 
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
@@ -651,9 +649,7 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name = 0
-	}
+	{ }
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 97a82ba..f862846 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1303,7 +1303,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_LOOSE,
 		.procname	= "nf_conntrack_tcp_loose",
 		.data		= &nf_ct_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
@@ -1311,7 +1310,6 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_BE_LIBERAL,
 		.procname       = "nf_conntrack_tcp_be_liberal",
 		.data           = &nf_ct_tcp_be_liberal,
 		.maxlen         = sizeof(unsigned int),
@@ -1319,16 +1317,13 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.proc_handler   = proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_TCP_MAX_RETRANS,
 		.procname	= "nf_conntrack_tcp_max_retrans",
 		.data		= &nf_ct_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
@@ -1404,7 +1399,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_LOOSE,
 		.procname	= "ip_conntrack_tcp_loose",
 		.data		= &nf_ct_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
@@ -1412,7 +1406,6 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_BE_LIBERAL,
 		.procname	= "ip_conntrack_tcp_be_liberal",
 		.data		= &nf_ct_tcp_be_liberal,
 		.maxlen		= sizeof(unsigned int),
@@ -1420,16 +1413,13 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_MAX_RETRANS,
 		.procname	= "ip_conntrack_tcp_max_retrans",
 		.data		= &nf_ct_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 70809d1..5c5518b 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -154,9 +154,7 @@ static struct ctl_table udp_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 static struct ctl_table udp_compat_sysctl_table[] = {
@@ -174,9 +172,7 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 0badedc..458655b 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -146,7 +146,6 @@ static unsigned int udplite_sysctl_table_users;
 static struct ctl_table_header *udplite_sysctl_header;
 static struct ctl_table udplite_sysctl_table[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_udplite_timeout",
 		.data		= &nf_ct_udplite_timeout,
 		.maxlen		= sizeof(unsigned int),
@@ -154,16 +153,13 @@ static struct ctl_table udplite_sysctl_table[] = {
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_udplite_timeout_stream",
 		.data		= &nf_ct_udplite_timeout_stream,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
-	{
-		.ctl_name	= 0
-	}
+	{ }
 };
 #endif /* CONFIG_SYSCTL */
 
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1935153..028aba6 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -340,7 +340,6 @@ static struct ctl_table_header *nf_ct_netfilter_header;
 
 static ctl_table nf_ct_sysctl_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_MAX,
 		.procname	= "nf_conntrack_max",
 		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
@@ -348,7 +347,6 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_COUNT,
 		.procname	= "nf_conntrack_count",
 		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
@@ -356,7 +354,6 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name       = NET_NF_CONNTRACK_BUCKETS,
 		.procname       = "nf_conntrack_buckets",
 		.data           = &nf_conntrack_htable_size,
 		.maxlen         = sizeof(unsigned int),
@@ -364,7 +361,6 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.proc_handler   = proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_CHECKSUM,
 		.procname	= "nf_conntrack_checksum",
 		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(unsigned int),
@@ -372,43 +368,39 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= NET_NF_CONNTRACK_LOG_INVALID,
 		.procname	= "nf_conntrack_log_invalid",
 		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &log_invalid_proto_min,
 		.extra2		= &log_invalid_proto_max,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_expect_max",
 		.data		= &nf_ct_expect_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 #define NET_NF_CONNTRACK_MAX 2089
 
 static ctl_table nf_ct_netfilter_table[] = {
 	{
-		.ctl_name	= NET_NF_CONNTRACK_MAX,
 		.procname	= "nf_conntrack_max",
 		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path nf_ct_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "net", },
 	{ }
 };
 
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index c93494f..565e0a3 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -216,9 +216,9 @@ static const struct file_operations nflog_file_ops = {
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_path nf_log_sysctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "netfilter", .ctl_name = NET_NETFILTER, },
-	{ .procname = "nf_log", .ctl_name = CTL_UNNUMBERED, },
+	{ .procname = "net", },
+	{ .procname = "netfilter", },
+	{ .procname = "nf_log", },
 	{ }
 };
 
@@ -273,7 +273,6 @@ static __init int netfilter_log_sysctl_init(void)
 
 	for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++) {
 		snprintf(nf_log_sysctl_fnames[i-NFPROTO_UNSPEC], 3, "%d", i);
-		nf_log_sysctl_table[i].ctl_name	= CTL_UNNUMBERED;
 		nf_log_sysctl_table[i].procname	=
 			nf_log_sysctl_fnames[i-NFPROTO_UNSPEC];
 		nf_log_sysctl_table[i].data = NULL;
diff --git a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
index 7b49591..1e0fa9e 100644
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -36,143 +36,119 @@ static struct ctl_table_header *nr_table_header;
 
 static ctl_table nr_table[] = {
 	{
-		.ctl_name	= NET_NETROM_DEFAULT_PATH_QUALITY,
 		.procname	= "default_path_quality",
 		.data		= &sysctl_netrom_default_path_quality,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_quality,
 		.extra2		= &max_quality
 	},
 	{
-		.ctl_name	= NET_NETROM_OBSOLESCENCE_COUNT_INITIALISER,
 		.procname	= "obsolescence_count_initialiser",
 		.data		= &sysctl_netrom_obsolescence_count_initialiser,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_obs,
 		.extra2		= &max_obs
 	},
 	{
-		.ctl_name	= NET_NETROM_NETWORK_TTL_INITIALISER,
 		.procname	= "network_ttl_initialiser",
 		.data		= &sysctl_netrom_network_ttl_initialiser,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_ttl,
 		.extra2		= &max_ttl
 	},
 	{
-		.ctl_name	= NET_NETROM_TRANSPORT_TIMEOUT,
 		.procname	= "transport_timeout",
 		.data		= &sysctl_netrom_transport_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_t1,
 		.extra2		= &max_t1
 	},
 	{
-		.ctl_name	= NET_NETROM_TRANSPORT_MAXIMUM_TRIES,
 		.procname	= "transport_maximum_tries",
 		.data		= &sysctl_netrom_transport_maximum_tries,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_n2,
 		.extra2		= &max_n2
 	},
 	{
-		.ctl_name	= NET_NETROM_TRANSPORT_ACKNOWLEDGE_DELAY,
 		.procname	= "transport_acknowledge_delay",
 		.data		= &sysctl_netrom_transport_acknowledge_delay,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_t2,
 		.extra2		= &max_t2
 	},
 	{
-		.ctl_name	= NET_NETROM_TRANSPORT_BUSY_DELAY,
 		.procname	= "transport_busy_delay",
 		.data		= &sysctl_netrom_transport_busy_delay,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_t4,
 		.extra2		= &max_t4
 	},
 	{
-		.ctl_name	= NET_NETROM_TRANSPORT_REQUESTED_WINDOW_SIZE,
 		.procname	= "transport_requested_window_size",
 		.data		= &sysctl_netrom_transport_requested_window_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_window,
 		.extra2		= &max_window
 	},
 	{
-		.ctl_name	= NET_NETROM_TRANSPORT_NO_ACTIVITY_TIMEOUT,
 		.procname	= "transport_no_activity_timeout",
 		.data		= &sysctl_netrom_transport_no_activity_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_idle,
 		.extra2		= &max_idle
 	},
 	{
-		.ctl_name	= NET_NETROM_ROUTING_CONTROL,
 		.procname	= "routing_control",
 		.data		= &sysctl_netrom_routing_control,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_route,
 		.extra2		= &max_route
 	},
 	{
-		.ctl_name	= NET_NETROM_LINK_FAILS_COUNT,
 		.procname	= "link_fails_count",
 		.data		= &sysctl_netrom_link_fails_count,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_fails,
 		.extra2		= &max_fails
 	},
 	{
-		.ctl_name	= NET_NETROM_RESET,
 		.procname	= "reset",
 		.data		= &sysctl_netrom_reset_circuit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_reset,
 		.extra2		= &max_reset
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path nr_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "netrom", .ctl_name = NET_NETROM, },
+	{ .procname = "net", },
+	{ .procname = "netrom", },
 	{ }
 };
 
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index 2220f33..cea1c7d 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -84,20 +84,18 @@ static int proc_local_port_range(ctl_table *table, int write,
 
 static struct ctl_table phonet_table[] = {
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "local_port_range",
 		.data		= &local_port_range,
 		.maxlen		= sizeof(local_port_range),
 		.mode		= 0644,
 		.proc_handler	= proc_local_port_range,
-		.strategy	= NULL,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path phonet_ctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "phonet", .ctl_name = CTL_UNNUMBERED, },
+	{ .procname = "net", },
+	{ .procname = "phonet", },
 	{ },
 };
 
diff --git a/net/rds/ib_sysctl.c b/net/rds/ib_sysctl.c
index 84b5ffc..517c6c9 100644
--- a/net/rds/ib_sysctl.c
+++ b/net/rds/ib_sysctl.c
@@ -67,7 +67,6 @@ unsigned int rds_ib_sysctl_flow_control = 0;
 
 ctl_table rds_ib_sysctl_table[] = {
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_send_wr",
 		.data		= &rds_ib_sysctl_max_send_wr,
 		.maxlen         = sizeof(unsigned long),
@@ -77,7 +76,6 @@ ctl_table rds_ib_sysctl_table[] = {
 		.extra2		= &rds_ib_sysctl_max_wr_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_recv_wr",
 		.data		= &rds_ib_sysctl_max_recv_wr,
 		.maxlen         = sizeof(unsigned long),
@@ -87,7 +85,6 @@ ctl_table rds_ib_sysctl_table[] = {
 		.extra2		= &rds_ib_sysctl_max_wr_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_unsignaled_wr",
 		.data		= &rds_ib_sysctl_max_unsig_wrs,
 		.maxlen         = sizeof(unsigned long),
@@ -97,7 +94,6 @@ ctl_table rds_ib_sysctl_table[] = {
 		.extra2		= &rds_ib_sysctl_max_unsig_wr_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_unsignaled_bytes",
 		.data		= &rds_ib_sysctl_max_unsig_bytes,
 		.maxlen         = sizeof(unsigned long),
@@ -107,7 +103,6 @@ ctl_table rds_ib_sysctl_table[] = {
 		.extra2		= &rds_ib_sysctl_max_unsig_bytes_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_recv_allocation",
 		.data		= &rds_ib_sysctl_max_recv_allocation,
 		.maxlen         = sizeof(unsigned long),
@@ -115,20 +110,19 @@ ctl_table rds_ib_sysctl_table[] = {
 		.proc_handler   = &proc_doulongvec_minmax,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "flow_control",
 		.data		= &rds_ib_sysctl_flow_control,
 		.maxlen		= sizeof(rds_ib_sysctl_flow_control),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
-	{ .ctl_name = 0}
+	{ }
 };
 
 static struct ctl_path rds_ib_sysctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "rds", .ctl_name = CTL_UNNUMBERED, },
-	{ .procname = "ib", .ctl_name = CTL_UNNUMBERED, },
+	{ .procname = "net", },
+	{ .procname = "rds", },
+	{ .procname = "ib", },
 	{ }
 };
 
diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
index 9590678..3e00b01 100644
--- a/net/rds/iw_sysctl.c
+++ b/net/rds/iw_sysctl.c
@@ -57,7 +57,6 @@ unsigned int rds_iw_sysctl_flow_control = 1;
 
 ctl_table rds_iw_sysctl_table[] = {
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_send_wr",
 		.data		= &rds_iw_sysctl_max_send_wr,
 		.maxlen         = sizeof(unsigned long),
@@ -67,7 +66,6 @@ ctl_table rds_iw_sysctl_table[] = {
 		.extra2		= &rds_iw_sysctl_max_wr_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_recv_wr",
 		.data		= &rds_iw_sysctl_max_recv_wr,
 		.maxlen         = sizeof(unsigned long),
@@ -77,7 +75,6 @@ ctl_table rds_iw_sysctl_table[] = {
 		.extra2		= &rds_iw_sysctl_max_wr_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_unsignaled_wr",
 		.data		= &rds_iw_sysctl_max_unsig_wrs,
 		.maxlen         = sizeof(unsigned long),
@@ -87,7 +84,6 @@ ctl_table rds_iw_sysctl_table[] = {
 		.extra2		= &rds_iw_sysctl_max_unsig_wr_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_unsignaled_bytes",
 		.data		= &rds_iw_sysctl_max_unsig_bytes,
 		.maxlen         = sizeof(unsigned long),
@@ -97,7 +93,6 @@ ctl_table rds_iw_sysctl_table[] = {
 		.extra2		= &rds_iw_sysctl_max_unsig_bytes_max,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "max_recv_allocation",
 		.data		= &rds_iw_sysctl_max_recv_allocation,
 		.maxlen         = sizeof(unsigned long),
@@ -105,20 +100,19 @@ ctl_table rds_iw_sysctl_table[] = {
 		.proc_handler   = &proc_doulongvec_minmax,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "flow_control",
 		.data		= &rds_iw_sysctl_flow_control,
 		.maxlen		= sizeof(rds_iw_sysctl_flow_control),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
-	{ .ctl_name = 0}
+	{ }
 };
 
 static struct ctl_path rds_iw_sysctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "rds", .ctl_name = CTL_UNNUMBERED, },
-	{ .procname = "iw", .ctl_name = CTL_UNNUMBERED, },
+	{ .procname = "net", },
+	{ .procname = "rds", },
+	{ .procname = "iw", },
 	{ }
 };
 
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index 307dc5c..8fb499e 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -51,7 +51,6 @@ unsigned int rds_sysctl_ping_enable = 1;
 
 static ctl_table rds_sysctl_rds_table[] = {
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "reconnect_min_delay_ms",
 		.data		= &rds_sysctl_reconnect_min_jiffies,
 		.maxlen         = sizeof(unsigned long),
@@ -61,7 +60,6 @@ static ctl_table rds_sysctl_rds_table[] = {
 		.extra2		= &rds_sysctl_reconnect_max_jiffies,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname       = "reconnect_max_delay_ms",
 		.data		= &rds_sysctl_reconnect_max_jiffies,
 		.maxlen         = sizeof(unsigned long),
@@ -71,7 +69,6 @@ static ctl_table rds_sysctl_rds_table[] = {
 		.extra2		= &rds_sysctl_reconnect_max,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "max_unacked_packets",
 		.data		= &rds_sysctl_max_unacked_packets,
 		.maxlen         = sizeof(unsigned long),
@@ -79,7 +76,6 @@ static ctl_table rds_sysctl_rds_table[] = {
 		.proc_handler   = &proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "max_unacked_bytes",
 		.data		= &rds_sysctl_max_unacked_bytes,
 		.maxlen         = sizeof(unsigned long),
@@ -87,19 +83,18 @@ static ctl_table rds_sysctl_rds_table[] = {
 		.proc_handler   = &proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "ping_enable",
 		.data		= &rds_sysctl_ping_enable,
 		.maxlen         = sizeof(int),
 		.mode           = 0644,
 		.proc_handler   = &proc_dointvec,
 	},
-	{ .ctl_name = 0}
+	{ }
 };
 
 static struct ctl_path rds_sysctl_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "rds", .ctl_name = CTL_UNNUMBERED, },
+	{ .procname = "net", },
+	{ .procname = "rds", },
 	{ }
 };
 
diff --git a/net/rose/sysctl_net_rose.c b/net/rose/sysctl_net_rose.c
index 3bfe504..df6d9da 100644
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -26,121 +26,101 @@ static struct ctl_table_header *rose_table_header;
 
 static ctl_table rose_table[] = {
 	{
-		.ctl_name	= NET_ROSE_RESTART_REQUEST_TIMEOUT,
 		.procname	= "restart_request_timeout",
 		.data		= &sysctl_rose_restart_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
 	{
-		.ctl_name	= NET_ROSE_CALL_REQUEST_TIMEOUT,
 		.procname	= "call_request_timeout",
 		.data		= &sysctl_rose_call_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
 	{
-		.ctl_name	= NET_ROSE_RESET_REQUEST_TIMEOUT,
 		.procname	= "reset_request_timeout",
 		.data		= &sysctl_rose_reset_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
 	{
-		.ctl_name	= NET_ROSE_CLEAR_REQUEST_TIMEOUT,
 		.procname	= "clear_request_timeout",
 		.data		= &sysctl_rose_clear_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
 	{
-		.ctl_name	= NET_ROSE_NO_ACTIVITY_TIMEOUT,
 		.procname	= "no_activity_timeout",
 		.data		= &sysctl_rose_no_activity_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_idle,
 		.extra2		= &max_idle
 	},
 	{
-		.ctl_name	= NET_ROSE_ACK_HOLD_BACK_TIMEOUT,
 		.procname	= "acknowledge_hold_back_timeout",
 		.data		= &sysctl_rose_ack_hold_back_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
 	{
-		.ctl_name	= NET_ROSE_ROUTING_CONTROL,
 		.procname	= "routing_control",
 		.data		= &sysctl_rose_routing_control,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_route,
 		.extra2		= &max_route
 	},
 	{
-		.ctl_name	= NET_ROSE_LINK_FAIL_TIMEOUT,
 		.procname	= "link_fail_timeout",
 		.data		= &sysctl_rose_link_fail_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_ftimer,
 		.extra2		= &max_ftimer
 	},
 	{
-		.ctl_name	= NET_ROSE_MAX_VCS,
 		.procname	= "maximum_virtual_circuits",
 		.data		= &sysctl_rose_maximum_vcs,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_maxvcs,
 		.extra2		= &max_maxvcs
 	},
 	{
-		.ctl_name	= NET_ROSE_WINDOW_SIZE,
 		.procname	= "window_size",
 		.data		= &sysctl_rose_window_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &min_window,
 		.extra2		= &max_window
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path rose_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "rose", .ctl_name = NET_ROSE, },
+	{ .procname = "net", },
+	{ .procname = "rose", },
 	{ }
 };
 
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index ab7151d..c4ece98 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -59,180 +59,145 @@ extern int sysctl_sctp_wmem[3];
 
 static ctl_table sctp_table[] = {
 	{
-		.ctl_name	= NET_SCTP_RTO_INITIAL,
 		.procname	= "rto_initial",
 		.data		= &sctp_rto_initial,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
 	{
-		.ctl_name	= NET_SCTP_RTO_MIN,
 		.procname	= "rto_min",
 		.data		= &sctp_rto_min,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
 	{
-		.ctl_name	= NET_SCTP_RTO_MAX,
 		.procname	= "rto_max",
 		.data		= &sctp_rto_max,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
 	{
-		.ctl_name	= NET_SCTP_VALID_COOKIE_LIFE,
 		.procname	= "valid_cookie_life",
 		.data		= &sctp_valid_cookie_life,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
 	{
-		.ctl_name	= NET_SCTP_MAX_BURST,
 		.procname	= "max_burst",
 		.data		= &sctp_max_burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &zero,
 		.extra2		= &int_max
 	},
 	{
-		.ctl_name	= NET_SCTP_ASSOCIATION_MAX_RETRANS,
 		.procname	= "association_max_retrans",
 		.data		= &sctp_max_retrans_association,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &one,
 		.extra2		= &int_max
 	},
 	{
-		.ctl_name	= NET_SCTP_SNDBUF_POLICY,
 		.procname	= "sndbuf_policy",
 		.data		= &sctp_sndbuf_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_RCVBUF_POLICY,
 		.procname	= "rcvbuf_policy",
 		.data		= &sctp_rcvbuf_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_PATH_MAX_RETRANS,
 		.procname	= "path_max_retrans",
 		.data		= &sctp_max_retrans_path,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &one,
 		.extra2		= &int_max
 	},
 	{
-		.ctl_name	= NET_SCTP_MAX_INIT_RETRANSMITS,
 		.procname	= "max_init_retransmits",
 		.data		= &sctp_max_retrans_init,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1		= &one,
 		.extra2		= &int_max
 	},
 	{
-		.ctl_name	= NET_SCTP_HB_INTERVAL,
 		.procname	= "hb_interval",
 		.data		= &sctp_hb_interval,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
 	{
-		.ctl_name	= NET_SCTP_PRESERVE_ENABLE,
 		.procname	= "cookie_preserve_enable",
 		.data		= &sctp_cookie_preserve_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_RTO_ALPHA,
 		.procname	= "rto_alpha_exp_divisor",
 		.data		= &sctp_rto_alpha,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_RTO_BETA,
 		.procname	= "rto_beta_exp_divisor",
 		.data		= &sctp_rto_beta,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_ADDIP_ENABLE,
 		.procname	= "addip_enable",
 		.data		= &sctp_addip_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_PRSCTP_ENABLE,
 		.procname	= "prsctp_enable",
 		.data		= &sctp_prsctp_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= NET_SCTP_SACK_TIMEOUT,
 		.procname	= "sack_timeout",
 		.data		= &sctp_sack_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_minmax,
-		.strategy	= sysctl_intvec,
 		.extra1         = &sack_timer_min,
 		.extra2         = &sack_timer_max,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "sctp_mem",
 		.data		= &sysctl_sctp_mem,
 		.maxlen		= sizeof(sysctl_sctp_mem),
@@ -240,7 +205,6 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "sctp_rmem",
 		.data		= &sysctl_sctp_rmem,
 		.maxlen		= sizeof(sysctl_sctp_rmem),
@@ -248,7 +212,6 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "sctp_wmem",
 		.data		= &sysctl_sctp_wmem,
 		.maxlen		= sizeof(sysctl_sctp_wmem),
@@ -256,40 +219,34 @@ static ctl_table sctp_table[] = {
 		.proc_handler	= proc_dointvec,
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "auth_enable",
 		.data		= &sctp_auth_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "addip_noauth_enable",
 		.data		= &sctp_addip_noauth,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
-		.strategy	= sysctl_intvec
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "addr_scope_policy",
 		.data		= &sctp_scope_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 		.extra2		= &addr_scope_max,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path sctp_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "sctp", .ctl_name = NET_SCTP, },
+	{ .procname = "net", },
+	{ .procname = "sctp", },
 	{ }
 };
 
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index 42f9748..f0ce326 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -168,17 +168,16 @@ static ctl_table debug_table[] = {
 		.mode		= 0444,
 		.proc_handler	= &proc_do_xprt,
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static ctl_table sunrpc_table[] = {
 	{
-		.ctl_name	= CTL_SUNRPC,
 		.procname	= "sunrpc",
 		.mode		= 0555,
 		.child		= debug_table
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 #endif
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 35fb68b..678cee2 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -121,7 +121,6 @@ static ctl_table svcrdma_parm_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_max_requests,
 		.extra2		= &max_max_requests
 	},
@@ -131,7 +130,6 @@ static ctl_table svcrdma_parm_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_max_inline,
 		.extra2		= &max_max_inline
 	},
@@ -141,7 +139,6 @@ static ctl_table svcrdma_parm_table[] = {
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_ord,
 		.extra2		= &max_ord,
 	},
@@ -209,9 +206,7 @@ static ctl_table svcrdma_parm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &read_reset_stat,
 	},
-	{
-		.ctl_name = 0,
-	},
+	{ },
 };
 
 static ctl_table svcrdma_table[] = {
@@ -220,21 +215,16 @@ static ctl_table svcrdma_table[] = {
 		.mode		= 0555,
 		.child		= svcrdma_parm_table
 	},
-	{
-		.ctl_name = 0,
-	},
+	{ },
 };
 
 static ctl_table svcrdma_root_table[] = {
 	{
-		.ctl_name	= CTL_SUNRPC,
 		.procname	= "sunrpc",
 		.mode		= 0555,
 		.child		= svcrdma_table
 	},
-	{
-		.ctl_name = 0,
-	},
+	{ },
 };
 
 void svc_rdma_cleanup(void)
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 9a63f66..4768160 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -86,79 +86,63 @@ static struct ctl_table_header *sunrpc_table_header;
 
 static ctl_table xr_tunables_table[] = {
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_slot_table_entries",
 		.data		= &xprt_rdma_slot_table_entries,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_slot_table_size,
 		.extra2		= &max_slot_table_size
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_max_inline_read",
 		.data		= &xprt_rdma_max_inline_read,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_max_inline_write",
 		.data		= &xprt_rdma_max_inline_write,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_inline_write_padding",
 		.data		= &xprt_rdma_inline_write_padding,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 		.extra2		= &max_padding,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_memreg_strategy",
 		.data		= &xprt_rdma_memreg_strategy,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_memreg,
 		.extra2		= &max_memreg,
 	},
 	{
-		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_pad_optimize",
 		.data		= &xprt_rdma_pad_optimize,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec,
 	},
-	{
-		.ctl_name = 0,
-	},
+	{ },
 };
 
 static ctl_table sunrpc_table[] = {
 	{
-		.ctl_name	= CTL_SUNRPC,
 		.procname	= "sunrpc",
 		.mode		= 0555,
 		.child		= xr_tunables_table
 	},
-	{
-		.ctl_name = 0,
-	},
+	{ },
 };
 
 #endif
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37c5475..8b9a207 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -81,46 +81,38 @@ static struct ctl_table_header *sunrpc_table_header;
  */
 static ctl_table xs_tunables_table[] = {
 	{
-		.ctl_name	= CTL_SLOTTABLE_UDP,
 		.procname	= "udp_slot_table_entries",
 		.data		= &xprt_udp_slot_table_entries,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_slot_table_size,
 		.extra2		= &max_slot_table_size
 	},
 	{
-		.ctl_name	= CTL_SLOTTABLE_TCP,
 		.procname	= "tcp_slot_table_entries",
 		.data		= &xprt_tcp_slot_table_entries,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &min_slot_table_size,
 		.extra2		= &max_slot_table_size
 	},
 	{
-		.ctl_name	= CTL_MIN_RESVPORT,
 		.procname	= "min_resvport",
 		.data		= &xprt_min_resvport,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &xprt_min_resvport_limit,
 		.extra2		= &xprt_max_resvport_limit
 	},
 	{
-		.ctl_name	= CTL_MAX_RESVPORT,
 		.procname	= "max_resvport",
 		.data		= &xprt_max_resvport,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
 		.extra1		= &xprt_min_resvport_limit,
 		.extra2		= &xprt_max_resvport_limit
 	},
@@ -130,23 +122,17 @@ static ctl_table xs_tunables_table[] = {
 		.maxlen		= sizeof(xs_tcp_fin_timeout),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= sysctl_jiffies
-	},
-	{
-		.ctl_name = 0,
 	},
+	{ },
 };
 
 static ctl_table sunrpc_table[] = {
 	{
-		.ctl_name	= CTL_SUNRPC,
 		.procname	= "sunrpc",
 		.mode		= 0555,
 		.child		= xs_tunables_table
 	},
-	{
-		.ctl_name = 0,
-	},
+	{ },
 };
 
 #endif
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 83c0930..708f5df 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -16,19 +16,18 @@
 
 static ctl_table unix_table[] = {
 	{
-		.ctl_name	= NET_UNIX_MAX_DGRAM_QLEN,
 		.procname	= "max_dgram_qlen",
 		.data		= &init_net.unx.sysctl_max_dgram_qlen,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
-	{ .ctl_name = 0 }
+	{ }
 };
 
 static struct ctl_path unix_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "unix", .ctl_name = NET_UNIX, },
+	{ .procname = "net", },
+	{ .procname = "unix", },
 	{ },
 };
 
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index a5d3416..d2efd29 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -19,62 +19,51 @@ static struct ctl_table_header *x25_table_header;
 
 static struct ctl_table x25_table[] = {
 	{
-		.ctl_name =	NET_X25_RESTART_REQUEST_TIMEOUT,
 		.procname =	"restart_request_timeout",
 		.data =		&sysctl_x25_restart_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
 		.proc_handler =	proc_dointvec_minmax,
-		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
 	{
-		.ctl_name =	NET_X25_CALL_REQUEST_TIMEOUT,
 		.procname =	"call_request_timeout",
 		.data =		&sysctl_x25_call_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
 		.proc_handler =	proc_dointvec_minmax,
-		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
 	{
-		.ctl_name =	NET_X25_RESET_REQUEST_TIMEOUT,
 		.procname =	"reset_request_timeout",
 		.data =		&sysctl_x25_reset_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
 		.proc_handler =	proc_dointvec_minmax,
-		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
 	{
-		.ctl_name =	NET_X25_CLEAR_REQUEST_TIMEOUT,
 		.procname =	"clear_request_timeout",
 		.data =		&sysctl_x25_clear_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
 		.proc_handler =	proc_dointvec_minmax,
-		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
 	{
-		.ctl_name =	NET_X25_ACK_HOLD_BACK_TIMEOUT,
 		.procname =	"acknowledgement_hold_back_timeout",
 		.data =		&sysctl_x25_ack_holdback_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
 		.proc_handler =	proc_dointvec_minmax,
-		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
 	{
-		.ctl_name =	NET_X25_FORWARD,
 		.procname =	"x25_forward",
 		.data = 	&sysctl_x25_forward,
 		.maxlen = 	sizeof(int),
@@ -85,8 +74,8 @@ static struct ctl_table x25_table[] = {
 };
 
 static struct ctl_path x25_path[] = {
-	{ .procname = "net", .ctl_name = CTL_NET, },
-	{ .procname = "x25", .ctl_name = NET_X25, },
+	{ .procname = "net", },
+	{ .procname = "x25", },
 	{ }
 };
 
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 2e6ffb6..2e221f2 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -13,28 +13,24 @@ static void __xfrm_sysctl_init(struct net *net)
 #ifdef CONFIG_SYSCTL
 static struct ctl_table xfrm_table[] = {
 	{
-		.ctl_name	= NET_CORE_AEVENT_ETIME,
 		.procname	= "xfrm_aevent_etime",
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= NET_CORE_AEVENT_RSEQTH,
 		.procname	= "xfrm_aevent_rseqth",
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "xfrm_larval_drop",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "xfrm_acq_expires",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-- 
1.6.5.2.143.g8cc62

