From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: '&' redux
Date: Tue, 4 Nov 2008 05:22:00 +0300
Message-ID: <20081104022200.GA15822@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:17650 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353AbYKDCSp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 21:18:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I want to compile out proc_* and sysctl_* handlers totally and
stub them to NULL depending on config options, however usage of &
will prevent this, since taking adress of NULL pointer will break
compilation.

So, drop & in front of every ->proc_handler and every ->strategy
handler, it was never needed in fact.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/802/tr.c                                   |    2 
 net/appletalk/sysctl_net_atalk.c               |   14 -
 net/ax25/sysctl_net_ax25.c                     |   56 +++----
 net/bridge/br_netfilter.c                      |   10 -
 net/core/neighbour.c                           |   48 +++---
 net/core/sysctl_net_core.c                     |   34 ++--
 net/decnet/sysctl_net_decnet.c                 |   44 +++---
 net/ipv4/ip_fragment.c                         |   14 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   12 -
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    4 
 net/ipv4/route.c                               |   48 +++---
 net/ipv4/sysctl_net_ipv4.c                     |  178 ++++++++++++-------------
 net/ipv6/addrconf.c                            |   62 ++++----
 net/ipv6/icmp.c                                |    4 
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 
 net/ipv6/netfilter/nf_conntrack_reasm.c        |    6 
 net/ipv6/reassembly.c                          |   12 -
 net/ipv6/route.c                               |   34 ++--
 net/ipv6/sysctl_net_ipv6.c                     |    4 
 net/ipx/sysctl_net_ipx.c                       |    2 
 net/irda/irsysctl.c                            |   50 +++----
 net/llc/sysctl_net_llc.c                       |   20 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |   46 +++---
 net/netfilter/ipvs/ip_vs_lblc.c                |    2 
 net/netfilter/ipvs/ip_vs_lblcr.c               |    2 
 net/netfilter/nf_conntrack_acct.c              |    2 
 net/netfilter/nf_conntrack_proto_generic.c     |    4 
 net/netfilter/nf_conntrack_proto_sctp.c        |   28 +--
 net/netfilter/nf_conntrack_proto_tcp.c         |   50 +++----
 net/netfilter/nf_conntrack_proto_udp.c         |    8 -
 net/netfilter/nf_conntrack_proto_udplite.c     |    4 
 net/netfilter/nf_conntrack_standalone.c        |   16 +-
 net/netrom/sysctl_net_netrom.c                 |   48 +++---
 net/phonet/sysctl.c                            |    2 
 net/rose/sysctl_net_rose.c                     |   40 ++---
 net/sctp/sysctl.c                              |   82 +++++------
 net/unix/sysctl_net_unix.c                     |    2 
 net/x25/sysctl_net_x25.c                       |   22 +--
 38 files changed, 509 insertions(+), 509 deletions(-)

--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -635,7 +635,7 @@ static struct ctl_table tr_table[] = {
 		.data		= &sysctl_tr_rif_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ 0 },
 };
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -17,8 +17,8 @@ static struct ctl_table atalk_table[] = {
 		.data		= &sysctl_aarp_expiry_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_ATALK_AARP_TICK_TIME,
@@ -26,8 +26,8 @@ static struct ctl_table atalk_table[] = {
 		.data		= &sysctl_aarp_tick_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_ATALK_AARP_RETRANSMIT_LIMIT,
@@ -35,7 +35,7 @@ static struct ctl_table atalk_table[] = {
 		.data		= &sysctl_aarp_retransmit_limit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_ATALK_AARP_RESOLVE_TIME,
@@ -43,8 +43,8 @@ static struct ctl_table atalk_table[] = {
 		.data		= &sysctl_aarp_resolve_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{ 0 },
 };
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -43,8 +43,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "ip_default_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_ipdefmode,
 		.extra2		= &max_ipdefmode
 	},
@@ -53,8 +53,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "ax25_default_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_axdefmode,
 		.extra2		= &max_axdefmode
 	},
@@ -63,8 +63,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "backoff_type",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_backoff,
 		.extra2		= &max_backoff
 	},
@@ -73,8 +73,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "connect_mode",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_conmode,
 		.extra2		= &max_conmode
 	},
@@ -83,8 +83,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "standard_window_size",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_window,
 		.extra2		= &max_window
 	},
@@ -93,8 +93,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "extended_window_size",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_ewindow,
 		.extra2		= &max_ewindow
 	},
@@ -103,8 +103,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "t1_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_t1,
 		.extra2		= &max_t1
 	},
@@ -113,8 +113,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "t2_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_t2,
 		.extra2		= &max_t2
 	},
@@ -123,8 +123,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "t3_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_t3,
 		.extra2		= &max_t3
 	},
@@ -133,8 +133,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "idle_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_idle,
 		.extra2		= &max_idle
 	},
@@ -143,8 +143,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "maximum_retry_count",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_n2,
 		.extra2		= &max_n2
 	},
@@ -153,8 +153,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "maximum_packet_length",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_paclen,
 		.extra2		= &max_paclen
 	},
@@ -163,8 +163,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "protocol",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_proto,
 		.extra2		= &max_proto
 	},
@@ -174,8 +174,8 @@ static const ctl_table ax25_param_table[] = {
 		.procname	= "dama_slave_timeout",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_ds_timeout,
 		.extra2		= &max_ds_timeout
 	},
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -938,35 +938,35 @@ static ctl_table brnf_table[] = {
 		.data		= &brnf_call_arptables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &brnf_sysctl_call_tables,
+		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-call-iptables",
 		.data		= &brnf_call_iptables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &brnf_sysctl_call_tables,
+		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-call-ip6tables",
 		.data		= &brnf_call_ip6tables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &brnf_sysctl_call_tables,
+		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-filter-vlan-tagged",
 		.data		= &brnf_filter_vlan_tagged,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &brnf_sysctl_call_tables,
+		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{
 		.procname	= "bridge-nf-filter-pppoe-tagged",
 		.data		= &brnf_filter_pppoe_tagged,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &brnf_sysctl_call_tables,
+		.proc_handler	= brnf_sysctl_call_tables,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2566,128 +2566,128 @@ static struct neigh_sysctl_table {
 			.procname	= "mcast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.ctl_name	= NET_NEIGH_UCAST_SOLICIT,
 			.procname	= "ucast_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.ctl_name	= NET_NEIGH_APP_SOLICIT,
 			.procname	= "app_solicit",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.procname	= "retrans_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_userhz_jiffies,
+			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_REACHABLE_TIME,
 			.procname	= "base_reachable_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_jiffies,
-			.strategy	= &sysctl_jiffies,
+			.proc_handler	= proc_dointvec_jiffies,
+			.strategy	= sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_DELAY_PROBE_TIME,
 			.procname	= "delay_first_probe_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_jiffies,
-			.strategy	= &sysctl_jiffies,
+			.proc_handler	= proc_dointvec_jiffies,
+			.strategy	= sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_STALE_TIME,
 			.procname	= "gc_stale_time",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_jiffies,
-			.strategy	= &sysctl_jiffies,
+			.proc_handler	= proc_dointvec_jiffies,
+			.strategy	= sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_UNRES_QLEN,
 			.procname	= "unres_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.ctl_name	= NET_NEIGH_PROXY_QLEN,
 			.procname	= "proxy_qlen",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.procname	= "anycast_delay",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_userhz_jiffies,
+			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
 		{
 			.procname	= "proxy_delay",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_userhz_jiffies,
+			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
 		{
 			.procname	= "locktime",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_userhz_jiffies,
+			.proc_handler	= proc_dointvec_userhz_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_RETRANS_TIME_MS,
 			.procname	= "retrans_time_ms",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_ms_jiffies,
-			.strategy	= &sysctl_ms_jiffies,
+			.proc_handler	= proc_dointvec_ms_jiffies,
+			.strategy	= sysctl_ms_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_REACHABLE_TIME_MS,
 			.procname	= "base_reachable_time_ms",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_ms_jiffies,
-			.strategy	= &sysctl_ms_jiffies,
+			.proc_handler	= proc_dointvec_ms_jiffies,
+			.strategy	= sysctl_ms_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_INTERVAL,
 			.procname	= "gc_interval",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec_jiffies,
-			.strategy	= &sysctl_jiffies,
+			.proc_handler	= proc_dointvec_jiffies,
+			.strategy	= sysctl_jiffies,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_THRESH1,
 			.procname	= "gc_thresh1",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_THRESH2,
 			.procname	= "gc_thresh2",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{
 			.ctl_name	= NET_NEIGH_GC_THRESH3,
 			.procname	= "gc_thresh3",
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= &proc_dointvec,
+			.proc_handler	= proc_dointvec,
 		},
 		{},
 	},
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -22,7 +22,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_wmem_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_RMEM_MAX,
@@ -30,7 +30,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_rmem_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_WMEM_DEFAULT,
@@ -38,7 +38,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_wmem_default,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_RMEM_DEFAULT,
@@ -46,7 +46,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_rmem_default,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_DEV_WEIGHT,
@@ -54,7 +54,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &weight_p,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_MAX_BACKLOG,
@@ -62,7 +62,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &netdev_max_backlog,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_MSG_COST,
@@ -70,8 +70,8 @@ static struct ctl_table net_core_table[] = {
 		.data		= &net_ratelimit_state.interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_CORE_MSG_BURST,
@@ -79,7 +79,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &net_ratelimit_state.burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_CORE_OPTMEM_MAX,
@@ -87,7 +87,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_optmem_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #ifdef CONFIG_XFRM
 	{
@@ -96,7 +96,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_xfrm_aevent_etime,
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_AEVENT_RSEQTH,
@@ -104,7 +104,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_xfrm_aevent_rseqth,
 		.maxlen		= sizeof(u32),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -112,7 +112,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_xfrm_larval_drop,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -120,7 +120,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &sysctl_xfrm_acq_expires,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #endif /* CONFIG_XFRM */
 #endif /* CONFIG_NET */
@@ -130,7 +130,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &netdev_budget,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_CORE_WARNINGS,
@@ -138,7 +138,7 @@ static struct ctl_table net_core_table[] = {
 		.data		= &net_msg_warn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ .ctl_name = 0 }
 };
@@ -150,7 +150,7 @@ static struct ctl_table netns_core_table[] = {
 		.data		= &init_net.core.sysctl_somaxconn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -354,8 +354,8 @@ static ctl_table dn_table[] = {
 		.data = node_name,
 		.maxlen = 7,
 		.mode = 0644,
-		.proc_handler = &proc_dostring,
-		.strategy = &sysctl_string,
+		.proc_handler = proc_dostring,
+		.strategy = sysctl_string,
 	},
 	{
 		.ctl_name = NET_DECNET_DEFAULT_DEVICE,
@@ -371,8 +371,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_time_wait,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_minmax,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec_minmax,
+		.strategy = sysctl_intvec,
 		.extra1 = &min_decnet_time_wait,
 		.extra2 = &max_decnet_time_wait
 	},
@@ -382,8 +382,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_dn_count,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_minmax,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec_minmax,
+		.strategy = sysctl_intvec,
 		.extra1 = &min_state_count,
 		.extra2 = &max_state_count
 	},
@@ -393,8 +393,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_di_count,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_minmax,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec_minmax,
+		.strategy = sysctl_intvec,
 		.extra1 = &min_state_count,
 		.extra2 = &max_state_count
 	},
@@ -404,8 +404,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_dr_count,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_minmax,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec_minmax,
+		.strategy = sysctl_intvec,
 		.extra1 = &min_state_count,
 		.extra2 = &max_state_count
 	},
@@ -415,8 +415,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_dst_gc_interval,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_minmax,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec_minmax,
+		.strategy = sysctl_intvec,
 		.extra1 = &min_decnet_dst_gc_interval,
 		.extra2 = &max_decnet_dst_gc_interval
 	},
@@ -426,8 +426,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_no_fc_max_cwnd,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec_minmax,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec_minmax,
+		.strategy = sysctl_intvec,
 		.extra1 = &min_decnet_no_fc_max_cwnd,
 		.extra2 = &max_decnet_no_fc_max_cwnd
 	},
@@ -437,8 +437,8 @@ static ctl_table dn_table[] = {
 		.data = &sysctl_decnet_mem,
 		.maxlen = sizeof(sysctl_decnet_mem),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec,
+		.strategy = sysctl_intvec,
 	},
 	{
 		.ctl_name = NET_DECNET_RMEM,
@@ -446,8 +446,8 @@ static ctl_table dn_table[] = {
 		.data = &sysctl_decnet_rmem,
 		.maxlen = sizeof(sysctl_decnet_rmem),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec,
+		.strategy = sysctl_intvec,
 	},
 	{
 		.ctl_name = NET_DECNET_WMEM,
@@ -455,8 +455,8 @@ static ctl_table dn_table[] = {
 		.data = &sysctl_decnet_wmem,
 		.maxlen = sizeof(sysctl_decnet_wmem),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec,
+		.strategy = sysctl_intvec,
 	},
 	{
 		.ctl_name = NET_DECNET_DEBUG_LEVEL,
@@ -464,8 +464,8 @@ static ctl_table dn_table[] = {
 		.data = &decnet_debug_level,
 		.maxlen = sizeof(int),
 		.mode = 0644,
-		.proc_handler = &proc_dointvec,
-		.strategy = &sysctl_intvec,
+		.proc_handler = proc_dointvec,
+		.strategy = sysctl_intvec,
 	},
 	{0}
 };
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -607,7 +607,7 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_LOW_THRESH,
@@ -615,7 +615,7 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_IPFRAG_TIME,
@@ -623,8 +623,8 @@ static struct ctl_table ip4_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv4.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{ }
 };
@@ -636,15 +636,15 @@ static struct ctl_table ip4_frags_ctl_table[] = {
 		.data		= &ip4_frags.secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.procname	= "ipfrag_max_dist",
 		.data		= &sysctl_ipfrag_max_dist,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
+		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &zero
 	},
 	{ }
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -197,7 +197,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_COUNT,
@@ -205,7 +205,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_BUCKETS,
@@ -213,7 +213,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.data		= &nf_conntrack_htable_size,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_CHECKSUM,
@@ -221,7 +221,7 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_LOG_INVALID,
@@ -229,8 +229,8 @@ static ctl_table ip_ct_sysctl_table[] = {
 		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &log_invalid_proto_min,
 		.extra2		= &log_invalid_proto_max,
 	},
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -272,7 +272,7 @@ static struct ctl_table icmp_sysctl_table[] = {
 		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name = 0
@@ -285,7 +285,7 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name = 0
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3118,7 +3118,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ipv4_dst_ops.gc_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_MAX_SIZE,
@@ -3126,7 +3126,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		/*  Deprecated. Use gc_min_interval_ms */
@@ -3136,8 +3136,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_gc_min_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_MIN_INTERVAL_MS,
@@ -3145,8 +3145,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_gc_min_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_ms_jiffies,
-		.strategy	= &sysctl_ms_jiffies,
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.strategy	= sysctl_ms_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_TIMEOUT,
@@ -3154,8 +3154,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_gc_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_INTERVAL,
@@ -3163,8 +3163,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_gc_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_LOAD,
@@ -3172,7 +3172,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_redirect_load,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_NUMBER,
@@ -3180,7 +3180,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_redirect_number,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_REDIRECT_SILENCE,
@@ -3188,7 +3188,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_redirect_silence,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_ERROR_COST,
@@ -3196,7 +3196,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_error_cost,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_ERROR_BURST,
@@ -3204,7 +3204,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_error_burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_GC_ELASTICITY,
@@ -3212,7 +3212,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_gc_elasticity,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_MTU_EXPIRES,
@@ -3220,8 +3220,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_mtu_expires,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_MIN_PMTU,
@@ -3229,7 +3229,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_min_pmtu,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_MIN_ADVMSS,
@@ -3237,7 +3237,7 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_min_advmss,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_ROUTE_SECRET_INTERVAL,
@@ -3245,8 +3245,8 @@ static ctl_table ipv4_route_table[] = {
 		.data		= &ip_rt_secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &ipv4_sysctl_rt_secret_interval,
-		.strategy	= &ipv4_sysctl_rt_secret_interval_strategy,
+		.proc_handler	= ipv4_sysctl_rt_secret_interval,
+		.strategy	= ipv4_sysctl_rt_secret_interval_strategy,
 	},
 	{ .ctl_name = 0 }
 };
@@ -3274,8 +3274,8 @@ static struct ctl_table ipv4_route_flush_table[] = {
 		.procname	= "flush",
 		.maxlen		= sizeof(int),
 		.mode		= 0200,
-		.proc_handler	= &ipv4_sysctl_rtcache_flush,
-		.strategy	= &ipv4_sysctl_rtcache_flush_strategy,
+		.proc_handler	= ipv4_sysctl_rtcache_flush,
+		.strategy	= ipv4_sysctl_rtcache_flush_strategy,
 	},
 	{ .ctl_name = 0 },
 };
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -195,7 +195,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_timestamps,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_WINDOW_SCALING,
@@ -203,7 +203,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_window_scaling,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_SACK,
@@ -211,7 +211,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_sack,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_RETRANS_COLLAPSE,
@@ -219,7 +219,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_retrans_collapse,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_DEFAULT_TTL,
@@ -227,8 +227,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_ip_default_ttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &ipv4_doint_and_flush,
-		.strategy	= &ipv4_doint_and_flush_strategy,
+		.proc_handler	= ipv4_doint_and_flush,
+		.strategy	= ipv4_doint_and_flush_strategy,
 		.extra2		= &init_net,
 	},
 	{
@@ -237,7 +237,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &ipv4_config.no_pmtu_disc,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_NONLOCAL_BIND,
@@ -245,7 +245,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_ip_nonlocal_bind,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_SYN_RETRIES,
@@ -253,7 +253,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_syn_retries,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_SYNACK_RETRIES,
@@ -261,7 +261,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_synack_retries,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_MAX_ORPHANS,
@@ -269,7 +269,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_max_orphans,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_MAX_TW_BUCKETS,
@@ -277,7 +277,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &tcp_death_row.sysctl_max_tw_buckets,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_DYNADDR,
@@ -285,7 +285,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_ip_dynaddr,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_TIME,
@@ -293,8 +293,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_keepalive_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_PROBES,
@@ -302,7 +302,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_keepalive_probes,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_KEEPALIVE_INTVL,
@@ -310,8 +310,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_keepalive_intvl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_RETRIES1,
@@ -319,8 +319,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_retries1,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra2		= &tcp_retr1_max
 	},
 	{
@@ -329,7 +329,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_retries2,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_FIN_TIMEOUT,
@@ -337,8 +337,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_fin_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 #ifdef CONFIG_SYN_COOKIES
 	{
@@ -347,7 +347,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_syncookies,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #endif
 	{
@@ -356,7 +356,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &tcp_death_row.sysctl_tw_recycle,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_ABORT_ON_OVERFLOW,
@@ -364,7 +364,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_abort_on_overflow,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_STDURG,
@@ -372,7 +372,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_stdurg,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_RFC1337,
@@ -380,7 +380,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_rfc1337,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_MAX_SYN_BACKLOG,
@@ -388,7 +388,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_max_syn_backlog,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_LOCAL_PORT_RANGE,
@@ -396,8 +396,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_local_ports.range,
 		.maxlen		= sizeof(sysctl_local_ports.range),
 		.mode		= 0644,
-		.proc_handler	= &ipv4_local_port_range,
-		.strategy	= &ipv4_sysctl_local_port_range,
+		.proc_handler	= ipv4_local_port_range,
+		.strategy	= ipv4_sysctl_local_port_range,
 	},
 #ifdef CONFIG_IP_MULTICAST
 	{
@@ -406,7 +406,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_igmp_max_memberships,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 
 #endif
@@ -416,7 +416,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_igmp_max_msf,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_THRESHOLD,
@@ -424,7 +424,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &inet_peer_threshold,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_MINTTL,
@@ -432,8 +432,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &inet_peer_minttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_MAXTTL,
@@ -441,8 +441,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &inet_peer_maxttl,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_GC_MINTIME,
@@ -450,8 +450,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &inet_peer_gc_mintime,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_INET_PEER_GC_MAXTIME,
@@ -459,8 +459,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &inet_peer_gc_maxtime,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{
 		.ctl_name	= NET_TCP_ORPHAN_RETRIES,
@@ -468,7 +468,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_orphan_retries,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_FACK,
@@ -476,7 +476,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_fack,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_REORDERING,
@@ -484,7 +484,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_reordering,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_ECN,
@@ -492,7 +492,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_ecn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_DSACK,
@@ -500,7 +500,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_dsack,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_MEM,
@@ -508,7 +508,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_mem,
 		.maxlen		= sizeof(sysctl_tcp_mem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_WMEM,
@@ -516,7 +516,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_wmem,
 		.maxlen		= sizeof(sysctl_tcp_wmem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_RMEM,
@@ -524,7 +524,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_rmem,
 		.maxlen		= sizeof(sysctl_tcp_rmem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_APP_WIN,
@@ -532,7 +532,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_app_win,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_ADV_WIN_SCALE,
@@ -540,7 +540,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_adv_win_scale,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_TW_REUSE,
@@ -548,7 +548,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_tw_reuse,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_FRTO,
@@ -556,7 +556,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_frto,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_FRTO_RESPONSE,
@@ -564,7 +564,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_frto_response,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_LOW_LATENCY,
@@ -572,7 +572,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_low_latency,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_TCP_NO_METRICS_SAVE,
@@ -580,7 +580,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_nometrics_save,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_TCP_MODERATE_RCVBUF,
@@ -588,7 +588,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_moderate_rcvbuf,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_TCP_TSO_WIN_DIVISOR,
@@ -596,15 +596,15 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_tso_win_divisor,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_TCP_CONG_CONTROL,
 		.procname	= "tcp_congestion_control",
 		.mode		= 0644,
 		.maxlen		= TCP_CA_NAME_MAX,
-		.proc_handler	= &proc_tcp_congestion_control,
-		.strategy	= &sysctl_tcp_congestion_control,
+		.proc_handler	= proc_tcp_congestion_control,
+		.strategy	= sysctl_tcp_congestion_control,
 	},
 	{
 		.ctl_name	= NET_TCP_ABC,
@@ -612,7 +612,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_abc,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_TCP_MTU_PROBING,
@@ -620,7 +620,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_mtu_probing,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_TCP_BASE_MSS,
@@ -628,7 +628,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_base_mss,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_TCP_WORKAROUND_SIGNED_WINDOWS,
@@ -636,7 +636,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_workaround_signed_windows,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #ifdef CONFIG_NET_DMA
 	{
@@ -645,7 +645,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_dma_copybreak,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #endif
 	{
@@ -654,7 +654,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_slow_start_after_idle,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #ifdef CONFIG_NETLABEL
 	{
@@ -663,7 +663,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &cipso_v4_cache_enabled,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_CIPSOV4_CACHE_BUCKET_SIZE,
@@ -671,7 +671,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &cipso_v4_cache_bucketsize,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_CIPSOV4_RBM_OPTFMT,
@@ -679,7 +679,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &cipso_v4_rbm_optfmt,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_CIPSOV4_RBM_STRICTVALID,
@@ -687,22 +687,22 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &cipso_v4_rbm_strictvalid,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 #endif /* CONFIG_NETLABEL */
 	{
 		.procname	= "tcp_available_congestion_control",
 		.maxlen		= TCP_CA_BUF_MAX,
 		.mode		= 0444,
-		.proc_handler   = &proc_tcp_available_congestion_control,
+		.proc_handler   = proc_tcp_available_congestion_control,
 	},
 	{
 		.ctl_name	= NET_TCP_ALLOWED_CONG_CONTROL,
 		.procname	= "tcp_allowed_congestion_control",
 		.maxlen		= TCP_CA_BUF_MAX,
 		.mode		= 0644,
-		.proc_handler   = &proc_allowed_congestion_control,
-		.strategy	= &strategy_allowed_congestion_control,
+		.proc_handler   = proc_allowed_congestion_control,
+		.strategy	= strategy_allowed_congestion_control,
 	},
 	{
 		.ctl_name	= NET_TCP_MAX_SSTHRESH,
@@ -710,7 +710,7 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_tcp_max_ssthresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -718,8 +718,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_udp_mem,
 		.maxlen		= sizeof(sysctl_udp_mem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
 	{
@@ -728,8 +728,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_udp_rmem_min,
 		.maxlen		= sizeof(sysctl_udp_rmem_min),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
 	{
@@ -738,8 +738,8 @@ static struct ctl_table ipv4_table[] = {
 		.data		= &sysctl_udp_wmem_min,
 		.maxlen		= sizeof(sysctl_udp_wmem_min),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &zero
 	},
 	{ .ctl_name = 0 }
@@ -752,7 +752,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_all,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_ECHO_IGNORE_BROADCASTS,
@@ -760,7 +760,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_echo_ignore_broadcasts,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_IGNORE_BOGUS_ERROR_RESPONSES,
@@ -768,7 +768,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_ignore_bogus_error_responses,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_ERRORS_USE_INBOUND_IFADDR,
@@ -776,7 +776,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_errors_use_inbound_ifaddr,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_RATELIMIT,
@@ -784,8 +784,8 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_ratelimit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_ms_jiffies,
-		.strategy	= &sysctl_ms_jiffies
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.strategy	= sysctl_ms_jiffies
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_RATEMASK,
@@ -793,7 +793,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_icmp_ratemask,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -801,7 +801,7 @@ static struct ctl_table ipv4_net_table[] = {
 		.data		= &init_net.ipv4.sysctl_rt_cache_rebuild_count,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ }
 };
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4030,8 +4030,8 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.forwarding,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&addrconf_sysctl_forward,
-			.strategy	=	&addrconf_sysctl_forward_strategy,
+			.proc_handler	=	addrconf_sysctl_forward,
+			.strategy	=	addrconf_sysctl_forward_strategy,
 		},
 		{
 			.ctl_name	=	NET_IPV6_HOP_LIMIT,
@@ -4047,7 +4047,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.mtu6,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_ACCEPT_RA,
@@ -4055,7 +4055,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_ra,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_ACCEPT_REDIRECTS,
@@ -4063,7 +4063,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_redirects,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_AUTOCONF,
@@ -4071,7 +4071,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.autoconf,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_DAD_TRANSMITS,
@@ -4079,7 +4079,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.dad_transmits,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_RTR_SOLICITS,
@@ -4087,7 +4087,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.rtr_solicits,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_RTR_SOLICIT_INTERVAL,
@@ -4095,8 +4095,8 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.rtr_solicit_interval,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec_jiffies,
-			.strategy	=	&sysctl_jiffies,
+			.proc_handler	=	proc_dointvec_jiffies,
+			.strategy	=	sysctl_jiffies,
 		},
 		{
 			.ctl_name	=	NET_IPV6_RTR_SOLICIT_DELAY,
@@ -4104,8 +4104,8 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.rtr_solicit_delay,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec_jiffies,
-			.strategy	=	&sysctl_jiffies,
+			.proc_handler	=	proc_dointvec_jiffies,
+			.strategy	=	sysctl_jiffies,
 		},
 		{
 			.ctl_name	=	NET_IPV6_FORCE_MLD_VERSION,
@@ -4113,7 +4113,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.force_mld_version,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_PRIVACY
 		{
@@ -4122,7 +4122,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.use_tempaddr,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_TEMP_VALID_LFT,
@@ -4130,7 +4130,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.temp_valid_lft,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_TEMP_PREFERED_LFT,
@@ -4138,7 +4138,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.temp_prefered_lft,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_REGEN_MAX_RETRY,
@@ -4146,7 +4146,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.regen_max_retry,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_MAX_DESYNC_FACTOR,
@@ -4154,7 +4154,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.max_desync_factor,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 #endif
 		{
@@ -4163,7 +4163,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.max_addresses,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_ACCEPT_RA_DEFRTR,
@@ -4171,7 +4171,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_ra_defrtr,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_ACCEPT_RA_PINFO,
@@ -4179,7 +4179,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_ra_pinfo,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		{
@@ -4188,7 +4188,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_ra_rtr_pref,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_RTR_PROBE_INTERVAL,
@@ -4196,8 +4196,8 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.rtr_probe_interval,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec_jiffies,
-			.strategy	=	&sysctl_jiffies,
+			.proc_handler	=	proc_dointvec_jiffies,
+			.strategy	=	sysctl_jiffies,
 		},
 #ifdef CONFIG_IPV6_ROUTE_INFO
 		{
@@ -4206,7 +4206,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_ra_rt_info_max_plen,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 #endif
 #endif
@@ -4216,7 +4216,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.proxy_ndp,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	NET_IPV6_ACCEPT_SOURCE_ROUTE,
@@ -4224,7 +4224,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_source_route,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
@@ -4233,7 +4233,7 @@ static struct addrconf_sysctl_table
 			.data           =       &ipv6_devconf.optimistic_dad,
 			.maxlen         =       sizeof(int),
 			.mode           =       0644,
-			.proc_handler   =       &proc_dointvec,
+			.proc_handler   =       proc_dointvec,
 
 		},
 #endif
@@ -4244,7 +4244,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.mc_forwarding,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 #endif
 		{
@@ -4253,7 +4253,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.disable_ipv6,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	CTL_UNNUMBERED,
@@ -4261,7 +4261,7 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.accept_dad,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	&proc_dointvec,
+			.proc_handler	=	proc_dointvec,
 		},
 		{
 			.ctl_name	=	0,	/* sentinel */
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -956,8 +956,8 @@ ctl_table ipv6_icmp_table_template[] = {
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_ms_jiffies,
-		.strategy	= &sysctl_ms_jiffies
+		.proc_handler	= proc_dointvec_ms_jiffies,
+		.strategy	= sysctl_ms_jiffies
 	},
 	{ .ctl_name = 0 },
 };
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -253,7 +253,7 @@ static struct ctl_table icmpv6_sysctl_table[] = {
 		.data		= &nf_ct_icmpv6_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= 0
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -80,7 +80,7 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 		.data		= &nf_init_frags.timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_FRAG6_LOW_THRESH,
@@ -88,7 +88,7 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 		.data		= &nf_init_frags.low_thresh,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_FRAG6_HIGH_THRESH,
@@ -96,7 +96,7 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
 		.data		= &nf_init_frags.high_thresh,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -642,7 +642,7 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv6.frags.high_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_LOW_THRESH,
@@ -650,7 +650,7 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv6.frags.low_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IPV6_IP6FRAG_TIME,
@@ -658,8 +658,8 @@ static struct ctl_table ip6_frags_ns_ctl_table[] = {
 		.data		= &init_net.ipv6.frags.timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies,
 	},
 	{ }
 };
@@ -671,8 +671,8 @@ static struct ctl_table ip6_frags_ctl_table[] = {
 		.data		= &ip6_frags.secret_interval,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
-		.strategy	= &sysctl_jiffies
+		.proc_handler	= proc_dointvec_jiffies,
+		.strategy	= sysctl_jiffies
 	},
 	{ }
 };
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2499,7 +2499,7 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.flush_delay,
 		.maxlen		=	sizeof(int),
 		.mode		=	0200,
-		.proc_handler	=	&ipv6_sysctl_rtcache_flush
+		.proc_handler	=	ipv6_sysctl_rtcache_flush
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_THRESH,
@@ -2507,7 +2507,7 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&ip6_dst_ops_template.gc_thresh,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+		.proc_handler	=	proc_dointvec,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MAX_SIZE,
@@ -2515,7 +2515,7 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_max_size,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec,
+		.proc_handler	=	proc_dointvec,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL,
@@ -2523,8 +2523,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_jiffies,
-		.strategy	=	&sysctl_jiffies,
+		.proc_handler	=	proc_dointvec_jiffies,
+		.strategy	=	sysctl_jiffies,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_TIMEOUT,
@@ -2532,8 +2532,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_timeout,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_jiffies,
-		.strategy	=	&sysctl_jiffies,
+		.proc_handler	=	proc_dointvec_jiffies,
+		.strategy	=	sysctl_jiffies,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_INTERVAL,
@@ -2541,8 +2541,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_jiffies,
-		.strategy	=	&sysctl_jiffies,
+		.proc_handler	=	proc_dointvec_jiffies,
+		.strategy	=	sysctl_jiffies,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_ELASTICITY,
@@ -2550,8 +2550,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_elasticity,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_jiffies,
-		.strategy	=	&sysctl_jiffies,
+		.proc_handler	=	proc_dointvec_jiffies,
+		.strategy	=	sysctl_jiffies,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MTU_EXPIRES,
@@ -2559,8 +2559,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_mtu_expires,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_jiffies,
-		.strategy	=	&sysctl_jiffies,
+		.proc_handler	=	proc_dointvec_jiffies,
+		.strategy	=	sysctl_jiffies,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_MIN_ADVMSS,
@@ -2568,8 +2568,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_min_advmss,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_jiffies,
-		.strategy	=	&sysctl_jiffies,
+		.proc_handler	=	proc_dointvec_jiffies,
+		.strategy	=	sysctl_jiffies,
 	},
 	{
 		.ctl_name	=	NET_IPV6_ROUTE_GC_MIN_INTERVAL_MS,
@@ -2577,8 +2577,8 @@ ctl_table ipv6_route_table_template[] = {
 		.data		=	&init_net.ipv6.sysctl.ip6_rt_gc_min_interval,
 		.maxlen		=	sizeof(int),
 		.mode		=	0644,
-		.proc_handler	=	&proc_dointvec_ms_jiffies,
-		.strategy	=	&sysctl_ms_jiffies,
+		.proc_handler	=	proc_dointvec_ms_jiffies,
+		.strategy	=	sysctl_ms_jiffies,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -35,7 +35,7 @@ static ctl_table ipv6_table_template[] = {
 		.data		= &init_net.ipv6.sysctl.bindv6only,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ .ctl_name = 0 }
 };
@@ -47,7 +47,7 @@ static ctl_table ipv6_table[] = {
 		.data		= &sysctl_mld_max_msf,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -23,7 +23,7 @@ static struct ctl_table ipx_table[] = {
 		.data		= &sysctl_ipx_pprop_broadcasting,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{ 0 },
 };
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -118,8 +118,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_discovery,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &do_discovery,
-		.strategy       = &sysctl_intvec
+		.proc_handler	= do_discovery,
+		.strategy       = sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_IRDA_DEVNAME,
@@ -127,8 +127,8 @@ static ctl_table irda_table[] = {
 		.data		= sysctl_devname,
 		.maxlen		= 65,
 		.mode		= 0644,
-		.proc_handler	= &do_devname,
-		.strategy	= &sysctl_string
+		.proc_handler	= do_devname,
+		.strategy	= sysctl_string
 	},
 #ifdef CONFIG_IRDA_DEBUG
 	{
@@ -137,7 +137,7 @@ static ctl_table irda_table[] = {
 		.data		= &irda_debug,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #endif
 #ifdef CONFIG_IRDA_FAST_RR
@@ -147,7 +147,7 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_fast_poll_increase,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 #endif
 	{
@@ -156,8 +156,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_discovery_slots,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_discovery_slots,
 		.extra2		= &max_discovery_slots
 	},
@@ -167,7 +167,7 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_discovery_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{
 		.ctl_name	= NET_IRDA_SLOT_TIMEOUT,
@@ -175,8 +175,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_slot_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_slot_timeout,
 		.extra2		= &max_slot_timeout
 	},
@@ -186,8 +186,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_max_baud_rate,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_baud_rate,
 		.extra2		= &max_max_baud_rate
 	},
@@ -197,8 +197,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_min_tx_turn_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_min_tx_turn_time,
 		.extra2		= &max_min_tx_turn_time
 	},
@@ -208,8 +208,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_max_tx_data_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_tx_data_size,
 		.extra2		= &max_max_tx_data_size
 	},
@@ -219,8 +219,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_max_tx_window,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_tx_window,
 		.extra2		= &max_max_tx_window
 	},
@@ -230,8 +230,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_max_noreply_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_max_noreply_time,
 		.extra2		= &max_max_noreply_time
 	},
@@ -241,8 +241,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_warn_noreply_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_warn_noreply_time,
 		.extra2		= &max_warn_noreply_time
 	},
@@ -252,8 +252,8 @@ static ctl_table irda_table[] = {
 		.data		= &sysctl_lap_keepalive_time,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_lap_keepalive_time,
 		.extra2		= &max_lap_keepalive_time
 	},
--- a/net/llc/sysctl_net_llc.c
+++ b/net/llc/sysctl_net_llc.c
@@ -20,8 +20,8 @@ static struct ctl_table llc2_timeout_table[] = {
 		.data		= &sysctl_llc2_ack_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler   = &proc_dointvec_jiffies,
-		.strategy       = &sysctl_jiffies,
+		.proc_handler   = proc_dointvec_jiffies,
+		.strategy       = sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_LLC2_BUSY_TIMEOUT,
@@ -29,8 +29,8 @@ static struct ctl_table llc2_timeout_table[] = {
 		.data		= &sysctl_llc2_busy_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler   = &proc_dointvec_jiffies,
-		.strategy       = &sysctl_jiffies,
+		.proc_handler   = proc_dointvec_jiffies,
+		.strategy       = sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_LLC2_P_TIMEOUT,
@@ -38,8 +38,8 @@ static struct ctl_table llc2_timeout_table[] = {
 		.data		= &sysctl_llc2_p_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler   = &proc_dointvec_jiffies,
-		.strategy       = &sysctl_jiffies,
+		.proc_handler   = proc_dointvec_jiffies,
+		.strategy       = sysctl_jiffies,
 	},
 	{
 		.ctl_name	= NET_LLC2_REJ_TIMEOUT,
@@ -47,8 +47,8 @@ static struct ctl_table llc2_timeout_table[] = {
 		.data		= &sysctl_llc2_rej_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler   = &proc_dointvec_jiffies,
-		.strategy       = &sysctl_jiffies,
+		.proc_handler   = proc_dointvec_jiffies,
+		.strategy       = sysctl_jiffies,
 	},
 	{ 0 },
 };
@@ -60,8 +60,8 @@ static struct ctl_table llc_station_table[] = {
 		.data		= &sysctl_llc_station_ack_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler   = &proc_dointvec_jiffies,
-		.strategy       = &sysctl_jiffies,
+		.proc_handler   = proc_dointvec_jiffies,
+		.strategy       = sysctl_jiffies,
 	},
 	{ 0 },
 };
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1557,7 +1557,7 @@ static struct ctl_table vs_vars[] = {
 		.data		= &sysctl_ip_vs_amemthresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 #ifdef CONFIG_IP_VS_DEBUG
 	{
@@ -1565,7 +1565,7 @@ static struct ctl_table vs_vars[] = {
 		.data		= &sysctl_ip_vs_debug_level,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 #endif
 	{
@@ -1573,28 +1573,28 @@ static struct ctl_table vs_vars[] = {
 		.data		= &sysctl_ip_vs_am_droprate,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "drop_entry",
 		.data		= &sysctl_ip_vs_drop_entry,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_do_defense_mode,
+		.proc_handler	= proc_do_defense_mode,
 	},
 	{
 		.procname	= "drop_packet",
 		.data		= &sysctl_ip_vs_drop_packet,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_do_defense_mode,
+		.proc_handler	= proc_do_defense_mode,
 	},
 	{
 		.procname	= "secure_tcp",
 		.data		= &sysctl_ip_vs_secure_tcp,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_do_defense_mode,
+		.proc_handler	= proc_do_defense_mode,
 	},
 #if 0
 	{
@@ -1602,84 +1602,84 @@ static struct ctl_table vs_vars[] = {
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ESTABLISHED],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_synsent",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_SENT],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_synrecv",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYN_RECV],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_finwait",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_FIN_WAIT],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_timewait",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_TIME_WAIT],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_close",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_closewait",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_CLOSE_WAIT],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_lastack",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LAST_ACK],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_listen",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_LISTEN],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_synack",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_SYNACK],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_udp",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_UDP],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "timeout_icmp",
 		.data	= &vs_timeout_table_dos.timeout[IP_VS_S_ICMP],
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 #endif
 	{
@@ -1687,35 +1687,35 @@ static struct ctl_table vs_vars[] = {
 		.data		= &sysctl_ip_vs_cache_bypass,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "expire_nodest_conn",
 		.data		= &sysctl_ip_vs_expire_nodest_conn,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "expire_quiescent_template",
 		.data		= &sysctl_ip_vs_expire_quiescent_template,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.procname	= "sync_threshold",
 		.data		= &sysctl_ip_vs_sync_threshold,
 		.maxlen		= sizeof(sysctl_ip_vs_sync_threshold),
 		.mode		= 0644,
-		.proc_handler	= &proc_do_sync_threshold,
+		.proc_handler	= proc_do_sync_threshold,
 	},
 	{
 		.procname	= "nat_icmp_send",
 		.data		= &sysctl_ip_vs_nat_icmp_send,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -115,7 +115,7 @@ static ctl_table vs_vars_table[] = {
 		.data		= &sysctl_ip_vs_lblc_expiration,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -293,7 +293,7 @@ static ctl_table vs_vars_table[] = {
 		.data		= &sysctl_ip_vs_lblcr_expiration,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -35,7 +35,7 @@ static struct ctl_table acct_sysctl_table[] = {
 		.data		= &init_net.ct.sysctl_acct,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{}
 };
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -67,7 +67,7 @@ static struct ctl_table generic_sysctl_table[] = {
 		.data		= &nf_ct_generic_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= 0
@@ -80,7 +80,7 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 		.data		= &nf_ct_generic_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= 0
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -548,49 +548,49 @@ static struct ctl_table sctp_sysctl_table[] = {
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_wait",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_cookie_echoed",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_established",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_sent",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_recd",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_sctp_timeout_shutdown_ack_sent",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name = 0
@@ -604,49 +604,49 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_CLOSED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_wait",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_cookie_echoed",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_COOKIE_ECHOED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_established",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_sent",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_recd",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_RECD],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_sctp_timeout_shutdown_ack_sent",
 		.data		= &sctp_timeouts[SCTP_CONNTRACK_SHUTDOWN_ACK_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name = 0
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1192,70 +1192,70 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_recv",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_established",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_fin_wait",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close_wait",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_last_ack",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_time_wait",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_close",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_max_retrans",
 		.data		= &nf_ct_tcp_timeout_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_tcp_timeout_unacknowledged",
 		.data		= &nf_ct_tcp_timeout_unacknowledged,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_TCP_LOOSE,
@@ -1263,7 +1263,7 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.data		= &nf_ct_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_TCP_BE_LIBERAL,
@@ -1271,7 +1271,7 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.data           = &nf_ct_tcp_be_liberal,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0644,
-		.proc_handler   = &proc_dointvec,
+		.proc_handler   = proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_TCP_MAX_RETRANS,
@@ -1279,7 +1279,7 @@ static struct ctl_table tcp_sysctl_table[] = {
 		.data		= &nf_ct_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= 0
@@ -1293,63 +1293,63 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_SENT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_syn_recv",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_SYN_RECV],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_established",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_ESTABLISHED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_fin_wait",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_FIN_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close_wait",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_last_ack",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_LAST_ACK],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_time_wait",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_TIME_WAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_close",
 		.data		= &tcp_timeouts[TCP_CONNTRACK_CLOSE],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_tcp_timeout_max_retrans",
 		.data		= &nf_ct_tcp_timeout_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_LOOSE,
@@ -1357,7 +1357,7 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.data		= &nf_ct_tcp_loose,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_BE_LIBERAL,
@@ -1365,7 +1365,7 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.data		= &nf_ct_tcp_be_liberal,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_IPV4_NF_CONNTRACK_TCP_MAX_RETRANS,
@@ -1373,7 +1373,7 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 		.data		= &nf_ct_tcp_max_retrans,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= 0
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -143,14 +143,14 @@ static struct ctl_table udp_sysctl_table[] = {
 		.data		= &nf_ct_udp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_udp_timeout_stream",
 		.data		= &nf_ct_udp_timeout_stream,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= 0
@@ -163,14 +163,14 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 		.data		= &nf_ct_udp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "ip_conntrack_udp_timeout_stream",
 		.data		= &nf_ct_udp_timeout_stream,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= 0
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -151,7 +151,7 @@ static struct ctl_table udplite_sysctl_table[] = {
 		.data		= &nf_ct_udplite_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -159,7 +159,7 @@ static struct ctl_table udplite_sysctl_table[] = {
 		.data		= &nf_ct_udplite_timeout_stream,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_jiffies,
+		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.ctl_name	= 0
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -336,7 +336,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_COUNT,
@@ -344,7 +344,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data		= &init_net.ct.count,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name       = NET_NF_CONNTRACK_BUCKETS,
@@ -352,7 +352,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data           = &nf_conntrack_htable_size,
 		.maxlen         = sizeof(unsigned int),
 		.mode           = 0444,
-		.proc_handler   = &proc_dointvec,
+		.proc_handler   = proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_CHECKSUM,
@@ -360,7 +360,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data		= &init_net.ct.sysctl_checksum,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= NET_NF_CONNTRACK_LOG_INVALID,
@@ -368,8 +368,8 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data		= &init_net.ct.sysctl_log_invalid,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &log_invalid_proto_min,
 		.extra2		= &log_invalid_proto_max,
 	},
@@ -379,7 +379,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 		.data		= &nf_ct_expect_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{ .ctl_name = 0 }
 };
@@ -393,7 +393,7 @@ static ctl_table nf_ct_netfilter_table[] = {
 		.data		= &nf_conntrack_max,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -41,8 +41,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_default_path_quality,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_quality,
 		.extra2		= &max_quality
 	},
@@ -52,8 +52,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_obsolescence_count_initialiser,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_obs,
 		.extra2		= &max_obs
 	},
@@ -63,8 +63,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_network_ttl_initialiser,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_ttl,
 		.extra2		= &max_ttl
 	},
@@ -74,8 +74,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_transport_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_t1,
 		.extra2		= &max_t1
 	},
@@ -85,8 +85,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_transport_maximum_tries,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_n2,
 		.extra2		= &max_n2
 	},
@@ -96,8 +96,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_transport_acknowledge_delay,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_t2,
 		.extra2		= &max_t2
 	},
@@ -107,8 +107,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_transport_busy_delay,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_t4,
 		.extra2		= &max_t4
 	},
@@ -118,8 +118,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_transport_requested_window_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_window,
 		.extra2		= &max_window
 	},
@@ -129,8 +129,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_transport_no_activity_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_idle,
 		.extra2		= &max_idle
 	},
@@ -140,8 +140,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_routing_control,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_route,
 		.extra2		= &max_route
 	},
@@ -151,8 +151,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_link_fails_count,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_fails,
 		.extra2		= &max_fails
 	},
@@ -162,8 +162,8 @@ static ctl_table nr_table[] = {
 		.data		= &sysctl_netrom_reset_circuit,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_reset,
 		.extra2		= &max_reset
 	},
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -89,7 +89,7 @@ static struct ctl_table phonet_table[] = {
 		.data		= &local_port_range,
 		.maxlen		= sizeof(local_port_range),
 		.mode		= 0644,
-		.proc_handler	= &proc_local_port_range,
+		.proc_handler	= proc_local_port_range,
 		.strategy	= NULL,
 	},
 	{ .ctl_name = 0 }
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -31,8 +31,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_restart_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
@@ -42,8 +42,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_call_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
@@ -53,8 +53,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_reset_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
@@ -64,8 +64,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_clear_request_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
@@ -75,8 +75,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_no_activity_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_idle,
 		.extra2		= &max_idle
 	},
@@ -86,8 +86,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_ack_hold_back_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_timer,
 		.extra2		= &max_timer
 	},
@@ -97,8 +97,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_routing_control,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_route,
 		.extra2		= &max_route
 	},
@@ -108,8 +108,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_link_fail_timeout,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_ftimer,
 		.extra2		= &max_ftimer
 	},
@@ -119,8 +119,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_maximum_vcs,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_maxvcs,
 		.extra2		= &max_maxvcs
 	},
@@ -130,8 +130,8 @@ static ctl_table rose_table[] = {
 		.data		= &sysctl_rose_window_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &min_window,
 		.extra2		= &max_window
 	},
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -63,8 +63,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rto_initial,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
@@ -74,8 +74,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rto_min,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
@@ -85,8 +85,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rto_max,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
@@ -96,8 +96,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_valid_cookie_life,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
@@ -107,8 +107,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_burst,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &zero,
 		.extra2		= &int_max
 	},
@@ -118,8 +118,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_retrans_association,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &one,
 		.extra2		= &int_max
 	},
@@ -129,8 +129,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_sndbuf_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_RCVBUF_POLICY,
@@ -138,8 +138,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rcvbuf_policy,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_PATH_MAX_RETRANS,
@@ -147,8 +147,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_retrans_path,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &one,
 		.extra2		= &int_max
 	},
@@ -158,8 +158,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_max_retrans_init,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1		= &one,
 		.extra2		= &int_max
 	},
@@ -169,8 +169,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_hb_interval,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1         = &one,
 		.extra2         = &timer_max
 	},
@@ -180,8 +180,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_cookie_preserve_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_RTO_ALPHA,
@@ -189,8 +189,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rto_alpha,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_RTO_BETA,
@@ -198,8 +198,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_rto_beta,
 		.maxlen		= sizeof(int),
 		.mode		= 0444,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_ADDIP_ENABLE,
@@ -207,8 +207,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_addip_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_PRSCTP_ENABLE,
@@ -216,8 +216,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_prsctp_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= NET_SCTP_SACK_TIMEOUT,
@@ -225,8 +225,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_sack_timeout,
 		.maxlen		= sizeof(long),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
+		.proc_handler	= proc_dointvec_minmax,
+		.strategy	= sysctl_intvec,
 		.extra1         = &sack_timer_min,
 		.extra2         = &sack_timer_max,
 	},
@@ -236,7 +236,7 @@ static ctl_table sctp_table[] = {
 		.data		= &sysctl_sctp_mem,
 		.maxlen		= sizeof(sysctl_sctp_mem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -244,7 +244,7 @@ static ctl_table sctp_table[] = {
 		.data		= &sysctl_sctp_rmem,
 		.maxlen		= sizeof(sysctl_sctp_rmem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -252,7 +252,7 @@ static ctl_table sctp_table[] = {
 		.data		= &sysctl_sctp_wmem,
 		.maxlen		= sizeof(sysctl_sctp_wmem),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= proc_dointvec,
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -260,8 +260,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_auth_enable,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{
 		.ctl_name	= CTL_UNNUMBERED,
@@ -269,8 +269,8 @@ static ctl_table sctp_table[] = {
 		.data		= &sctp_addip_noauth,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
-		.strategy	= &sysctl_intvec
+		.proc_handler	= proc_dointvec,
+		.strategy	= sysctl_intvec
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -21,7 +21,7 @@ static ctl_table unix_table[] = {
 		.data		= &init_net.unx.sysctl_max_dgram_qlen,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec
+		.proc_handler	= proc_dointvec
 	},
 	{ .ctl_name = 0 }
 };
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -24,8 +24,8 @@ static struct ctl_table x25_table[] = {
 		.data =		&sysctl_x25_restart_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
-		.proc_handler =	&proc_dointvec_minmax,
-		.strategy =	&sysctl_intvec,
+		.proc_handler =	proc_dointvec_minmax,
+		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
@@ -35,8 +35,8 @@ static struct ctl_table x25_table[] = {
 		.data =		&sysctl_x25_call_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
-		.proc_handler =	&proc_dointvec_minmax,
-		.strategy =	&sysctl_intvec,
+		.proc_handler =	proc_dointvec_minmax,
+		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
@@ -46,8 +46,8 @@ static struct ctl_table x25_table[] = {
 		.data =		&sysctl_x25_reset_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
-		.proc_handler =	&proc_dointvec_minmax,
-		.strategy =	&sysctl_intvec,
+		.proc_handler =	proc_dointvec_minmax,
+		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
@@ -57,8 +57,8 @@ static struct ctl_table x25_table[] = {
 		.data =		&sysctl_x25_clear_request_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
-		.proc_handler =	&proc_dointvec_minmax,
-		.strategy =	&sysctl_intvec,
+		.proc_handler =	proc_dointvec_minmax,
+		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
@@ -68,8 +68,8 @@ static struct ctl_table x25_table[] = {
 		.data =		&sysctl_x25_ack_holdback_timeout,
 		.maxlen =	sizeof(int),
 		.mode =		0644,
-		.proc_handler =	&proc_dointvec_minmax,
-		.strategy =	&sysctl_intvec,
+		.proc_handler =	proc_dointvec_minmax,
+		.strategy =	sysctl_intvec,
 		.extra1 =	&min_timer,
 		.extra2 =	&max_timer,
 	},
@@ -79,7 +79,7 @@ static struct ctl_table x25_table[] = {
 		.data = 	&sysctl_x25_forward,
 		.maxlen = 	sizeof(int),
 		.mode = 	0644,
-		.proc_handler = &proc_dointvec,
+		.proc_handler = proc_dointvec,
 	},
 	{ 0, },
 };
