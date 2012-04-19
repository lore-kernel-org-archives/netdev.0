From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 17/19] net: Convert all sysctl registrations to register_net_sysctl
Date: Thu, 19 Apr 2012 16:44:49 -0700
Message-ID: <m1lilre172.fsf@fess.ebiederm.org>
References: <m1aa27ia6h.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, pablo@netfilter.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:60373 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756202Ab2DSXkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 19:40:52 -0400
In-Reply-To: <m1aa27ia6h.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Apr 2012 16:17:10 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This results in code with less boiler plate that is a bit easier
to read.

Additionally stops us from using compatibility code in the sysctl
core, hastening the day when the compatibility code can be removed.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/infiniband/core/ucma.c          |    8 +-------
 net/802/tr.c                            |    8 +-------
 net/appletalk/sysctl_net_atalk.c        |    8 +-------
 net/bridge/br_netfilter.c               |    8 +-------
 net/core/sysctl_net_core.c              |    3 +--
 net/dccp/sysctl.c                       |    9 +--------
 net/ipv4/ip_fragment.c                  |    2 +-
 net/ipv4/netfilter/ip_queue.c           |    2 +-
 net/ipv4/route.c                        |   10 +---------
 net/ipv4/sysctl_net_ipv4.c              |    5 ++---
 net/ipv4/xfrm4_policy.c                 |    4 ++--
 net/ipv6/netfilter/ip6_queue.c          |    2 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 net/ipv6/reassembly.c                   |    2 +-
 net/ipv6/xfrm6_policy.c                 |    4 ++--
 net/ipx/sysctl_net_ipx.c                |    8 +-------
 net/irda/irsysctl.c                     |    8 +-------
 net/netfilter/ipvs/ip_vs_ctl.c          |    3 +--
 net/netfilter/ipvs/ip_vs_lblc.c         |    3 +--
 net/netfilter/ipvs/ip_vs_lblcr.c        |    3 +--
 net/netfilter/nf_conntrack_acct.c       |    4 ++--
 net/netfilter/nf_conntrack_ecache.c     |    3 +--
 net/netfilter/nf_conntrack_proto_dccp.c |    4 ++--
 net/netfilter/nf_conntrack_standalone.c |   10 ++--------
 net/netfilter/nf_conntrack_timestamp.c  |    4 ++--
 net/netfilter/nf_log.c                  |    9 +--------
 net/netrom/sysctl_net_netrom.c          |    8 +-------
 net/phonet/sysctl.c                     |    8 +-------
 net/rds/ib_sysctl.c                     |    9 +--------
 net/rds/iw_sysctl.c                     |    9 +--------
 net/rds/sysctl.c                        |    9 +--------
 net/rose/sysctl_net_rose.c              |    8 +-------
 net/sctp/sysctl.c                       |    8 +-------
 net/unix/sysctl_net_unix.c              |    8 +-------
 net/x25/sysctl_net_x25.c                |    8 +-------
 net/xfrm/xfrm_sysctl.c                  |    2 +-
 36 files changed, 44 insertions(+), 171 deletions(-)

diff --git a/drivers/infiniband/core/ucma.c b/drivers/infiniband/core/ucma.c
index 9f3e2be..8002ae6 100644
--- a/drivers/infiniband/core/ucma.c
+++ b/drivers/infiniband/core/ucma.c
@@ -66,12 +66,6 @@ static ctl_table ucma_ctl_table[] = {
 	{ }
 };
 
-static struct ctl_path ucma_ctl_path[] = {
-	{ .procname = "net" },
-	{ .procname = "rdma_ucm" },
-	{ }
-};
-
 struct ucma_file {
 	struct mutex		mut;
 	struct file		*filp;
@@ -1392,7 +1386,7 @@ static int __init ucma_init(void)
 		goto err1;
 	}
 
-	ucma_ctl_table_hdr = register_net_sysctl_table(&init_net, ucma_ctl_path, ucma_ctl_table);
+	ucma_ctl_table_hdr = register_net_sysctl(&init_net, "net/rdma_ucm", ucma_ctl_table);
 	if (!ucma_ctl_table_hdr) {
 		printk(KERN_ERR "rdma_ucm: couldn't register sysctl paths\n");
 		ret = -ENOMEM;
diff --git a/net/802/tr.c b/net/802/tr.c
index 103e020..30a352e 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -643,12 +643,6 @@ static struct ctl_table tr_table[] = {
 	},
 	{ },
 };
-
-static __initdata struct ctl_path tr_path[] = {
-	{ .procname = "net", },
-	{ .procname = "token-ring", },
-	{ }
-};
 #endif
 
 /*
@@ -662,7 +656,7 @@ static int __init rif_init(void)
 	setup_timer(&rif_timer, rif_check_expire, 0);
 	add_timer(&rif_timer);
 #ifdef CONFIG_SYSCTL
-	register_net_sysctl_table(&init_net, tr_path, tr_table);
+	register_net_sysctl(&init_net, "net/token-ring", tr_table);
 #endif
 	proc_net_fops_create(&init_net, "tr_rif", S_IRUGO, &rif_seq_fops);
 	return 0;
diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net_atalk.c
index 5edce8f..ebb8643 100644
--- a/net/appletalk/sysctl_net_atalk.c
+++ b/net/appletalk/sysctl_net_atalk.c
@@ -42,17 +42,11 @@ static struct ctl_table atalk_table[] = {
 	{ },
 };
 
-static struct ctl_path atalk_path[] = {
-	{ .procname = "net", },
-	{ .procname = "appletalk", },
-	{ }
-};
-
 static struct ctl_table_header *atalk_table_header;
 
 void atalk_register_sysctl(void)
 {
-	atalk_table_header = register_net_sysctl_table(&init_net, atalk_path, atalk_table);
+	atalk_table_header = register_net_sysctl(&init_net, "net/appletalk", atalk_table);
 }
 
 void atalk_unregister_sysctl(void)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4f4c4a6..9d4f09c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1008,12 +1008,6 @@ static ctl_table brnf_table[] = {
 	},
 	{ }
 };
-
-static struct ctl_path brnf_path[] = {
-	{ .procname = "net", },
-	{ .procname = "bridge", },
-	{ }
-};
 #endif
 
 int __init br_netfilter_init(void)
@@ -1030,7 +1024,7 @@ int __init br_netfilter_init(void)
 		return ret;
 	}
 #ifdef CONFIG_SYSCTL
-	brnf_sysctl_header = register_net_sysctl_table(&init_net, brnf_path, brnf_table);
+	brnf_sysctl_header = register_net_sysctl(&init_net, "net/bridge", brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 4a9472d..286d739 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -223,8 +223,7 @@ static __net_init int sysctl_core_net_init(struct net *net)
 		tbl[0].data = &net->core.sysctl_somaxconn;
 	}
 
-	net->core.sysctl_hdr = register_net_sysctl_table(net,
-			net_core_path, tbl);
+	net->core.sysctl_hdr = register_net_sysctl(net, "net/core", tbl);
 	if (net->core.sysctl_hdr == NULL)
 		goto err_reg;
 
diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
index 329e139..607ab71 100644
--- a/net/dccp/sysctl.c
+++ b/net/dccp/sysctl.c
@@ -98,18 +98,11 @@ static struct ctl_table dccp_default_table[] = {
 	{ }
 };
 
-static struct ctl_path dccp_path[] = {
-	{ .procname = "net", },
-	{ .procname = "dccp", },
-	{ .procname = "default", },
-	{ }
-};
-
 static struct ctl_table_header *dccp_table_header;
 
 int __init dccp_sysctl_init(void)
 {
-	dccp_table_header = register_net_sysctl_table(&init_net, dccp_path,
+	dccp_table_header = register_net_sysctl(&init_net, "net/dccp/default",
 			dccp_default_table);
 
 	return dccp_table_header != NULL ? 0 : -ENOMEM;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a746cca..fd81203 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -782,7 +782,7 @@ static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 		table[2].data = &net->ipv4.frags.timeout;
 	}
 
-	hdr = register_net_sysctl_table(net, net_ipv4_ctl_path, table);
+	hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (hdr == NULL)
 		goto err_reg;
 
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 766485d..09775a1 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -586,7 +586,7 @@ static int __init ip_queue_init(void)
 #endif
 	register_netdevice_notifier(&ipq_dev_notifier);
 #ifdef CONFIG_SYSCTL
-	ipq_sysctl_header = register_net_sysctl_table(&init_net, net_ipv4_ctl_path, ipq_table);
+	ipq_sysctl_header = register_net_sysctl(&init_net, "net/ipv4", ipq_table);
 #endif
 	status = nf_register_queue_handler(NFPROTO_IPV4, &nfqh);
 	if (status < 0) {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4dd8027..01cd527 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3353,13 +3353,6 @@ static struct ctl_table ipv4_route_flush_table[] = {
 	{ },
 };
 
-static __net_initdata struct ctl_path ipv4_route_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipv4", },
-	{ .procname = "route", },
-	{ },
-};
-
 static __net_init int sysctl_route_net_init(struct net *net)
 {
 	struct ctl_table *tbl;
@@ -3372,8 +3365,7 @@ static __net_init int sysctl_route_net_init(struct net *net)
 	}
 	tbl[0].extra1 = net;
 
-	net->ipv4.route_hdr =
-		register_net_sysctl_table(net, ipv4_route_path, tbl);
+	net->ipv4.route_hdr = register_net_sysctl(net, "net/ipv4/route", tbl);
 	if (net->ipv4.route_hdr == NULL)
 		goto err_reg;
 	return 0;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e7a6fa3..56e64f7 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -815,8 +815,7 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 
 	tcp_init_mem(net);
 
-	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
-			net_ipv4_ctl_path, table);
+	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (net->ipv4.ipv4_hdr == NULL)
 		goto err_reg;
 
@@ -857,7 +856,7 @@ static __init int sysctl_ipv4_init(void)
 	if (!i->procname)
 		return -EINVAL;
 
-	hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path, ipv4_table);
+	hdr = register_net_sysctl(&init_net, "net/ipv4", ipv4_table);
 	if (hdr == NULL)
 		return -ENOMEM;
 
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 8ef24e1..0d3426c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -298,8 +298,8 @@ void __init xfrm4_init(int rt_max_size)
 	xfrm4_state_init();
 	xfrm4_policy_init();
 #ifdef CONFIG_SYSCTL
-	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv4_ctl_path,
-						xfrm4_policy_table);
+	sysctl_hdr = register_net_sysctl(&init_net, "net/ipv4",
+					 xfrm4_policy_table);
 #endif
 }
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index 6785f50..3ca9303 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -588,7 +588,7 @@ static int __init ip6_queue_init(void)
 #endif
 	register_netdevice_notifier(&ipq_dev_notifier);
 #ifdef CONFIG_SYSCTL
-	ipq_sysctl_header = register_net_sysctl_table(&init_net, net_ipv6_ctl_path, ipq_table);
+	ipq_sysctl_header = register_net_sysctl(&init_net, "net/ipv6", ipq_table);
 #endif
 	status = nf_register_queue_handler(NFPROTO_IPV6, &nfqh);
 	if (status < 0) {
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 7548144..48a2be1 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -626,8 +626,8 @@ int nf_ct_frag6_init(void)
 	inet_frags_init(&nf_frags);
 
 #ifdef CONFIG_SYSCTL
-	nf_ct_frag6_sysctl_header = register_net_sysctl_table(&init_net, nf_net_netfilter_sysctl_path,
-							  nf_ct_frag6_sysctl_table);
+	nf_ct_frag6_sysctl_header = register_net_sysctl(&init_net, "net/netfilter",
+							nf_ct_frag6_sysctl_table);
 	if (!nf_ct_frag6_sysctl_header) {
 		inet_frags_fini(&nf_frags);
 		return -ENOMEM;
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 42f4f7c..36e04cf 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -646,7 +646,7 @@ static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 		table[2].data = &net->ipv6.frags.timeout;
 	}
 
-	hdr = register_net_sysctl_table(net, net_ipv6_ctl_path, table);
+	hdr = register_net_sysctl(net, "net/ipv6", table);
 	if (hdr == NULL)
 		goto err_reg;
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 8ea65e0..8625fba 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -334,8 +334,8 @@ int __init xfrm6_init(void)
 		goto out_policy;
 
 #ifdef CONFIG_SYSCTL
-	sysctl_hdr = register_net_sysctl_table(&init_net, net_ipv6_ctl_path,
-						xfrm6_policy_table);
+	sysctl_hdr = register_net_sysctl(&init_net, "net/ipv6",
+					 xfrm6_policy_table);
 #endif
 out:
 	return ret;
diff --git a/net/ipx/sysctl_net_ipx.c b/net/ipx/sysctl_net_ipx.c
index 0358807..ad7c03d 100644
--- a/net/ipx/sysctl_net_ipx.c
+++ b/net/ipx/sysctl_net_ipx.c
@@ -28,17 +28,11 @@ static struct ctl_table ipx_table[] = {
 	{ },
 };
 
-static struct ctl_path ipx_path[] = {
-	{ .procname = "net", },
-	{ .procname = "ipx", },
-	{ }
-};
-
 static struct ctl_table_header *ipx_table_header;
 
 void ipx_register_sysctl(void)
 {
-	ipx_table_header = register_net_sysctl_table(&init_net, ipx_path, ipx_table);
+	ipx_table_header = register_net_sysctl(&init_net, "net/ipx", ipx_table);
 }
 
 void ipx_unregister_sysctl(void)
diff --git a/net/irda/irsysctl.c b/net/irda/irsysctl.c
index 20ced38..de73f64 100644
--- a/net/irda/irsysctl.c
+++ b/net/irda/irsysctl.c
@@ -235,12 +235,6 @@ static ctl_table irda_table[] = {
 	{ }
 };
 
-static struct ctl_path irda_path[] = {
-	{ .procname = "net", },
-	{ .procname = "irda", },
-	{ }
-};
-
 static struct ctl_table_header *irda_table_header;
 
 /*
@@ -251,7 +245,7 @@ static struct ctl_table_header *irda_table_header;
  */
 int __init irda_sysctl_register(void)
 {
-	irda_table_header = register_net_sysctl_table(&init_net, irda_path, irda_table);
+	irda_table_header = register_net_sysctl(&init_net, "net/irda", irda_table);
 	if (!irda_table_header)
 		return -ENOMEM;
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index b8d0df7..a606d6b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3672,8 +3672,7 @@ int __net_init ip_vs_control_net_init_sysctl(struct net *net)
 	tbl[idx++].data = &ipvs->sysctl_nat_icmp_send;
 
 
-	ipvs->sysctl_hdr = register_net_sysctl_table(net, net_vs_ctl_path,
-						     tbl);
+	ipvs->sysctl_hdr = register_net_sysctl(net, "net/ipv4/vs", tbl);
 	if (ipvs->sysctl_hdr == NULL) {
 		if (!net_eq(net, &init_net))
 			kfree(tbl);
diff --git a/net/netfilter/ipvs/ip_vs_lblc.c b/net/netfilter/ipvs/ip_vs_lblc.c
index 27c24f1..1024466 100644
--- a/net/netfilter/ipvs/ip_vs_lblc.c
+++ b/net/netfilter/ipvs/ip_vs_lblc.c
@@ -563,8 +563,7 @@ static int __net_init __ip_vs_lblc_init(struct net *net)
 	ipvs->lblc_ctl_table[0].data = &ipvs->sysctl_lblc_expiration;
 
 	ipvs->lblc_ctl_header =
-		register_net_sysctl_table(net, net_vs_ctl_path,
-					  ipvs->lblc_ctl_table);
+		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblc_ctl_table);
 	if (!ipvs->lblc_ctl_header) {
 		if (!net_eq(net, &init_net))
 			kfree(ipvs->lblc_ctl_table);
diff --git a/net/netfilter/ipvs/ip_vs_lblcr.c b/net/netfilter/ipvs/ip_vs_lblcr.c
index 7498756..9261825 100644
--- a/net/netfilter/ipvs/ip_vs_lblcr.c
+++ b/net/netfilter/ipvs/ip_vs_lblcr.c
@@ -757,8 +757,7 @@ static int __net_init __ip_vs_lblcr_init(struct net *net)
 	ipvs->lblcr_ctl_table[0].data = &ipvs->sysctl_lblcr_expiration;
 
 	ipvs->lblcr_ctl_header =
-		register_net_sysctl_table(net, net_vs_ctl_path,
-					  ipvs->lblcr_ctl_table);
+		register_net_sysctl(net, "net/ipv4/vs", ipvs->lblcr_ctl_table);
 	if (!ipvs->lblcr_ctl_header) {
 		if (!net_eq(net, &init_net))
 			kfree(ipvs->lblcr_ctl_table);
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index f4f8cda..d61e078 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -69,8 +69,8 @@ static int nf_conntrack_acct_init_sysctl(struct net *net)
 
 	table[0].data = &net->ct.sysctl_acct;
 
-	net->ct.acct_sysctl_header = register_net_sysctl_table(net,
-			nf_net_netfilter_sysctl_path, table);
+	net->ct.acct_sysctl_header = register_net_sysctl(net, "net/netfilter",
+							 table);
 	if (!net->ct.acct_sysctl_header) {
 		printk(KERN_ERR "nf_conntrack_acct: can't register to sysctl.\n");
 		goto out_register;
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 5bd3047d..b924f3a 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -199,8 +199,7 @@ static int nf_conntrack_event_init_sysctl(struct net *net)
 	table[1].data = &net->ct.sysctl_events_retry_timeout;
 
 	net->ct.event_sysctl_header =
-		register_net_sysctl_table(net,
-					  nf_net_netfilter_sysctl_path, table);
+		register_net_sysctl(net, "net/netfilter", table);
 	if (!net->ct.event_sysctl_header) {
 		printk(KERN_ERR "nf_ct_event: can't register to sysctl.\n");
 		goto out_register;
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index a58998d..ef706a4 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -910,8 +910,8 @@ static __net_init int dccp_net_init(struct net *net)
 	dn->sysctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
 	dn->sysctl_table[7].data = &dn->dccp_loose;
 
-	dn->sysctl_header = register_net_sysctl_table(net,
-			nf_net_netfilter_sysctl_path, dn->sysctl_table);
+	dn->sysctl_header = register_net_sysctl(net, "net/netfilter",
+						dn->sysctl_table);
 	if (!dn->sysctl_header) {
 		kfree(dn->sysctl_table);
 		return -ENOMEM;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 0c3888d..9b39432 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -468,18 +468,13 @@ static ctl_table nf_ct_netfilter_table[] = {
 	{ }
 };
 
-static struct ctl_path nf_ct_path[] = {
-	{ .procname = "net", },
-	{ }
-};
-
 static int nf_conntrack_standalone_init_sysctl(struct net *net)
 {
 	struct ctl_table *table;
 
 	if (net_eq(net, &init_net)) {
 		nf_ct_netfilter_header =
-		       register_net_sysctl_table(&init_net, nf_ct_path, nf_ct_netfilter_table);
+		       register_net_sysctl(&init_net, "net", nf_ct_netfilter_table);
 		if (!nf_ct_netfilter_header)
 			goto out;
 	}
@@ -494,8 +489,7 @@ static int nf_conntrack_standalone_init_sysctl(struct net *net)
 	table[3].data = &net->ct.sysctl_checksum;
 	table[4].data = &net->ct.sysctl_log_invalid;
 
-	net->ct.sysctl_header = register_net_sysctl_table(net,
-					nf_net_netfilter_sysctl_path, table);
+	net->ct.sysctl_header = register_net_sysctl(net, "net/netfilter", table);
 	if (!net->ct.sysctl_header)
 		goto out_unregister_netfilter;
 
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index e8d27af..dbb364f 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -51,8 +51,8 @@ static int nf_conntrack_tstamp_init_sysctl(struct net *net)
 
 	table[0].data = &net->ct.sysctl_tstamp;
 
-	net->ct.tstamp_sysctl_header = register_net_sysctl_table(net,
-			nf_net_netfilter_sysctl_path, table);
+	net->ct.tstamp_sysctl_header = register_net_sysctl(net,	"net/netfilter",
+							   table);
 	if (!net->ct.tstamp_sysctl_header) {
 		printk(KERN_ERR "nf_ct_tstamp: can't register to sysctl.\n");
 		goto out_register;
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 04fca48..703fb26 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -214,13 +214,6 @@ static const struct file_operations nflog_file_ops = {
 #endif /* PROC_FS */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_path nf_log_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "netfilter", },
-	{ .procname = "nf_log", },
-	{ }
-};
-
 static char nf_log_sysctl_fnames[NFPROTO_NUMPROTO-NFPROTO_UNSPEC][3];
 static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
 static struct ctl_table_header *nf_log_dir_header;
@@ -283,7 +276,7 @@ static __init int netfilter_log_sysctl_init(void)
 		nf_log_sysctl_table[i].extra1 = (void *)(unsigned long) i;
 	}
 
-	nf_log_dir_header = register_net_sysctl_table(&init_net, nf_log_sysctl_path,
+	nf_log_dir_header = register_net_sysctl(&init_net, "net/netfilter/nf_log",
 				       nf_log_sysctl_table);
 	if (!nf_log_dir_header)
 		return -ENOMEM;
diff --git a/net/netrom/sysctl_net_netrom.c b/net/netrom/sysctl_net_netrom.c
index 4ed149e..42f630b 100644
--- a/net/netrom/sysctl_net_netrom.c
+++ b/net/netrom/sysctl_net_netrom.c
@@ -146,15 +146,9 @@ static ctl_table nr_table[] = {
 	{ }
 };
 
-static struct ctl_path nr_path[] = {
-	{ .procname = "net", },
-	{ .procname = "netrom", },
-	{ }
-};
-
 void __init nr_register_sysctl(void)
 {
-	nr_table_header = register_net_sysctl_table(&init_net, nr_path, nr_table);
+	nr_table_header = register_net_sysctl(&init_net, "net/netrom", nr_table);
 }
 
 void nr_unregister_sysctl(void)
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
index aa55db5..696348f 100644
--- a/net/phonet/sysctl.c
+++ b/net/phonet/sysctl.c
@@ -98,15 +98,9 @@ static struct ctl_table phonet_table[] = {
 	{ }
 };
 
-static struct ctl_path phonet_ctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "phonet", },
-	{ },
-};
-
 int __init phonet_sysctl_init(void)
 {
-	phonet_table_hrd = register_net_sysctl_table(&init_net, phonet_ctl_path, phonet_table);
+	phonet_table_hrd = register_net_sysctl(&init_net, "net/phonet", phonet_table);
 	return phonet_table_hrd == NULL ? -ENOMEM : 0;
 }
 
diff --git a/net/rds/ib_sysctl.c b/net/rds/ib_sysctl.c
index 0fef3e1..7e643ba 100644
--- a/net/rds/ib_sysctl.c
+++ b/net/rds/ib_sysctl.c
@@ -106,13 +106,6 @@ static ctl_table rds_ib_sysctl_table[] = {
 	{ }
 };
 
-static struct ctl_path rds_ib_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rds", },
-	{ .procname = "ib", },
-	{ }
-};
-
 void rds_ib_sysctl_exit(void)
 {
 	if (rds_ib_sysctl_hdr)
@@ -121,7 +114,7 @@ void rds_ib_sysctl_exit(void)
 
 int rds_ib_sysctl_init(void)
 {
-	rds_ib_sysctl_hdr = register_net_sysctl_table(&init_net, rds_ib_sysctl_path, rds_ib_sysctl_table);
+	rds_ib_sysctl_hdr = register_net_sysctl(&init_net, "net/rds/ib", rds_ib_sysctl_table);
 	if (!rds_ib_sysctl_hdr)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/iw_sysctl.c b/net/rds/iw_sysctl.c
index bcfe36d..5d5ebd5 100644
--- a/net/rds/iw_sysctl.c
+++ b/net/rds/iw_sysctl.c
@@ -109,13 +109,6 @@ static ctl_table rds_iw_sysctl_table[] = {
 	{ }
 };
 
-static struct ctl_path rds_iw_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rds", },
-	{ .procname = "iw", },
-	{ }
-};
-
 void rds_iw_sysctl_exit(void)
 {
 	if (rds_iw_sysctl_hdr)
@@ -124,7 +117,7 @@ void rds_iw_sysctl_exit(void)
 
 int rds_iw_sysctl_init(void)
 {
-	rds_iw_sysctl_hdr = register_net_sysctl_table(&init_net, rds_iw_sysctl_path, rds_iw_sysctl_table);
+	rds_iw_sysctl_hdr = register_net_sysctl(&init_net, "net/rds/iw", rds_iw_sysctl_table);
 	if (!rds_iw_sysctl_hdr)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rds/sysctl.c b/net/rds/sysctl.c
index 30354b8..907214b 100644
--- a/net/rds/sysctl.c
+++ b/net/rds/sysctl.c
@@ -92,13 +92,6 @@ static ctl_table rds_sysctl_rds_table[] = {
 	{ }
 };
 
-static struct ctl_path rds_sysctl_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rds", },
-	{ }
-};
-
-
 void rds_sysctl_exit(void)
 {
 	if (rds_sysctl_reg_table)
@@ -110,7 +103,7 @@ int rds_sysctl_init(void)
 	rds_sysctl_reconnect_min = msecs_to_jiffies(1);
 	rds_sysctl_reconnect_min_jiffies = rds_sysctl_reconnect_min;
 
-	rds_sysctl_reg_table = register_net_sysctl_table(&init_net, rds_sysctl_path, rds_sysctl_rds_table);
+	rds_sysctl_reg_table = register_net_sysctl(&init_net,"net/rds", rds_sysctl_rds_table);
 	if (!rds_sysctl_reg_table)
 		return -ENOMEM;
 	return 0;
diff --git a/net/rose/sysctl_net_rose.c b/net/rose/sysctl_net_rose.c
index 02b7397..94ca9c2 100644
--- a/net/rose/sysctl_net_rose.c
+++ b/net/rose/sysctl_net_rose.c
@@ -118,15 +118,9 @@ static ctl_table rose_table[] = {
 	{ }
 };
 
-static struct ctl_path rose_path[] = {
-	{ .procname = "net", },
-	{ .procname = "rose", },
-	{ }
-};
-
 void __init rose_register_sysctl(void)
 {
-	rose_table_header = register_net_sysctl_table(&init_net, rose_path, rose_table);
+	rose_table_header = register_net_sysctl(&init_net, "net/rose", rose_table);
 }
 
 void rose_unregister_sysctl(void)
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 1e385b4..e5fe639 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -275,18 +275,12 @@ static ctl_table sctp_table[] = {
 	{ /* sentinel */ }
 };
 
-static struct ctl_path sctp_path[] = {
-	{ .procname = "net", },
-	{ .procname = "sctp", },
-	{ }
-};
-
 static struct ctl_table_header * sctp_sysctl_header;
 
 /* Sysctl registration.  */
 void sctp_sysctl_register(void)
 {
-	sctp_sysctl_header = register_net_sysctl_table(&init_net, sctp_path, sctp_table);
+	sctp_sysctl_header = register_net_sysctl(&init_net, "net/sctp", sctp_table);
 }
 
 /* Sysctl deregistration.  */
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 4f6979c..b34b5b9 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -26,12 +26,6 @@ static ctl_table unix_table[] = {
 	{ }
 };
 
-static struct ctl_path unix_path[] = {
-	{ .procname = "net", },
-	{ .procname = "unix", },
-	{ },
-};
-
 int __net_init unix_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
@@ -41,7 +35,7 @@ int __net_init unix_sysctl_register(struct net *net)
 		goto err_alloc;
 
 	table[0].data = &net->unx.sysctl_max_dgram_qlen;
-	net->unx.ctl = register_net_sysctl_table(net, unix_path, table);
+	net->unx.ctl = register_net_sysctl(net, "net/unix", table);
 	if (net->unx.ctl == NULL)
 		goto err_reg;
 
diff --git a/net/x25/sysctl_net_x25.c b/net/x25/sysctl_net_x25.c
index 08337cb..4323952 100644
--- a/net/x25/sysctl_net_x25.c
+++ b/net/x25/sysctl_net_x25.c
@@ -73,15 +73,9 @@ static struct ctl_table x25_table[] = {
 	{ 0, },
 };
 
-static struct ctl_path x25_path[] = {
-	{ .procname = "net", },
-	{ .procname = "x25", },
-	{ }
-};
-
 void __init x25_register_sysctl(void)
 {
-	x25_table_header = register_net_sysctl_table(&init_net, x25_path, x25_table);
+	x25_table_header = register_net_sysctl(&init_net, "net/x25", x25_table);
 }
 
 void x25_unregister_sysctl(void)
diff --git a/net/xfrm/xfrm_sysctl.c b/net/xfrm/xfrm_sysctl.c
index 05640bc..380976f 100644
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -54,7 +54,7 @@ int __net_init xfrm_sysctl_init(struct net *net)
 	table[2].data = &net->xfrm.sysctl_larval_drop;
 	table[3].data = &net->xfrm.sysctl_acq_expires;
 
-	net->xfrm.sysctl_hdr = register_net_sysctl_table(net, net_core_path, table);
+	net->xfrm.sysctl_hdr = register_net_sysctl(net, "net/core", table);
 	if (!net->xfrm.sysctl_hdr)
 		goto out_register;
 	return 0;
-- 
1.7.2.5
