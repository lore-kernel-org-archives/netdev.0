From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net: Convert uses of typedef ctl_table to struct ctl_table
Date: Tue, 11 Jun 2013 23:04:25 -0700
Message-ID: <0cd3f2ac0e85c8ff68dd2c67057a5d40aaec8337.1371016392.git.joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37727 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752763Ab3FLGE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 02:04:29 -0400
Received: from [173.51.221.202] (account joe@perches.com HELO localhost.localdomain)
  by labridge.com (CommuniGate Pro SMTP 5.0.14)
  with ESMTPA id 21077997 for netdev@vger.kernel.org; Tue, 11 Jun 2013 23:04:27 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the uses of this unnecessary typedef.

Done via perl script:

$ git grep --name-only -w ctl_table net | \
  xargs perl -p -i -e '\
	sub trim { my ($local) = @_; $local =~ s/(^\s+|\s+$)//g; return $local; } \
        s/\b(?<!struct\s)ctl_table\b(\s*\*\s*|\s+\w+)/"struct ctl_table " . trim($1)/ge'

Reflow the modified lines that now exceed 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ax25/sysctl_net_ax25.c                     |  2 +-
 net/bridge/br_netfilter.c                      |  4 ++--
 net/core/neighbour.c                           |  6 ++---
 net/core/sysctl_net_core.c                     |  8 +++----
 net/decnet/dn_dev.c                            |  6 ++---
 net/decnet/sysctl_net_decnet.c                 |  6 ++---
 net/ipv4/devinet.c                             |  6 ++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  2 +-
 net/ipv4/route.c                               |  4 ++--
 net/ipv4/sysctl_net_ipv4.c                     | 31 +++++++++++++-------------
 net/ipv6/addrconf.c                            | 10 ++++-----
 net/ipv6/icmp.c                                |  2 +-
 net/ipv6/route.c                               |  4 ++--
 net/ipv6/sysctl_net_ipv6.c                     |  4 ++--
 net/irda/irsysctl.c                            |  6 ++---
 net/netfilter/ipvs/ip_vs_ctl.c                 |  8 +++----
 net/netfilter/ipvs/ip_vs_lblc.c                |  2 +-
 net/netfilter/ipvs/ip_vs_lblcr.c               |  2 +-
 net/netfilter/nf_conntrack_standalone.c        |  4 ++--
 net/netfilter/nf_log.c                         |  2 +-
 net/netrom/sysctl_net_netrom.c                 |  2 +-
 net/phonet/sysctl.c                            |  4 ++--
 net/rds/ib_sysctl.c                            |  2 +-
 net/rds/iw_sysctl.c                            |  2 +-
 net/rds/sysctl.c                               |  2 +-
 net/rose/sysctl_net_rose.c                     |  2 +-
 net/sctp/sysctl.c                              | 10 ++++-----
 net/sunrpc/sysctl.c                            | 10 ++++-----
 net/sunrpc/xprtrdma/svc_rdma.c                 |  8 +++----
 net/sunrpc/xprtrdma/transport.c                |  4 ++--
 net/sunrpc/xprtsock.c                          |  4 ++--
 net/unix/sysctl_net_unix.c                     |  2 +-
 32 files changed, 86 insertions(+), 85 deletions(-)

diff --git a/net/ax25/sysctl_net_ax25.c b/net/ax25/sysctl_net_ax25.c
index d5744b7..919a5ce 100644
--- a/net/ax25/sysctl_net_ax25.c
+++ b/net/ax25/sysctl_net_ax25.c
@@ -29,7 +29,7 @@ static int min_proto[1],		max_proto[] = { AX25_PROTO_MAX };
 static int min_ds_timeout[1],		max_ds_timeout[] = {65535000};
 #endif
 
-static const ctl_table ax25_param_table[] = {
+static const struct ctl_table ax25_param_table[] = {
 	{
 		.procname	= "ip_default_mode",
 		.maxlen		= sizeof(int),
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 1ed75bf..f877362 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -992,7 +992,7 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 
 #ifdef CONFIG_SYSCTL
 static
-int brnf_sysctl_call_tables(ctl_table * ctl, int write,
+int brnf_sysctl_call_tables(struct ctl_table *ctl, int write,
 			    void __user * buffer, size_t * lenp, loff_t * ppos)
 {
 	int ret;
@@ -1004,7 +1004,7 @@ int brnf_sysctl_call_tables(ctl_table * ctl, int write,
 	return ret;
 }
 
-static ctl_table brnf_table[] = {
+static struct ctl_table brnf_table[] = {
 	{
 		.procname	= "bridge-nf-call-arptables",
 		.data		= &brnf_call_arptables,
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 5c56b21..decaa4b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2765,11 +2765,11 @@ EXPORT_SYMBOL(neigh_app_ns);
 static int zero;
 static int unres_qlen_max = INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
 
-static int proc_unres_qlen(ctl_table *ctl, int write, void __user *buffer,
-			   size_t *lenp, loff_t *ppos)
+static int proc_unres_qlen(struct ctl_table *ctl, int write,
+			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int size, ret;
-	ctl_table tmp = *ctl;
+	struct ctl_table tmp = *ctl;
 
 	tmp.extra1 = &zero;
 	tmp.extra2 = &unres_qlen_max;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 4b48f39..637a42e 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -24,12 +24,12 @@
 static int one = 1;
 
 #ifdef CONFIG_RPS
-static int rps_sock_flow_sysctl(ctl_table *table, int write,
+static int rps_sock_flow_sysctl(struct ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	unsigned int orig_size, size;
 	int ret, i;
-	ctl_table tmp = {
+	struct ctl_table tmp = {
 		.data = &size,
 		.maxlen = sizeof(size),
 		.mode = table->mode
@@ -91,7 +91,7 @@ static int rps_sock_flow_sysctl(ctl_table *table, int write,
 #ifdef CONFIG_NET_FLOW_LIMIT
 static DEFINE_MUTEX(flow_limit_update_mutex);
 
-static int flow_limit_cpu_sysctl(ctl_table *table, int write,
+static int flow_limit_cpu_sysctl(struct ctl_table *table, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *ppos)
 {
@@ -156,7 +156,7 @@ done:
 	return ret;
 }
 
-static int flow_limit_table_len_sysctl(ctl_table *table, int write,
+static int flow_limit_table_len_sysctl(struct ctl_table *table, int write,
 				       void __user *buffer, size_t *lenp,
 				       loff_t *ppos)
 {
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 7d91970..dd0dfb2 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -158,11 +158,11 @@ static int max_t3[] = { 8191 }; /* Must fit in 16 bits when multiplied by BCT3MU
 static int min_priority[1];
 static int max_priority[] = { 127 }; /* From DECnet spec */
 
-static int dn_forwarding_proc(ctl_table *, int,
+static int dn_forwarding_proc(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 static struct dn_dev_sysctl_table {
 	struct ctl_table_header *sysctl_header;
-	ctl_table dn_dev_vars[5];
+	struct ctl_table dn_dev_vars[5];
 } dn_dev_sysctl = {
 	NULL,
 	{
@@ -242,7 +242,7 @@ static void dn_dev_sysctl_unregister(struct dn_dev_parms *parms)
 	}
 }
 
-static int dn_forwarding_proc(ctl_table *table, int write,
+static int dn_forwarding_proc(struct ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
diff --git a/net/decnet/sysctl_net_decnet.c b/net/decnet/sysctl_net_decnet.c
index a55eecc..5325b54 100644
--- a/net/decnet/sysctl_net_decnet.c
+++ b/net/decnet/sysctl_net_decnet.c
@@ -132,7 +132,7 @@ static int parse_addr(__le16 *addr, char *str)
 	return 0;
 }
 
-static int dn_node_address_handler(ctl_table *table, int write,
+static int dn_node_address_handler(struct ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
@@ -183,7 +183,7 @@ static int dn_node_address_handler(ctl_table *table, int write,
 	return 0;
 }
 
-static int dn_def_dev_handler(ctl_table *table, int write,
+static int dn_def_dev_handler(struct ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
@@ -246,7 +246,7 @@ static int dn_def_dev_handler(ctl_table *table, int write,
 	return 0;
 }
 
-static ctl_table dn_table[] = {
+static struct ctl_table dn_table[] = {
 	{
 		.procname = "node_address",
 		.maxlen = 7,
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index b047e2d..d8318d5 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1941,7 +1941,7 @@ static void inet_forward_change(struct net *net)
 	}
 }
 
-static int devinet_conf_proc(ctl_table *ctl, int write,
+static int devinet_conf_proc(struct ctl_table *ctl, int write,
 			     void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
 {
@@ -1984,7 +1984,7 @@ static int devinet_conf_proc(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int devinet_sysctl_forward(ctl_table *ctl, int write,
+static int devinet_sysctl_forward(struct ctl_table *ctl, int write,
 				  void __user *buffer,
 				  size_t *lenp, loff_t *ppos)
 {
@@ -2027,7 +2027,7 @@ static int devinet_sysctl_forward(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int ipv4_doint_and_flush(ctl_table *ctl, int write,
+static int ipv4_doint_and_flush(struct ctl_table *ctl, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 567d841..0a2e0e3 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -223,7 +223,7 @@ static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 static int log_invalid_proto_min = 0;
 static int log_invalid_proto_max = 255;
 
-static ctl_table ip_ct_sysctl_table[] = {
+static struct ctl_table ip_ct_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_max",
 		.maxlen		= sizeof(int),
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 198ea59..f3fa42e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2448,7 +2448,7 @@ static int ip_rt_gc_interval __read_mostly  = 60 * HZ;
 static int ip_rt_gc_min_interval __read_mostly	= HZ / 2;
 static int ip_rt_gc_elasticity __read_mostly	= 8;
 
-static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
+static int ipv4_sysctl_rtcache_flush(struct ctl_table *__ctl, int write,
 					void __user *buffer,
 					size_t *lenp, loff_t *ppos)
 {
@@ -2463,7 +2463,7 @@ static int ipv4_sysctl_rtcache_flush(ctl_table *__ctl, int write,
 	return -EINVAL;
 }
 
-static ctl_table ipv4_route_table[] = {
+static struct ctl_table ipv4_route_table[] = {
 	{
 		.procname	= "gc_thresh",
 		.data		= &ipv4_dst_ops.gc_thresh,
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fa2f63f..b2c123c 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -49,13 +49,13 @@ static void set_local_port_range(int range[2])
 }
 
 /* Validate changes from /proc interface. */
-static int ipv4_local_port_range(ctl_table *table, int write,
+static int ipv4_local_port_range(struct ctl_table *table, int write,
 				 void __user *buffer,
 				 size_t *lenp, loff_t *ppos)
 {
 	int ret;
 	int range[2];
-	ctl_table tmp = {
+	struct ctl_table tmp = {
 		.data = &range,
 		.maxlen = sizeof(range),
 		.mode = table->mode,
@@ -100,7 +100,7 @@ static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t hig
 }
 
 /* Validate changes from /proc interface. */
-static int ipv4_ping_group_range(ctl_table *table, int write,
+static int ipv4_ping_group_range(struct ctl_table *table, int write,
 				 void __user *buffer,
 				 size_t *lenp, loff_t *ppos)
 {
@@ -108,7 +108,7 @@ static int ipv4_ping_group_range(ctl_table *table, int write,
 	int ret;
 	gid_t urange[2];
 	kgid_t low, high;
-	ctl_table tmp = {
+	struct ctl_table tmp = {
 		.data = &urange,
 		.maxlen = sizeof(urange),
 		.mode = table->mode,
@@ -135,11 +135,11 @@ static int ipv4_ping_group_range(ctl_table *table, int write,
 	return ret;
 }
 
-static int proc_tcp_congestion_control(ctl_table *ctl, int write,
+static int proc_tcp_congestion_control(struct ctl_table *ctl, int write,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char val[TCP_CA_NAME_MAX];
-	ctl_table tbl = {
+	struct ctl_table tbl = {
 		.data = val,
 		.maxlen = TCP_CA_NAME_MAX,
 	};
@@ -153,12 +153,12 @@ static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 	return ret;
 }
 
-static int proc_tcp_available_congestion_control(ctl_table *ctl,
+static int proc_tcp_available_congestion_control(struct ctl_table *ctl,
 						 int write,
 						 void __user *buffer, size_t *lenp,
 						 loff_t *ppos)
 {
-	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX, };
+	struct ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX, };
 	int ret;
 
 	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
@@ -170,12 +170,12 @@ static int proc_tcp_available_congestion_control(ctl_table *ctl,
 	return ret;
 }
 
-static int proc_allowed_congestion_control(ctl_table *ctl,
+static int proc_allowed_congestion_control(struct ctl_table *ctl,
 					   int write,
 					   void __user *buffer, size_t *lenp,
 					   loff_t *ppos)
 {
-	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX };
+	struct ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX };
 	int ret;
 
 	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
@@ -190,7 +190,7 @@ static int proc_allowed_congestion_control(ctl_table *ctl,
 	return ret;
 }
 
-static int ipv4_tcp_mem(ctl_table *ctl, int write,
+static int ipv4_tcp_mem(struct ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp,
 			   loff_t *ppos)
 {
@@ -201,7 +201,7 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 	struct mem_cgroup *memcg;
 #endif
 
-	ctl_table tmp = {
+	struct ctl_table tmp = {
 		.data = &vec,
 		.maxlen = sizeof(vec),
 		.mode = ctl->mode,
@@ -233,10 +233,11 @@ static int ipv4_tcp_mem(ctl_table *ctl, int write,
 	return 0;
 }
 
-static int proc_tcp_fastopen_key(ctl_table *ctl, int write, void __user *buffer,
-				 size_t *lenp, loff_t *ppos)
+static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
+				 void __user *buffer, size_t *lenp,
+				 loff_t *ppos)
 {
-	ctl_table tbl = { .maxlen = (TCP_FASTOPEN_KEY_LENGTH * 2 + 10) };
+	struct ctl_table tbl = { .maxlen = (TCP_FASTOPEN_KEY_LENGTH * 2 + 10) };
 	struct tcp_fastopen_context *ctxt;
 	int ret;
 	u32  user_key[4]; /* 16 bytes, matching TCP_FASTOPEN_KEY_LENGTH */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21010fd..8044912 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4620,13 +4620,13 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifp)
 #ifdef CONFIG_SYSCTL
 
 static
-int addrconf_sysctl_forward(ctl_table *ctl, int write,
+int addrconf_sysctl_forward(struct ctl_table *ctl, int write,
 			   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
-	ctl_table lctl;
+	struct ctl_table lctl;
 	int ret;
 
 	/*
@@ -4705,13 +4705,13 @@ static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int newf)
 }
 
 static
-int addrconf_sysctl_disable(ctl_table *ctl, int write,
+int addrconf_sysctl_disable(struct ctl_table *ctl, int write,
 			    void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = ctl->data;
 	int val = *valp;
 	loff_t pos = *ppos;
-	ctl_table lctl;
+	struct ctl_table lctl;
 	int ret;
 
 	/*
@@ -4733,7 +4733,7 @@ int addrconf_sysctl_disable(ctl_table *ctl, int write,
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
-	ctl_table addrconf_vars[DEVCONF_MAX+1];
+	struct ctl_table addrconf_vars[DEVCONF_MAX+1];
 } addrconf_sysctl __read_mostly = {
 	.sysctl_header = NULL,
 	.addrconf_vars = {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 4b4890b..7cfc8d2 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -976,7 +976,7 @@ int icmpv6_err_convert(u8 type, u8 code, int *err)
 EXPORT_SYMBOL(icmpv6_err_convert);
 
 #ifdef CONFIG_SYSCTL
-ctl_table ipv6_icmp_table_template[] = {
+struct ctl_table ipv6_icmp_table_template[] = {
 	{
 		.procname	= "ratelimit",
 		.data		= &init_net.ipv6.sysctl.icmpv6_time,
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2b87418..7ca87b37 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2790,7 +2790,7 @@ static const struct file_operations rt6_stats_seq_fops = {
 #ifdef CONFIG_SYSCTL
 
 static
-int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
+int ipv6_sysctl_rtcache_flush(struct ctl_table *ctl, int write,
 			      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net *net;
@@ -2805,7 +2805,7 @@ int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write,
 	return 0;
 }
 
-ctl_table ipv6_route_table_template[] = {
+struct ctl_table ipv6_route_table_template[] = {
 	{
 		.procname	=	"flush",
 		.data		=	&init_net.ipv6.sysctl.flush_delay,
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index e85c48b..107b2f1 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -16,7 +16,7 @@
 #include <net/addrconf.h>
 #include <net/inet_frag.h>
 
-static ctl_table ipv6_table_template[] = {
+static struct ctl_table ipv6_table_template[] = {
 	{
 		.procname	= "bindv6only",
 		.data		= &init_net.ipv6.sysctl.bindv6only,
@@ -27,7 +27,7 @@ static ctl_table ipv6_table_template[] = {
 	{ }
 };
 
-static ctl_table ipv6_rotable[] = {
+static struct ctl_table ipv6_rotable[] = {
 	{
 		.procname	= "mld_max_msf",
 		.data		= &sysctl_mld_max_msf,
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index de73f64..d6a5965 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -73,7 +73,7 @@ static int min_lap_keepalive_time = 100;	/* 100us */
 /* For other sysctl, I've no idea of the range. Maybe Dag could help
  * us on that - Jean II */
 
-static int do_devname(ctl_table *table, int write,
+static int do_devname(struct ctl_table *table, int write,
 		      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int ret;
@@ -90,7 +90,7 @@ static int do_devname(ctl_table *table, int write,
 }
 
 
-static int do_discovery(ctl_table *table, int write,
+static int do_discovery(struct ctl_table *table, int write,
                     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
        int ret;
@@ -111,7 +111,7 @@ static int do_discovery(ctl_table *table, int write,
 }
 
 /* One file */
-static ctl_table irda_table[] = {
+static struct ctl_table irda_table[] = {
 	{
 		.procname	= "discovery",
 		.data		= &sysctl_discovery,
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index df05c1c..edb88fb 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1575,7 +1575,7 @@ static int zero;
 static int three = 3;
 
 static int
-proc_do_defense_mode(ctl_table *table, int write,
+proc_do_defense_mode(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	struct net *net = current->nsproxy->net_ns;
@@ -1596,7 +1596,7 @@ proc_do_defense_mode(ctl_table *table, int write,
 }
 
 static int
-proc_do_sync_threshold(ctl_table *table, int write,
+proc_do_sync_threshold(struct ctl_table *table, int write,
 		       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = table->data;
@@ -1616,7 +1616,7 @@ proc_do_sync_threshold(ctl_table *table, int write,
 }
 
 static int
-proc_do_sync_mode(ctl_table *table, int write,
+proc_do_sync_mode(struct ctl_table *table, int write,
 		     void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = table->data;
@@ -1634,7 +1634,7 @@ proc_do_sync_mode(ctl_table *table, int write,
 }
 
 static int
-proc_do_sync_ports(ctl_table *table, int write,
+proc_do_sync_ports(struct ctl_table *table, int write,
 		   void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	int *valp = table->data;
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 5ea26bd..44595b8 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -118,7 +118,7 @@ struct ip_vs_lblc_table {
  *      IPVS LBLC sysctl table
  */
 #ifdef CONFIG_SYSCTL
-static ctl_table vs_vars_table[] = {
+static struct ctl_table vs_vars_table[] = {
 	{
 		.procname	= "lblc_expiration",
 		.data		= NULL,
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 50123c2..876937d 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -299,7 +299,7 @@ struct ip_vs_lblcr_table {
  *      IPVS LBLCR sysctl table
  */
 
-static ctl_table vs_vars_table[] = {
+static struct ctl_table vs_vars_table[] = {
 	{
 		.procname	= "lblcr_expiration",
 		.data		= NULL,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index bd700b4..f641751 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -408,7 +408,7 @@ static int log_invalid_proto_max = 255;
 
 static struct ctl_table_header *nf_ct_netfilter_header;
 
-static ctl_table nf_ct_sysctl_table[] = {
+static struct ctl_table nf_ct_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_max",
 		.data		= &nf_conntrack_max,
@@ -458,7 +458,7 @@ static ctl_table nf_ct_sysctl_table[] = {
 
 #define NET_NF_CONNTRACK_MAX 2089
 
-static ctl_table nf_ct_netfilter_table[] = {
+static struct ctl_table nf_ct_netfilter_table[] = {
 	{
 		.procname	= "nf_conntrack_max",
 		.data		= &nf_conntrack_max,
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 4b60a87..85296d4 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -245,7 +245,7 @@ static const struct file_operations nflog_file_ops = {
 static char nf_log_sysctl_fnames[NFPROTO_NUMPROTO-NFPROTO_UNSPEC][3];
 static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
 
-static int nf_log_proc_dostring(ctl_table *table, int write,
+static int nf_log_proc_dostring(struct ctl_table *table, int write,
 			 void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	const struct nf_logger *logger;
diff --git a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
index 42f630b..ba1c368 100644
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -34,7 +34,7 @@ static int min_reset[]   = {0}, max_reset[]   = {1};
 
 static struct ctl_table_header *nr_table_header;
 
-static ctl_table nr_table[] = {
+static struct ctl_table nr_table[] = {
 	{
 		.procname	= "default_path_quality",
 		.data		= &sysctl_netrom_default_path_quality,
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index d6bbbbd..c02a8c4 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -61,13 +61,13 @@ void phonet_get_local_port_range(int *min, int *max)
 	} while (read_seqretry(&local_port_range_lock, seq));
 }
 
-static int proc_local_port_range(ctl_table *table, int write,
+static int proc_local_port_range(struct ctl_table *table, int write,
 				void __user *buffer,
 				size_t *lenp, loff_t *ppos)
 {
 	int ret;
 	int range[2] = {local_port_range[0], local_port_range[1]};
-	ctl_table tmp = {
+	struct ctl_table tmp = {
 		.data = &range,
 		.maxlen = sizeof(range),
 		.mode = table->mode,
diff --git a/net/rds/ib_sysctl.c b/net/rds/ib_sysctl.c
index 7e643ba..e4e41b3 100644
--- a/net/rds/ib_sysctl.c
+++ b/net/rds/ib_sysctl.c
@@ -61,7 +61,7 @@ static unsigned long rds_ib_sysctl_max_unsig_wr_max = 64;
  */
 unsigned int rds_ib_sysctl_flow_control = 0;
 
-static ctl_table rds_ib_sysctl_table[] = {
+static struct ctl_table rds_ib_sysctl_table[] = {
 	{
 		.procname       = "max_send_wr",
 		.data		= &rds_ib_sysctl_max_send_wr,
diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
index 5d5ebd5..89c9151 100644
--- a/net/rds/iw_sysctl.c
+++ b/net/rds/iw_sysctl.c
@@ -55,7 +55,7 @@ static unsigned long rds_iw_sysctl_max_unsig_bytes_max = ~0UL;
 
 unsigned int rds_iw_sysctl_flow_control = 1;
 
-static ctl_table rds_iw_sysctl_table[] = {
+static struct ctl_table rds_iw_sysctl_table[] = {
 	{
 		.procname       = "max_send_wr",
 		.data		= &rds_iw_sysctl_max_send_wr,
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index 907214b..b5cb2aa 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -49,7 +49,7 @@ unsigned int  rds_sysctl_max_unacked_bytes = (16 << 20);
 
 unsigned int rds_sysctl_ping_enable = 1;
 
-static ctl_table rds_sysctl_rds_table[] = {
+static struct ctl_table rds_sysctl_rds_table[] = {
 	{
 		.procname       = "reconnect_min_delay_ms",
 		.data		= &rds_sysctl_reconnect_min_jiffies,
diff --git a/net/rose/sysctl_net_rose.c b/net/rose/sysctl_net_rose.c
index 94ca9c2..89a9278 100644
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -24,7 +24,7 @@ static int min_window[] = {1}, max_window[] = {7};
 
 static struct ctl_table_header *rose_table_header;
 
-static ctl_table rose_table[] = {
+static struct ctl_table rose_table[] = {
 	{
 		.procname	= "restart_request_timeout",
 		.data		= &sysctl_rose_restart_request_timeout,
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index bf3c6e8..9a5c4c9 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -62,12 +62,12 @@ extern long sysctl_sctp_mem[3];
 extern int sysctl_sctp_rmem[3];
 extern int sysctl_sctp_wmem[3];
 
-static int proc_sctp_do_hmac_alg(ctl_table *ctl,
+static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
 				int write,
 				void __user *buffer, size_t *lenp,
 
 				loff_t *ppos);
-static ctl_table sctp_table[] = {
+static struct ctl_table sctp_table[] = {
 	{
 		.procname	= "sctp_mem",
 		.data		= &sysctl_sctp_mem,
@@ -93,7 +93,7 @@ static ctl_table sctp_table[] = {
 	{ /* sentinel */ }
 };
 
-static ctl_table sctp_net_table[] = {
+static struct ctl_table sctp_net_table[] = {
 	{
 		.procname	= "rto_initial",
 		.data		= &init_net.sctp.rto_initial,
@@ -300,14 +300,14 @@ static ctl_table sctp_net_table[] = {
 	{ /* sentinel */ }
 };
 
-static int proc_sctp_do_hmac_alg(ctl_table *ctl,
+static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
 				int write,
 				void __user *buffer, size_t *lenp,
 				loff_t *ppos)
 {
 	struct net *net = current->nsproxy->net_ns;
 	char tmp[8];
-	ctl_table tbl;
+	struct ctl_table tbl;
 	int ret;
 	int changed = 0;
 	char *none = "none";
diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index af7d339..c99c58e 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -40,7 +40,7 @@ EXPORT_SYMBOL_GPL(nlm_debug);
 #ifdef RPC_DEBUG
 
 static struct ctl_table_header *sunrpc_table_header;
-static ctl_table		sunrpc_table[];
+static struct ctl_table sunrpc_table[];
 
 void
 rpc_register_sysctl(void)
@@ -58,7 +58,7 @@ rpc_unregister_sysctl(void)
 	}
 }
 
-static int proc_do_xprt(ctl_table *table, int write,
+static int proc_do_xprt(struct ctl_table *table, int write,
 			void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char tmpbuf[256];
@@ -73,7 +73,7 @@ static int proc_do_xprt(ctl_table *table, int write,
 }
 
 static int
-proc_dodebug(ctl_table *table, int write,
+proc_dodebug(struct ctl_table *table, int write,
 				void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	char		tmpbuf[20], c, *s;
@@ -135,7 +135,7 @@ done:
 }
 
 
-static ctl_table debug_table[] = {
+static struct ctl_table debug_table[] = {
 	{
 		.procname	= "rpc_debug",
 		.data		= &rpc_debug,
@@ -173,7 +173,7 @@ static ctl_table debug_table[] = {
 	{ }
 };
 
-static ctl_table sunrpc_table[] = {
+static struct ctl_table sunrpc_table[] = {
 	{
 		.procname	= "sunrpc",
 		.mode		= 0555,
diff --git a/net/sunrpc/xprtrdma/svc_rdma.c b/net/sunrpc/xprtrdma/svc_rdma.c
index 8343737..c1b6270 100644
--- a/net/sunrpc/xprtrdma/svc_rdma.c
+++ b/net/sunrpc/xprtrdma/svc_rdma.c
@@ -84,7 +84,7 @@ struct workqueue_struct *svc_rdma_wq;
  * resets the associated statistic to zero. Any read returns it's
  * current value.
  */
-static int read_reset_stat(ctl_table *table, int write,
+static int read_reset_stat(struct ctl_table *table, int write,
 			   void __user *buffer, size_t *lenp,
 			   loff_t *ppos)
 {
@@ -119,7 +119,7 @@ static int read_reset_stat(ctl_table *table, int write,
 }
 
 static struct ctl_table_header *svcrdma_table_header;
-static ctl_table svcrdma_parm_table[] = {
+static struct ctl_table svcrdma_parm_table[] = {
 	{
 		.procname	= "max_requests",
 		.data		= &svcrdma_max_requests,
@@ -214,7 +214,7 @@ static ctl_table svcrdma_parm_table[] = {
 	{ },
 };
 
-static ctl_table svcrdma_table[] = {
+static struct ctl_table svcrdma_table[] = {
 	{
 		.procname	= "svc_rdma",
 		.mode		= 0555,
@@ -223,7 +223,7 @@ static ctl_table svcrdma_table[] = {
 	{ },
 };
 
-static ctl_table svcrdma_root_table[] = {
+static struct ctl_table svcrdma_root_table[] = {
 	{
 		.procname	= "sunrpc",
 		.mode		= 0555,
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 794312f..285dc08 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -86,7 +86,7 @@ static unsigned int max_memreg = RPCRDMA_LAST - 1;
 
 static struct ctl_table_header *sunrpc_table_header;
 
-static ctl_table xr_tunables_table[] = {
+static struct ctl_table xr_tunables_table[] = {
 	{
 		.procname	= "rdma_slot_table_entries",
 		.data		= &xprt_rdma_slot_table_entries,
@@ -138,7 +138,7 @@ static ctl_table xr_tunables_table[] = {
 	{ },
 };
 
-static ctl_table sunrpc_table[] = {
+static struct ctl_table sunrpc_table[] = {
 	{
 		.procname	= "sunrpc",
 		.mode		= 0555,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ffd5034..412de7c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -87,7 +87,7 @@ static struct ctl_table_header *sunrpc_table_header;
  * FIXME: changing the UDP slot table size should also resize the UDP
  *        socket buffers for existing UDP transports
  */
-static ctl_table xs_tunables_table[] = {
+static struct ctl_table xs_tunables_table[] = {
 	{
 		.procname	= "udp_slot_table_entries",
 		.data		= &xprt_udp_slot_table_entries,
@@ -143,7 +143,7 @@ static ctl_table xs_tunables_table[] = {
 	{ },
 };
 
-static ctl_table sunrpc_table[] = {
+static struct ctl_table sunrpc_table[] = {
 	{
 		.procname	= "sunrpc",
 		.mode		= 0555,
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 8800604..b3d5150 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -15,7 +15,7 @@
 
 #include <net/af_unix.h>
 
-static ctl_table unix_table[] = {
+static struct ctl_table unix_table[] = {
 	{
 		.procname	= "max_dgram_qlen",
 		.data		= &init_net.unx.sysctl_max_dgram_qlen,
-- 
1.8.1.2.459.gbcd45b4.dirty
