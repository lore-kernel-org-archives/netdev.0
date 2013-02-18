From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next 1/4] net: proc: change proc_net_fops_create to proc_create
Date: Mon, 18 Feb 2013 19:34:54 +0800
Message-ID: <1361187297-2527-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, davem@davemloft.net,
	containers@lists.linux-foundation.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:15552 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753122Ab3BRLea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 06:34:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now, some modules such as bonding use proc_create
to create proc entries under /proc/net/, and other modules
such as ipv4 use proc_net_fops_create.

It looks a little chaos.this patch changes all of
proc_net_fops_create to proc_create. we can remove
proc_net_fops_create after this patch.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/connector/connector.c                         |  2 +-
 drivers/net/hamradio/bpqether.c                       |  3 ++-
 drivers/net/hamradio/scc.c                            |  2 +-
 drivers/net/hamradio/yam.c                            |  2 +-
 drivers/net/ppp/pppoe.c                               |  2 +-
 net/ax25/af_ax25.c                                    |  7 ++++---
 net/bluetooth/af_bluetooth.c                          |  2 +-
 net/core/dev.c                                        |  7 ++++---
 net/core/dev_addr_lists.c                             |  2 +-
 net/core/sock.c                                       |  2 +-
 net/dccp/probe.c                                      |  2 +-
 net/decnet/af_decnet.c                                |  2 +-
 net/decnet/dn_dev.c                                   |  2 +-
 net/decnet/dn_neigh.c                                 |  3 ++-
 net/decnet/dn_route.c                                 |  3 ++-
 net/ipv4/arp.c                                        |  2 +-
 net/ipv4/fib_trie.c                                   |  8 ++++----
 net/ipv4/igmp.c                                       |  5 +++--
 net/ipv4/ipconfig.c                                   |  2 +-
 net/ipv4/ipmr.c                                       |  4 ++--
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |  6 +++---
 net/ipv4/ping.c                                       |  2 +-
 net/ipv4/proc.c                                       |  7 ++++---
 net/ipv4/raw.c                                        |  2 +-
 net/ipv4/route.c                                      |  4 ++--
 net/ipv4/tcp_probe.c                                  |  2 +-
 net/ipv6/addrconf.c                                   |  2 +-
 net/ipv6/anycast.c                                    |  2 +-
 net/ipv6/ip6_flowlabel.c                              |  4 ++--
 net/ipv6/ip6mr.c                                      |  4 ++--
 net/ipv6/mcast.c                                      |  6 +++---
 net/ipv6/proc.c                                       |  6 +++---
 net/ipv6/raw.c                                        |  2 +-
 net/ipv6/route.c                                      |  4 ++--
 net/key/af_key.c                                      |  2 +-
 net/l2tp/l2tp_ppp.c                                   |  3 ++-
 net/netfilter/ipvs/ip_vs_app.c                        |  2 +-
 net/netfilter/ipvs/ip_vs_conn.c                       |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c                        |  8 ++++----
 net/netfilter/nf_conntrack_expect.c                   |  3 ++-
 net/netfilter/nf_conntrack_standalone.c               |  2 +-
 net/netlink/af_netlink.c                              |  2 +-
 net/netrom/af_netrom.c                                |  6 +++---
 net/packet/af_packet.c                                |  2 +-
 net/phonet/pn_dev.c                                   |  4 ++--
 net/rose/af_rose.c                                    | 11 +++++++----
 net/rxrpc/af_rxrpc.c                                  |  5 +++--
 net/sched/sch_api.c                                   |  2 +-
 net/sctp/probe.c                                      |  4 ++--
 net/unix/af_unix.c                                    |  2 +-
 net/wireless/wext-proc.c                              |  3 ++-
 net/xfrm/xfrm_proc.c                                  |  4 ++--
 52 files changed, 100 insertions(+), 86 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 7b69591..ed17a57 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -276,7 +276,7 @@ static int cn_init(void)
 
 	cn_already_initialized = 1;
 
-	proc_net_fops_create(&init_net, "connector", S_IRUGO, &cn_file_ops);
+	proc_create("connector", S_IRUGO, init_net.proc_net, &cn_file_ops);
 
 	return 0;
 }
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index c2e5497..61f2884 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -586,7 +586,8 @@ static int bpq_device_event(struct notifier_block *this,unsigned long event, voi
 static int __init bpq_init_driver(void)
 {
 #ifdef CONFIG_PROC_FS
-	if (!proc_net_fops_create(&init_net, "bpqether", S_IRUGO, &bpq_info_fops)) {
+	if (!proc_create("bpqether", S_IRUGO, init_net.proc_net,
+			 &bpq_info_fops)) {
 		printk(KERN_ERR
 			"bpq: cannot create /proc/net/bpqether entry.\n");
 		return -ENOENT;
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 1b4a47b..cab13f4 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -2118,7 +2118,7 @@ static int __init scc_init_driver (void)
 	}
 	rtnl_unlock();
 
-	proc_net_fops_create(&init_net, "z8530drv", 0, &scc_net_seq_fops);
+	proc_create("z8530drv", 0, init_net.proc_net, &scc_net_seq_fops);
 
 	return 0;
 }
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index c6645f1..92847d2 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1167,7 +1167,7 @@ static int __init yam_init_driver(void)
 	yam_timer.expires = jiffies + HZ / 100;
 	add_timer(&yam_timer);
 
-	proc_net_fops_create(&init_net, "yam", S_IRUGO, &yam_info_fops);
+	proc_create("yam", S_IRUGO, init_net.proc_net, &yam_info_fops);
 	return 0;
  error:
 	while (--i >= 0) {
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 20f31d0..d7fa96c 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -1134,7 +1134,7 @@ static __net_init int pppoe_init_net(struct net *net)
 
 	rwlock_init(&pn->hash_lock);
 
-	pde = proc_net_fops_create(net, "pppoe", S_IRUGO, &pppoe_seq_fops);
+	pde = proc_create("pppoe", S_IRUGO, net->proc_net, &pppoe_seq_fops);
 #ifdef CONFIG_PROC_FS
 	if (!pde)
 		return -ENOMEM;
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index 779095d..b6ccbea 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -1992,9 +1992,10 @@ static int __init ax25_init(void)
 	dev_add_pack(&ax25_packet_type);
 	register_netdevice_notifier(&ax25_dev_notifier);
 
-	proc_net_fops_create(&init_net, "ax25_route", S_IRUGO, &ax25_route_fops);
-	proc_net_fops_create(&init_net, "ax25", S_IRUGO, &ax25_info_fops);
-	proc_net_fops_create(&init_net, "ax25_calls", S_IRUGO, &ax25_uid_fops);
+	proc_create("ax25_route", S_IRUGO, init_net.proc_net,
+		    &ax25_route_fops);
+	proc_create("ax25", S_IRUGO, init_net.proc_net, &ax25_info_fops);
+	proc_create("ax25_calls", S_IRUGO, init_net.proc_net, &ax25_uid_fops);
 out:
 	return rc;
 }
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 5355df6..8412b63 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -641,7 +641,7 @@ int bt_procfs_init(struct module* module, struct net *net, const char *name,
 	sk_list->fops.llseek    = seq_lseek;
 	sk_list->fops.release   = seq_release_private;
 
-	pde = proc_net_fops_create(net, name, 0, &sk_list->fops);
+	pde = proc_create(name, 0, net->proc_net, &sk_list->fops);
 	if (!pde)
 		return -ENOMEM;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 6ad3789..73e0565 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4722,11 +4722,12 @@ static int __net_init dev_proc_net_init(struct net *net)
 {
 	int rc = -ENOMEM;
 
-	if (!proc_net_fops_create(net, "dev", S_IRUGO, &dev_seq_fops))
+	if (!proc_create("dev", S_IRUGO, net->proc_net, &dev_seq_fops))
 		goto out;
-	if (!proc_net_fops_create(net, "softnet_stat", S_IRUGO, &softnet_seq_fops))
+	if (!proc_create("softnet_stat", S_IRUGO, net->proc_net,
+			 &softnet_seq_fops))
 		goto out_dev;
-	if (!proc_net_fops_create(net, "ptype", S_IRUGO, &ptype_seq_fops))
+	if (!proc_create("ptype", S_IRUGO, net->proc_net, &ptype_seq_fops))
 		goto out_softnet;
 
 	if (wext_proc_init(net))
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index b079c7b..7c62ec4 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -780,7 +780,7 @@ static const struct file_operations dev_mc_seq_fops = {
 
 static int __net_init dev_mc_net_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "dev_mcast", 0, &dev_mc_seq_fops))
+	if (!proc_create("dev_mcast", 0, net->proc_net, &dev_mc_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/core/sock.c b/net/core/sock.c
index f1e14e2..b4d562ef 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2836,7 +2836,7 @@ static const struct file_operations proto_seq_fops = {
 
 static __net_init int proto_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(net, "protocols", S_IRUGO, &proto_seq_fops))
+	if (!proc_create("protocols", S_IRUGO, net->proc_net, &proto_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index 0a8d6eb..d183589 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -171,7 +171,7 @@ static __init int dccpprobe_init(void)
 	spin_lock_init(&dccpw.lock);
 	if (kfifo_alloc(&dccpw.fifo, bufsize, GFP_KERNEL))
 		return ret;
-	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &dccpprobe_fops))
+	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &dccpprobe_fops))
 		goto err0;
 
 	ret = setup_jprobe();
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 64d9843..f916013 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2384,7 +2384,7 @@ static int __init decnet_init(void)
 	dev_add_pack(&dn_dix_packet_type);
 	register_netdevice_notifier(&dn_dev_notifier);
 
-	proc_net_fops_create(&init_net, "decnet", S_IRUGO, &dn_socket_seq_fops);
+	proc_create("decnet", S_IRUGO, init_net.proc_net, &dn_socket_seq_fops);
 	dn_register_sysctl();
 out:
 	return rc;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index e47ba9f..a04894a 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1412,7 +1412,7 @@ void __init dn_dev_init(void)
 	rtnl_register(PF_DECnet, RTM_DELADDR, dn_nl_deladdr, NULL, NULL);
 	rtnl_register(PF_DECnet, RTM_GETADDR, NULL, dn_nl_dump_ifaddr, NULL);
 
-	proc_net_fops_create(&init_net, "decnet_dev", S_IRUGO, &dn_dev_seq_fops);
+	proc_create("decnet_dev", S_IRUGO, init_net.proc_net, &dn_dev_seq_fops);
 
 #ifdef CONFIG_SYSCTL
 	{
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 856636a..f3408f3 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -590,7 +590,8 @@ static const struct file_operations dn_neigh_seq_fops = {
 void __init dn_neigh_init(void)
 {
 	neigh_table_init(&dn_neigh_table);
-	proc_net_fops_create(&init_net, "decnet_neigh", S_IRUGO, &dn_neigh_seq_fops);
+	proc_create("decnet_neigh", S_IRUGO, init_net.proc_net,
+		    &dn_neigh_seq_fops);
 }
 
 void __exit dn_neigh_cleanup(void)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 1550028..8afb257 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1901,7 +1901,8 @@ void __init dn_route_init(void)
 
 	dn_dst_ops.gc_thresh = (dn_rt_hash_mask + 1);
 
-	proc_net_fops_create(&init_net, "decnet_cache", S_IRUGO, &dn_rt_cache_seq_fops);
+	proc_create("decnet_cache", S_IRUGO, init_net.proc_net,
+		    &dn_rt_cache_seq_fops);
 
 #ifdef CONFIG_DECNET_ROUTER
 	rtnl_register(PF_DECnet, RTM_GETROUTE, dn_cache_getroute,
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ded146b..b04c114 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1405,7 +1405,7 @@ static const struct file_operations arp_seq_fops = {
 
 static int __net_init arp_net_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "arp", S_IRUGO, &arp_seq_fops))
+	if (!proc_create("arp", S_IRUGO, net->proc_net, &arp_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 31d771c..67c1d4b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2607,14 +2607,14 @@ static const struct file_operations fib_route_fops = {
 
 int __net_init fib_proc_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "fib_trie", S_IRUGO, &fib_trie_fops))
+	if (!proc_create("fib_trie", S_IRUGO, net->proc_net, &fib_trie_fops))
 		goto out1;
 
-	if (!proc_net_fops_create(net, "fib_triestat", S_IRUGO,
-				  &fib_triestat_fops))
+	if (!proc_create("fib_triestat", S_IRUGO, net->proc_net,
+			 &fib_triestat_fops))
 		goto out2;
 
-	if (!proc_net_fops_create(net, "route", S_IRUGO, &fib_route_fops))
+	if (!proc_create("route", S_IRUGO, net->proc_net, &fib_route_fops))
 		goto out3;
 
 	return 0;
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 736ab70..be85628 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2646,10 +2646,11 @@ static int __net_init igmp_net_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_net_fops_create(net, "igmp", S_IRUGO, &igmp_mc_seq_fops);
+	pde = proc_create("igmp", S_IRUGO, net->proc_net, &igmp_mc_seq_fops);
 	if (!pde)
 		goto out_igmp;
-	pde = proc_net_fops_create(net, "mcfilter", S_IRUGO, &igmp_mcf_seq_fops);
+	pde = proc_create("mcfilter", S_IRUGO, net->proc_net,
+			  &igmp_mcf_seq_fops);
 	if (!pde)
 		goto out_mcfilter;
 	return 0;
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index a2e50ae..98cbc68 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1394,7 +1394,7 @@ static int __init ip_auto_config(void)
 	unsigned int i;
 
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "pnp", S_IRUGO, &pnp_seq_fops);
+	proc_create("pnp", S_IRUGO, init_net.proc_net, &pnp_seq_fops);
 #endif /* CONFIG_PROC_FS */
 
 	if (!ic_enable)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7085b9b..160a8b8 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2703,9 +2703,9 @@ static int __net_init ipmr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 	err = -ENOMEM;
-	if (!proc_net_fops_create(net, "ip_mr_vif", 0, &ipmr_vif_fops))
+	if (!proc_create("ip_mr_vif", 0, net->proc_net, &ipmr_vif_fops))
 		goto proc_vif_fail;
-	if (!proc_net_fops_create(net, "ip_mr_cache", 0, &ipmr_mfc_fops))
+	if (!proc_create("ip_mr_cache", 0, net->proc_net, &ipmr_mfc_fops))
 		goto proc_cache_fail;
 #endif
 	return 0;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 9682b36..48bc681 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -417,12 +417,12 @@ static int __net_init ip_conntrack_net_init(struct net *net)
 {
 	struct proc_dir_entry *proc, *proc_exp, *proc_stat;
 
-	proc = proc_net_fops_create(net, "ip_conntrack", 0440, &ct_file_ops);
+	proc = proc_create("ip_conntrack", 0440, net->proc_net, &ct_file_ops);
 	if (!proc)
 		goto err1;
 
-	proc_exp = proc_net_fops_create(net, "ip_conntrack_expect", 0440,
-					&ip_exp_file_ops);
+	proc_exp = proc_create("ip_conntrack_expect", 0440, net->proc_net,
+			       &ip_exp_file_ops);
 	if (!proc_exp)
 		goto err2;
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 6f9c072..fc62a13 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -889,7 +889,7 @@ static int ping_proc_register(struct net *net)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	p = proc_net_fops_create(net, "icmp", S_IRUGO, &ping_seq_fops);
+	p = proc_create("icmp", S_IRUGO, net->proc_net, &ping_seq_fops);
 	if (!p)
 		rc = -ENOMEM;
 	return rc;
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 8de53e1..954bcd4 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -471,11 +471,12 @@ static const struct file_operations netstat_seq_fops = {
 
 static __net_init int ip_proc_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(net, "sockstat", S_IRUGO, &sockstat_seq_fops))
+	if (!proc_create("sockstat", S_IRUGO, net->proc_net,
+			 &sockstat_seq_fops))
 		goto out_sockstat;
-	if (!proc_net_fops_create(net, "netstat", S_IRUGO, &netstat_seq_fops))
+	if (!proc_create("netstat", S_IRUGO, net->proc_net, &netstat_seq_fops))
 		goto out_netstat;
-	if (!proc_net_fops_create(net, "snmp", S_IRUGO, &snmp_seq_fops))
+	if (!proc_create("snmp", S_IRUGO, net->proc_net, &snmp_seq_fops))
 		goto out_snmp;
 
 	return 0;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 6f08991..5043a7d 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -1050,7 +1050,7 @@ static const struct file_operations raw_seq_fops = {
 
 static __net_init int raw_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(net, "raw", S_IRUGO, &raw_seq_fops))
+	if (!proc_create("raw", S_IRUGO, net->proc_net, &raw_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a0fcc47..3bdd1b1 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -384,8 +384,8 @@ static int __net_init ip_rt_do_proc_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_net_fops_create(net, "rt_cache", S_IRUGO,
-			&rt_cache_seq_fops);
+	pde = proc_create("rt_cache", S_IRUGO, net->proc_net,
+			  &rt_cache_seq_fops);
 	if (!pde)
 		goto err1;
 
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 4526fe6..1e3a1fb 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -234,7 +234,7 @@ static __init int tcpprobe_init(void)
 	if (!tcp_probe.log)
 		goto err0;
 
-	if (!proc_net_fops_create(&init_net, procname, S_IRUSR, &tcpprobe_fops))
+	if (!proc_create(procname, S_IRUSR, init_net.proc_net, &tcpprobe_fops))
 		goto err0;
 
 	ret = register_jprobe(&tcp_jprobe);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 86c235d..bad7108 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3325,7 +3325,7 @@ static const struct file_operations if6_fops = {
 
 static int __net_init if6_proc_net_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "if_inet6", S_IRUGO, &if6_fops))
+	if (!proc_create("if_inet6", S_IRUGO, net->proc_net, &if6_fops))
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 921b8b3..5a8c009 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -509,7 +509,7 @@ static const struct file_operations ac6_seq_fops = {
 
 int __net_init ac6_proc_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "anycast6", S_IRUGO, &ac6_seq_fops))
+	if (!proc_create("anycast6", S_IRUGO, net->proc_net, &ac6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index a7da2f4..900d79e 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -806,8 +806,8 @@ static const struct file_operations ip6fl_seq_fops = {
 
 static int __net_init ip6_flowlabel_proc_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "ip6_flowlabel",
-				  S_IRUGO, &ip6fl_seq_fops))
+	if (!proc_create("ip6_flowlabel", S_IRUGO, net->proc_net,
+			 &ip6fl_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 351ce98..fdfd96d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1359,9 +1359,9 @@ static int __net_init ip6mr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 	err = -ENOMEM;
-	if (!proc_net_fops_create(net, "ip6_mr_vif", 0, &ip6mr_vif_fops))
+	if (!proc_create("ip6_mr_vif", 0, net->proc_net, &ip6mr_vif_fops))
 		goto proc_vif_fail;
-	if (!proc_net_fops_create(net, "ip6_mr_cache", 0, &ip6mr_mfc_fops))
+	if (!proc_create("ip6_mr_cache", 0, net->proc_net, &ip6mr_mfc_fops))
 		goto proc_cache_fail;
 #endif
 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 3a2849f..de7d4b9 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2599,10 +2599,10 @@ static int __net_init igmp6_proc_init(struct net *net)
 	int err;
 
 	err = -ENOMEM;
-	if (!proc_net_fops_create(net, "igmp6", S_IRUGO, &igmp6_mc_seq_fops))
+	if (!proc_create("igmp6", S_IRUGO, net->proc_net, &igmp6_mc_seq_fops))
 		goto out;
-	if (!proc_net_fops_create(net, "mcfilter6", S_IRUGO,
-				  &igmp6_mcf_seq_fops))
+	if (!proc_create("mcfilter6", S_IRUGO, net->proc_net,
+			 &igmp6_mcf_seq_fops))
 		goto out_proc_net_igmp6;
 
 	err = 0;
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 745a320..cf8901d 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -295,11 +295,11 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
 
 static int __net_init ipv6_proc_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(net, "sockstat6", S_IRUGO,
-			&sockstat6_seq_fops))
+	if (!proc_create("sockstat6", S_IRUGO, net->proc_net,
+			 &sockstat6_seq_fops))
 		return -ENOMEM;
 
-	if (!proc_net_fops_create(net, "snmp6", S_IRUGO, &snmp6_seq_fops))
+	if (!proc_create("snmp6", S_IRUGO, net->proc_net, &snmp6_seq_fops))
 		goto proc_snmp6_fail;
 
 	net->mib.proc_net_devsnmp6 = proc_mkdir("dev_snmp6", net->proc_net);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 70fa814..ff42fb3 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1292,7 +1292,7 @@ static const struct file_operations raw6_seq_fops = {
 
 static int __net_init raw6_init_net(struct net *net)
 {
-	if (!proc_net_fops_create(net, "raw6", S_IRUGO, &raw6_seq_fops))
+	if (!proc_create("raw6", S_IRUGO, net->proc_net, &raw6_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f3328bc..e1228d8 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2995,8 +2995,8 @@ static void __net_exit ip6_route_net_exit(struct net *net)
 static int __net_init ip6_route_net_init_late(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(net, "ipv6_route", 0, &ipv6_route_proc_fops);
-	proc_net_fops_create(net, "rt6_stats", S_IRUGO, &rt6_stats_seq_fops);
+	proc_create("ipv6_route", 0, net->proc_net, &ipv6_route_proc_fops);
+	proc_create("rt6_stats", S_IRUGO, net->proc_net, &rt6_stats_seq_fops);
 #endif
 	return 0;
 }
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 7b3ba32..021a429 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3740,7 +3740,7 @@ static int __net_init pfkey_init_proc(struct net *net)
 {
 	struct proc_dir_entry *e;
 
-	e = proc_net_fops_create(net, "pfkey", 0, &pfkey_proc_ops);
+	e = proc_create("pfkey", 0, net->proc_net, &pfkey_proc_ops);
 	if (e == NULL)
 		return -ENOMEM;
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 716605c..3ca270b 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1783,7 +1783,8 @@ static __net_init int pppol2tp_init_net(struct net *net)
 	struct proc_dir_entry *pde;
 	int err = 0;
 
-	pde = proc_net_fops_create(net, "pppol2tp", S_IRUGO, &pppol2tp_proc_fops);
+	pde = proc_create("pppol2tp", S_IRUGO, net->proc_net,
+			  &pppol2tp_proc_fops);
 	if (!pde) {
 		err = -ENOMEM;
 		goto out;
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 9713e6e..1db8a25 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -605,7 +605,7 @@ int __net_init ip_vs_app_net_init(struct net *net)
 	struct netns_ipvs *ipvs = net_ipvs(net);
 
 	INIT_LIST_HEAD(&ipvs->app_list);
-	proc_net_fops_create(net, "ip_vs_app", 0, &ip_vs_app_fops);
+	proc_create("ip_vs_app", 0, net->proc_net, &ip_vs_app_fops);
 	return 0;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 68e368a..91ae112 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1291,8 +1291,8 @@ int __net_init ip_vs_conn_net_init(struct net *net)
 
 	atomic_set(&ipvs->conn_count, 0);
 
-	proc_net_fops_create(net, "ip_vs_conn", 0, &ip_vs_conn_fops);
-	proc_net_fops_create(net, "ip_vs_conn_sync", 0, &ip_vs_conn_sync_fops);
+	proc_create("ip_vs_conn", 0, net->proc_net, &ip_vs_conn_fops);
+	proc_create("ip_vs_conn_sync", 0, net->proc_net, &ip_vs_conn_sync_fops);
 	return 0;
 }
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index ec664cb..7d69181 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3800,10 +3800,10 @@ int __net_init ip_vs_control_net_init(struct net *net)
 
 	spin_lock_init(&ipvs->tot_stats.lock);
 
-	proc_net_fops_create(net, "ip_vs", 0, &ip_vs_info_fops);
-	proc_net_fops_create(net, "ip_vs_stats", 0, &ip_vs_stats_fops);
-	proc_net_fops_create(net, "ip_vs_stats_percpu", 0,
-			     &ip_vs_stats_percpu_fops);
+	proc_create("ip_vs", 0, net->proc_net, &ip_vs_info_fops);
+	proc_create("ip_vs_stats", 0, net->proc_net, &ip_vs_stats_fops);
+	proc_create("ip_vs_stats_percpu", 0, net->proc_net,
+		    &ip_vs_stats_percpu_fops);
 
 	if (ip_vs_control_net_init_sysctl(net))
 		goto err;
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index bdd3418..4c15f8d 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -571,7 +571,8 @@ static int exp_proc_init(struct net *net)
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
 	struct proc_dir_entry *proc;
 
-	proc = proc_net_fops_create(net, "nf_conntrack_expect", 0440, &exp_file_ops);
+	proc = proc_create("nf_conntrack_expect", 0440, net->proc_net,
+			   &exp_file_ops);
 	if (!proc)
 		return -ENOMEM;
 #endif /* CONFIG_NF_CONNTRACK_PROCFS */
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 7936bf7..bee9aec 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -366,7 +366,7 @@ static int nf_conntrack_standalone_init_proc(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_net_fops_create(net, "nf_conntrack", 0440, &ct_file_ops);
+	pde = proc_create("nf_conntrack", 0440, net->proc_net, &ct_file_ops);
 	if (!pde)
 		goto out_nf_conntrack;
 
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 74827e3..50084c4 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2145,7 +2145,7 @@ static const struct net_proto_family netlink_family_ops = {
 static int __net_init netlink_net_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	if (!proc_net_fops_create(net, "netlink", 0, &netlink_seq_fops))
+	if (!proc_create("netlink", 0, net->proc_net, &netlink_seq_fops))
 		return -ENOMEM;
 #endif
 	return 0;
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 7261eb8..71b8613 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1452,9 +1452,9 @@ static int __init nr_proto_init(void)
 
 	nr_loopback_init();
 
-	proc_net_fops_create(&init_net, "nr", S_IRUGO, &nr_info_fops);
-	proc_net_fops_create(&init_net, "nr_neigh", S_IRUGO, &nr_neigh_fops);
-	proc_net_fops_create(&init_net, "nr_nodes", S_IRUGO, &nr_nodes_fops);
+	proc_create("nr", S_IRUGO, init_net.proc_net, &nr_info_fops);
+	proc_create("nr_neigh", S_IRUGO, init_net.proc_net, &nr_neigh_fops);
+	proc_create("nr_nodes", S_IRUGO, init_net.proc_net, &nr_nodes_fops);
 out:
 	return rc;
 fail:
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c111bd0..b7b2d56 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3828,7 +3828,7 @@ static int __net_init packet_net_init(struct net *net)
 	mutex_init(&net->packet.sklist_lock);
 	INIT_HLIST_HEAD(&net->packet.sklist);
 
-	if (!proc_net_fops_create(net, "packet", 0, &packet_seq_fops))
+	if (!proc_create("packet", 0, net->proc_net, &packet_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 5bf6341..0e527c9 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -320,7 +320,7 @@ static int __net_init phonet_init_net(struct net *net)
 {
 	struct phonet_net *pnn = phonet_pernet(net);
 
-	if (!proc_net_fops_create(net, "phonet", 0, &pn_sock_seq_fops))
+	if (!proc_create("phonet", 0, net->proc_net, &pn_sock_seq_fops))
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&pnn->pndevs.list);
@@ -348,7 +348,7 @@ int __init phonet_device_init(void)
 	if (err)
 		return err;
 
-	proc_net_fops_create(&init_net, "pnresource", 0, &pn_res_seq_fops);
+	proc_create("pnresource", 0, init_net.proc_net, &pn_res_seq_fops);
 	register_netdevice_notifier(&phonet_device_notifier);
 	err = phonet_netlink_register();
 	if (err)
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index c4719ce..5fd8aac 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1575,10 +1575,13 @@ static int __init rose_proto_init(void)
 
 	rose_add_loopback_neigh();
 
-	proc_net_fops_create(&init_net, "rose", S_IRUGO, &rose_info_fops);
-	proc_net_fops_create(&init_net, "rose_neigh", S_IRUGO, &rose_neigh_fops);
-	proc_net_fops_create(&init_net, "rose_nodes", S_IRUGO, &rose_nodes_fops);
-	proc_net_fops_create(&init_net, "rose_routes", S_IRUGO, &rose_routes_fops);
+	proc_create("rose", S_IRUGO, init_net.proc_net, &rose_info_fops);
+	proc_create("rose_neigh", S_IRUGO, init_net.proc_net,
+		    &rose_neigh_fops);
+	proc_create("rose_nodes", S_IRUGO, init_net.proc_net,
+		    &rose_nodes_fops);
+	proc_create("rose_routes", S_IRUGO, init_net.proc_net,
+		    &rose_routes_fops);
 out:
 	return rc;
 fail:
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 5b0fd29..59c7c7d 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -839,8 +839,9 @@ static int __init af_rxrpc_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc_net_fops_create(&init_net, "rxrpc_calls", 0, &rxrpc_call_seq_fops);
-	proc_net_fops_create(&init_net, "rxrpc_conns", 0, &rxrpc_connection_seq_fops);
+	proc_create("rxrpc_calls", 0, init_net.proc_net, &rxrpc_call_seq_fops);
+	proc_create("rxrpc_conns", 0, init_net.proc_net,
+		    &rxrpc_connection_seq_fops);
 #endif
 	return 0;
 
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index fe1ba54..d8cf7d3 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1768,7 +1768,7 @@ static int __net_init psched_net_init(struct net *net)
 {
 	struct proc_dir_entry *e;
 
-	e = proc_net_fops_create(net, "psched", 0, &psched_fops);
+	e = proc_create("psched", 0, net->proc_net, &psched_fops);
 	if (e == NULL)
 		return -ENOMEM;
 
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index 261b7b9..dd507f5 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -195,8 +195,8 @@ static __init int sctpprobe_init(void)
 	if (kfifo_alloc(&sctpw.fifo, bufsize, GFP_KERNEL))
 		return ret;
 
-	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
-				  &sctpprobe_fops))
+	if (!proc_create(procname, S_IRUSR, init_net.proc_net,
+			 &sctpprobe_fops))
 		goto free_kfifo;
 
 	ret = register_jprobe(&sctp_recv_probe);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0c61236..0c479b6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2402,7 +2402,7 @@ static int __net_init unix_net_init(struct net *net)
 		goto out;
 
 #ifdef CONFIG_PROC_FS
-	if (!proc_net_fops_create(net, "unix", 0, &unix_seq_fops)) {
+	if (!proc_create("unix", 0, net->proc_net, &unix_seq_fops)) {
 		unix_sysctl_unregister(net);
 		goto out;
 	}
diff --git a/net/wireless/wext-proc.c b/net/wireless/wext-proc.c
index 8bafa31..00fc5bb 100644
--- a/net/wireless/wext-proc.c
+++ b/net/wireless/wext-proc.c
@@ -143,7 +143,8 @@ static const struct file_operations wireless_seq_fops = {
 int __net_init wext_proc_init(struct net *net)
 {
 	/* Create /proc/net/wireless entry */
-	if (!proc_net_fops_create(net, "wireless", S_IRUGO, &wireless_seq_fops))
+	if (!proc_create("wireless", S_IRUGO, net->proc_net,
+			 &wireless_seq_fops))
 		return -ENOMEM;
 
 	return 0;
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 6039038..9abe14f 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -74,8 +74,8 @@ static const struct file_operations xfrm_statistics_seq_fops = {
 
 int __net_init xfrm_proc_init(struct net *net)
 {
-	if (!proc_net_fops_create(net, "xfrm_stat", S_IRUGO,
-				  &xfrm_statistics_seq_fops))
+	if (!proc_create("xfrm_stat", S_IRUGO, net->proc_net,
+			 &xfrm_statistics_seq_fops))
 		return -ENOMEM;
 	return 0;
 }
-- 
1.7.11.7
