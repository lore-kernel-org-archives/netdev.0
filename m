From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next 3/4] net: proc: change proc_net_remove to remove_proc_entry
Date: Mon, 18 Feb 2013 19:34:56 +0800
Message-ID: <1361187297-2527-3-git-send-email-gaofeng@cn.fujitsu.com>
References: <1361187297-2527-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, davem@davemloft.net,
	containers@lists.linux-foundation.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:9211 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753117Ab3BRLea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 06:34:30 -0500
In-Reply-To: <1361187297-2527-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

proc_net_remove is only used to remove proc entries
that under /proc/net,it's not a general function for
removing proc entries of netns. if we want to remove
some proc entries which under /proc/net/stat/, we still
need to call remove_proc_entry.

this patch use remove_proc_entry to replace proc_net_remove.
we can remove proc_net_remove after this patch.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 drivers/connector/connector.c                         |  2 +-
 drivers/net/hamradio/bpqether.c                       |  2 +-
 drivers/net/hamradio/scc.c                            |  2 +-
 drivers/net/hamradio/yam.c                            |  2 +-
 drivers/net/ppp/pppoe.c                               |  2 +-
 net/8021q/vlanproc.c                                  |  2 +-
 net/atm/proc.c                                        |  2 +-
 net/ax25/af_ax25.c                                    |  6 +++---
 net/bluetooth/af_bluetooth.c                          |  2 +-
 net/can/bcm.c                                         |  2 +-
 net/can/proc.c                                        |  2 +-
 net/core/dev.c                                        | 12 ++++++------
 net/core/dev_addr_lists.c                             |  2 +-
 net/core/pktgen.c                                     |  4 ++--
 net/core/sock.c                                       |  2 +-
 net/dccp/probe.c                                      |  4 ++--
 net/decnet/af_decnet.c                                |  2 +-
 net/decnet/dn_dev.c                                   |  2 +-
 net/decnet/dn_neigh.c                                 |  2 +-
 net/decnet/dn_route.c                                 |  2 +-
 net/ipv4/arp.c                                        |  2 +-
 net/ipv4/fib_trie.c                                   | 10 +++++-----
 net/ipv4/igmp.c                                       |  6 +++---
 net/ipv4/ipmr.c                                       |  6 +++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |  8 ++++----
 net/ipv4/ping.c                                       |  2 +-
 net/ipv4/proc.c                                       | 10 +++++-----
 net/ipv4/raw.c                                        |  2 +-
 net/ipv4/tcp_ipv4.c                                   |  2 +-
 net/ipv4/tcp_probe.c                                  |  4 ++--
 net/ipv4/udp.c                                        |  2 +-
 net/ipv6/addrconf.c                                   |  2 +-
 net/ipv6/anycast.c                                    |  2 +-
 net/ipv6/ip6_flowlabel.c                              |  2 +-
 net/ipv6/ip6mr.c                                      |  6 +++---
 net/ipv6/mcast.c                                      |  6 +++---
 net/ipv6/proc.c                                       | 10 +++++-----
 net/ipv6/raw.c                                        |  2 +-
 net/ipv6/route.c                                      |  4 ++--
 net/key/af_key.c                                      |  2 +-
 net/l2tp/l2tp_ppp.c                                   |  2 +-
 net/netfilter/ipvs/ip_vs_app.c                        |  2 +-
 net/netfilter/ipvs/ip_vs_conn.c                       |  4 ++--
 net/netfilter/ipvs/ip_vs_ctl.c                        |  6 +++---
 net/netfilter/nf_conntrack_expect.c                   |  2 +-
 net/netfilter/nf_conntrack_standalone.c               |  4 ++--
 net/netfilter/x_tables.c                              | 10 +++++-----
 net/netfilter/xt_hashlimit.c                          |  6 +++---
 net/netfilter/xt_recent.c                             |  2 +-
 net/netlink/af_netlink.c                              |  2 +-
 net/netrom/af_netrom.c                                |  6 +++---
 net/packet/af_packet.c                                |  2 +-
 net/phonet/pn_dev.c                                   |  4 ++--
 net/rose/af_rose.c                                    |  8 ++++----
 net/rxrpc/af_rxrpc.c                                  |  4 ++--
 net/sched/sch_api.c                                   |  2 +-
 net/sctp/probe.c                                      |  4 ++--
 net/unix/af_unix.c                                    |  2 +-
 net/wireless/wext-proc.c                              |  2 +-
 net/xfrm/xfrm_proc.c                                  |  2 +-
 60 files changed, 112 insertions(+), 112 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index ed17a57..f1b7e24 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -287,7 +287,7 @@ static void cn_fini(void)
 
 	cn_already_initialized = 0;
 
-	proc_net_remove(&init_net, "connector");
+	remove_proc_entry("connector", init_net.proc_net);
 
 	cn_queue_free_dev(dev->cbdev);
 	netlink_kernel_release(dev->nls);
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 61f2884..02de6c8 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -611,7 +611,7 @@ static void __exit bpq_cleanup_driver(void)
 
 	unregister_netdevice_notifier(&bpq_dev_notifier);
 
-	proc_net_remove(&init_net, "bpqether");
+	remove_proc_entry("bpqether", init_net.proc_net);
 
 	rtnl_lock();
 	while (!list_empty(&bpq_devices)) {
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index cab13f4..bc1d521 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -2173,7 +2173,7 @@ static void __exit scc_cleanup_driver(void)
 	if (Vector_Latch)
 		release_region(Vector_Latch, 1);
 
-	proc_net_remove(&init_net, "z8530drv");
+	remove_proc_entry("z8530drv", init_net.proc_net);
 }
 
 MODULE_AUTHOR("Joerg Reuter <jreuter@yaina.de>");
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 92847d2..4cf8f10 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -1199,7 +1199,7 @@ static void __exit yam_cleanup_driver(void)
 		kfree(p);
 	}
 
-	proc_net_remove(&init_net, "yam");
+	remove_proc_entry("yam", init_net.proc_net);
 }
 
 /* --------------------------------------------------------------------- */
diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index d7fa96c..bb07ba9 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -1145,7 +1145,7 @@ static __net_init int pppoe_init_net(struct net *net)
 
 static __net_exit void pppoe_exit_net(struct net *net)
 {
-	proc_net_remove(net, "pppoe");
+	remove_proc_entry("pppoe", net->proc_net);
 }
 
 static struct pernet_operations pppoe_net_ops = {
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 4de77ea..dc526ec 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -131,7 +131,7 @@ void vlan_proc_cleanup(struct net *net)
 		remove_proc_entry(name_conf, vn->proc_vlan_dir);
 
 	if (vn->proc_vlan_dir)
-		proc_net_remove(net, name_root);
+		remove_proc_entry(name_root, net->proc_net);
 
 	/* Dynamically added entries should be cleaned up as their vlan_device
 	 * is removed, so we should not have to take care of it here...
diff --git a/net/atm/proc.c b/net/atm/proc.c
index 0d020de..b4e7534 100644
--- a/net/atm/proc.c
+++ b/net/atm/proc.c
@@ -460,7 +460,7 @@ static void atm_proc_dirs_remove(void)
 		if (e->dirent)
 			remove_proc_entry(e->name, atm_proc_root);
 	}
-	proc_net_remove(&init_net, "atm");
+	remove_proc_entry("atm", init_net.proc_net);
 }
 
 int __init atm_proc_init(void)
diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c
index b6ccbea..69a06c4 100644
--- a/net/ax25/af_ax25.c
+++ b/net/ax25/af_ax25.c
@@ -2009,9 +2009,9 @@ MODULE_ALIAS_NETPROTO(PF_AX25);
 
 static void __exit ax25_exit(void)
 {
-	proc_net_remove(&init_net, "ax25_route");
-	proc_net_remove(&init_net, "ax25");
-	proc_net_remove(&init_net, "ax25_calls");
+	remove_proc_entry("ax25_route", init_net.proc_net);
+	remove_proc_entry("ax25", init_net.proc_net);
+	remove_proc_entry("ax25_calls", init_net.proc_net);
 
 	unregister_netdevice_notifier(&ax25_dev_notifier);
 
diff --git a/net/bluetooth/af_bluetooth.c b/net/bluetooth/af_bluetooth.c
index 8412b63..d3ee69b 100644
--- a/net/bluetooth/af_bluetooth.c
+++ b/net/bluetooth/af_bluetooth.c
@@ -652,7 +652,7 @@ int bt_procfs_init(struct module* module, struct net *net, const char *name,
 
 void bt_procfs_cleanup(struct net *net, const char *name)
 {
-	proc_net_remove(net, name);
+	remove_proc_entry(name, net->proc_net);
 }
 #else
 int bt_procfs_init(struct module* module, struct net *net, const char *name,
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 28e12d1..5dcb200 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1633,7 +1633,7 @@ static void __exit bcm_module_exit(void)
 	can_proto_unregister(&bcm_can_proto);
 
 	if (proc_dir)
-		proc_net_remove(&init_net, "can-bcm");
+		remove_proc_entry("can-bcm", init_net.proc_net);
 }
 
 module_init(bcm_module_init);
diff --git a/net/can/proc.c b/net/can/proc.c
index ae56690..4973358 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -531,5 +531,5 @@ void can_remove_proc(void)
 		can_remove_proc_readentry(CAN_PROC_RCVLIST_SFF);
 
 	if (can_dir)
-		proc_net_remove(&init_net, "can");
+		remove_proc_entry("can", init_net.proc_net);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 73e0565..37d5b05 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4736,11 +4736,11 @@ static int __net_init dev_proc_net_init(struct net *net)
 out:
 	return rc;
 out_ptype:
-	proc_net_remove(net, "ptype");
+	remove_proc_entry("ptype", net->proc_net);
 out_softnet:
-	proc_net_remove(net, "softnet_stat");
+	remove_proc_entry("softnet_stat", net->proc_net);
 out_dev:
-	proc_net_remove(net, "dev");
+	remove_proc_entry("dev", net->proc_net);
 	goto out;
 }
 
@@ -4748,9 +4748,9 @@ static void __net_exit dev_proc_net_exit(struct net *net)
 {
 	wext_proc_exit(net);
 
-	proc_net_remove(net, "ptype");
-	proc_net_remove(net, "softnet_stat");
-	proc_net_remove(net, "dev");
+	remove_proc_entry("ptype", net->proc_net);
+	remove_proc_entry("softnet_stat", net->proc_net);
+	remove_proc_entry("dev", net->proc_net);
 }
 
 static struct pernet_operations __net_initdata dev_proc_ops = {
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 7c62ec4..8956252 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -787,7 +787,7 @@ static int __net_init dev_mc_net_init(struct net *net)
 
 static void __net_exit dev_mc_net_exit(struct net *net)
 {
-	proc_net_remove(net, "dev_mcast");
+	remove_proc_entry("dev_mcast", net->proc_net);
 }
 
 static struct pernet_operations __net_initdata dev_mc_net_ops = {
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 2201e69..6048fc1 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3650,7 +3650,7 @@ static int __net_init pg_net_init(struct net *net)
 remove_entry:
 	remove_proc_entry(PGCTRL, pn->proc_dir);
 remove:
-	proc_net_remove(pn->net, PG_PROC_DIR);
+	remove_proc_entry(PG_PROC_DIR, pn->net->proc_net);
 	return ret;
 }
 
@@ -3676,7 +3676,7 @@ static void __net_exit pg_net_exit(struct net *net)
 	}
 
 	remove_proc_entry(PGCTRL, pn->proc_dir);
-	proc_net_remove(pn->net, PG_PROC_DIR);
+	remove_proc_entry(PG_PROC_DIR, pn->net->proc_net);
 }
 
 static struct pernet_operations pg_net_ops = {
diff --git a/net/core/sock.c b/net/core/sock.c
index b4d562ef..fe96c5d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2844,7 +2844,7 @@ static __net_init int proto_init_net(struct net *net)
 
 static __net_exit void proto_exit_net(struct net *net)
 {
-	proc_net_remove(net, "protocols");
+	remove_proc_entry("protocols", net->proc_net);
 }
 
 
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index d183589..4c6bdf9 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -181,7 +181,7 @@ static __init int dccpprobe_init(void)
 	pr_info("DCCP watch registered (port=%d)\n", port);
 	return 0;
 err1:
-	proc_net_remove(&init_net, procname);
+	remove_proc_entry(procname, init_net.proc_net);
 err0:
 	kfifo_free(&dccpw.fifo);
 	return ret;
@@ -191,7 +191,7 @@ module_init(dccpprobe_init);
 static __exit void dccpprobe_exit(void)
 {
 	kfifo_free(&dccpw.fifo);
-	proc_net_remove(&init_net, procname);
+	remove_proc_entry(procname, init_net.proc_net);
 	unregister_jprobe(&dccp_send_probe);
 
 }
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index f916013..c4a2def 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -2413,7 +2413,7 @@ static void __exit decnet_exit(void)
 	dn_neigh_cleanup();
 	dn_fib_cleanup();
 
-	proc_net_remove(&init_net, "decnet");
+	remove_proc_entry("decnet", init_net.proc_net);
 
 	proto_unregister(&dn_proto);
 
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index a04894a..c8da116 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1433,7 +1433,7 @@ void __exit dn_dev_cleanup(void)
 	}
 #endif /* CONFIG_SYSCTL */
 
-	proc_net_remove(&init_net, "decnet_dev");
+	remove_proc_entry("decnet_dev", init_net.proc_net);
 
 	dn_dev_devices_off();
 }
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index f3408f3..f8637f9 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -596,6 +596,6 @@ void __init dn_neigh_init(void)
 
 void __exit dn_neigh_cleanup(void)
 {
-	proc_net_remove(&init_net, "decnet_neigh");
+	remove_proc_entry("decnet_neigh", init_net.proc_net);
 	neigh_table_clear(&dn_neigh_table);
 }
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 8afb257..5ac0e15 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1918,7 +1918,7 @@ void __exit dn_route_cleanup(void)
 	del_timer(&dn_route_timer);
 	dn_run_flush(0);
 
-	proc_net_remove(&init_net, "decnet_cache");
+	remove_proc_entry("decnet_cache", init_net.proc_net);
 	dst_entries_destroy(&dn_dst_ops);
 }
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index b04c114..fea4929 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -1412,7 +1412,7 @@ static int __net_init arp_net_init(struct net *net)
 
 static void __net_exit arp_net_exit(struct net *net)
 {
-	proc_net_remove(net, "arp");
+	remove_proc_entry("arp", net->proc_net);
 }
 
 static struct pernet_operations arp_net_ops = {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 67c1d4b..61e03da 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2620,18 +2620,18 @@ int __net_init fib_proc_init(struct net *net)
 	return 0;
 
 out3:
-	proc_net_remove(net, "fib_triestat");
+	remove_proc_entry("fib_triestat", net->proc_net);
 out2:
-	proc_net_remove(net, "fib_trie");
+	remove_proc_entry("fib_trie", net->proc_net);
 out1:
 	return -ENOMEM;
 }
 
 void __net_exit fib_proc_exit(struct net *net)
 {
-	proc_net_remove(net, "fib_trie");
-	proc_net_remove(net, "fib_triestat");
-	proc_net_remove(net, "route");
+	remove_proc_entry("fib_trie", net->proc_net);
+	remove_proc_entry("fib_triestat", net->proc_net);
+	remove_proc_entry("route", net->proc_net);
 }
 
 #endif /* CONFIG_PROC_FS */
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index be85628..d8c2327 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2656,15 +2656,15 @@ static int __net_init igmp_net_init(struct net *net)
 	return 0;
 
 out_mcfilter:
-	proc_net_remove(net, "igmp");
+	remove_proc_entry("igmp", net->proc_net);
 out_igmp:
 	return -ENOMEM;
 }
 
 static void __net_exit igmp_net_exit(struct net *net)
 {
-	proc_net_remove(net, "mcfilter");
-	proc_net_remove(net, "igmp");
+	remove_proc_entry("mcfilter", net->proc_net);
+	remove_proc_entry("igmp", net->proc_net);
 }
 
 static struct pernet_operations igmp_net_ops = {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 160a8b8..5f95b3a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2712,7 +2712,7 @@ static int __net_init ipmr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
-	proc_net_remove(net, "ip_mr_vif");
+	remove_proc_entry("ip_mr_vif", net->proc_net);
 proc_vif_fail:
 	ipmr_rules_exit(net);
 #endif
@@ -2723,8 +2723,8 @@ fail:
 static void __net_exit ipmr_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_net_remove(net, "ip_mr_cache");
-	proc_net_remove(net, "ip_mr_vif");
+	remove_proc_entry("ip_mr_cache", net->proc_net);
+	remove_proc_entry("ip_mr_vif", net->proc_net);
 #endif
 	ipmr_rules_exit(net);
 }
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 48bc681..f2ca127 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -433,9 +433,9 @@ static int __net_init ip_conntrack_net_init(struct net *net)
 	return 0;
 
 err3:
-	proc_net_remove(net, "ip_conntrack_expect");
+	remove_proc_entry("ip_conntrack_expect", net->proc_net);
 err2:
-	proc_net_remove(net, "ip_conntrack");
+	remove_proc_entry("ip_conntrack", net->proc_net);
 err1:
 	return -ENOMEM;
 }
@@ -443,8 +443,8 @@ err1:
 static void __net_exit ip_conntrack_net_exit(struct net *net)
 {
 	remove_proc_entry("ip_conntrack", net->proc_net_stat);
-	proc_net_remove(net, "ip_conntrack_expect");
-	proc_net_remove(net, "ip_conntrack");
+	remove_proc_entry("ip_conntrack_expect", net->proc_net);
+	remove_proc_entry("ip_conntrack", net->proc_net);
 }
 
 static struct pernet_operations ip_conntrack_net_ops = {
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index fc62a13..55c4ee1 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -897,7 +897,7 @@ static int ping_proc_register(struct net *net)
 
 static void ping_proc_unregister(struct net *net)
 {
-	proc_net_remove(net, "icmp");
+	remove_proc_entry("icmp", net->proc_net);
 }
 
 
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 954bcd4..32030a2 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -482,18 +482,18 @@ static __net_init int ip_proc_init_net(struct net *net)
 	return 0;
 
 out_snmp:
-	proc_net_remove(net, "netstat");
+	remove_proc_entry("netstat", net->proc_net);
 out_netstat:
-	proc_net_remove(net, "sockstat");
+	remove_proc_entry("sockstat", net->proc_net);
 out_sockstat:
 	return -ENOMEM;
 }
 
 static __net_exit void ip_proc_exit_net(struct net *net)
 {
-	proc_net_remove(net, "snmp");
-	proc_net_remove(net, "netstat");
-	proc_net_remove(net, "sockstat");
+	remove_proc_entry("snmp", net->proc_net);
+	remove_proc_entry("netstat", net->proc_net);
+	remove_proc_entry("sockstat", net->proc_net);
 }
 
 static __net_initdata struct pernet_operations ip_proc_ops = {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 5043a7d..53ddebc 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -1058,7 +1058,7 @@ static __net_init int raw_init_net(struct net *net)
 
 static __net_exit void raw_exit_net(struct net *net)
 {
-	proc_net_remove(net, "raw");
+	remove_proc_entry("raw", net->proc_net);
 }
 
 static __net_initdata struct pernet_operations raw_net_ops = {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 77f5050..145d3bf 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2616,7 +2616,7 @@ EXPORT_SYMBOL(tcp_proc_register);
 
 void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
-	proc_net_remove(net, afinfo->name);
+	remove_proc_entry(afinfo->name, net->proc_net);
 }
 EXPORT_SYMBOL(tcp_proc_unregister);
 
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 1e3a1fb..d4943f6 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -244,7 +244,7 @@ static __init int tcpprobe_init(void)
 	pr_info("probe registered (port=%d) bufsize=%u\n", port, bufsize);
 	return 0;
  err1:
-	proc_net_remove(&init_net, procname);
+	remove_proc_entry(procname, init_net.proc_net);
  err0:
 	kfree(tcp_probe.log);
 	return ret;
@@ -253,7 +253,7 @@ module_init(tcpprobe_init);
 
 static __exit void tcpprobe_exit(void)
 {
-	proc_net_remove(&init_net, procname);
+	remove_proc_entry(procname, init_net.proc_net);
 	unregister_jprobe(&tcp_jprobe);
 	kfree(tcp_probe.log);
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 39a5e7a..265c42c 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2122,7 +2122,7 @@ EXPORT_SYMBOL(udp_proc_register);
 
 void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
 {
-	proc_net_remove(net, afinfo->name);
+	remove_proc_entry(afinfo->name, net->proc_net);
 }
 EXPORT_SYMBOL(udp_proc_unregister);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index bad7108..4dc0d44 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3332,7 +3332,7 @@ static int __net_init if6_proc_net_init(struct net *net)
 
 static void __net_exit if6_proc_net_exit(struct net *net)
 {
-       proc_net_remove(net, "if_inet6");
+	remove_proc_entry("if_inet6", net->proc_net);
 }
 
 static struct pernet_operations if6_proc_net_ops = {
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 5a8c009..5a80f15 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -517,7 +517,7 @@ int __net_init ac6_proc_init(struct net *net)
 
 void ac6_proc_exit(struct net *net)
 {
-	proc_net_remove(net, "anycast6");
+	remove_proc_entry("anycast6", net->proc_net);
 }
 #endif
 
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 900d79e..b973ed3 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -814,7 +814,7 @@ static int __net_init ip6_flowlabel_proc_init(struct net *net)
 
 static void __net_exit ip6_flowlabel_proc_fini(struct net *net)
 {
-	proc_net_remove(net, "ip6_flowlabel");
+	remove_proc_entry("ip6_flowlabel", net->proc_net);
 }
 #else
 static inline int ip6_flowlabel_proc_init(struct net *net)
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index fdfd96d..96bfb4e 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1369,7 +1369,7 @@ static int __net_init ip6mr_net_init(struct net *net)
 
 #ifdef CONFIG_PROC_FS
 proc_cache_fail:
-	proc_net_remove(net, "ip6_mr_vif");
+	remove_proc_entry("ip6_mr_vif", net->proc_net);
 proc_vif_fail:
 	ip6mr_rules_exit(net);
 #endif
@@ -1380,8 +1380,8 @@ fail:
 static void __net_exit ip6mr_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_net_remove(net, "ip6_mr_cache");
-	proc_net_remove(net, "ip6_mr_vif");
+	remove_proc_entry("ip6_mr_cache", net->proc_net);
+	remove_proc_entry("ip6_mr_vif", net->proc_net);
 #endif
 	ip6mr_rules_exit(net);
 }
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index de7d4b9..bfa6cc3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2610,14 +2610,14 @@ out:
 	return err;
 
 out_proc_net_igmp6:
-	proc_net_remove(net, "igmp6");
+	remove_proc_entry("igmp6", net->proc_net);
 	goto out;
 }
 
 static void __net_exit igmp6_proc_exit(struct net *net)
 {
-	proc_net_remove(net, "mcfilter6");
-	proc_net_remove(net, "igmp6");
+	remove_proc_entry("mcfilter6", net->proc_net);
+	remove_proc_entry("igmp6", net->proc_net);
 }
 #else
 static inline int igmp6_proc_init(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index cf8901d..bbbe53a 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -308,17 +308,17 @@ static int __net_init ipv6_proc_init_net(struct net *net)
 	return 0;
 
 proc_dev_snmp6_fail:
-	proc_net_remove(net, "snmp6");
+	remove_proc_entry("snmp6", net->proc_net);
 proc_snmp6_fail:
-	proc_net_remove(net, "sockstat6");
+	remove_proc_entry("sockstat6", net->proc_net);
 	return -ENOMEM;
 }
 
 static void __net_exit ipv6_proc_exit_net(struct net *net)
 {
-	proc_net_remove(net, "sockstat6");
-	proc_net_remove(net, "dev_snmp6");
-	proc_net_remove(net, "snmp6");
+	remove_proc_entry("sockstat6", net->proc_net);
+	remove_proc_entry("dev_snmp6", net->proc_net);
+	remove_proc_entry("snmp6", net->proc_net);
 }
 
 static struct pernet_operations ipv6_proc_ops = {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ff42fb3..c65907d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1300,7 +1300,7 @@ static int __net_init raw6_init_net(struct net *net)
 
 static void __net_exit raw6_exit_net(struct net *net)
 {
-	proc_net_remove(net, "raw6");
+	remove_proc_entry("raw6", net->proc_net);
 }
 
 static struct pernet_operations raw6_net_ops = {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e1228d8..515bb51 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3004,8 +3004,8 @@ static int __net_init ip6_route_net_init_late(struct net *net)
 static void __net_exit ip6_route_net_exit_late(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_net_remove(net, "ipv6_route");
-	proc_net_remove(net, "rt6_stats");
+	remove_proc_entry("ipv6_route", net->proc_net);
+	remove_proc_entry("rt6_stats", net->proc_net);
 #endif
 }
 
diff --git a/net/key/af_key.c b/net/key/af_key.c
index 021a429..9ef7985 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3749,7 +3749,7 @@ static int __net_init pfkey_init_proc(struct net *net)
 
 static void __net_exit pfkey_exit_proc(struct net *net)
 {
-	proc_net_remove(net, "pfkey");
+	remove_proc_entry("pfkey", net->proc_net);
 }
 #else
 static inline int pfkey_init_proc(struct net *net)
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 3ca270b..3f4e3af 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1796,7 +1796,7 @@ out:
 
 static __net_exit void pppol2tp_exit_net(struct net *net)
 {
-	proc_net_remove(net, "pppol2tp");
+	remove_proc_entry("pppol2tp", net->proc_net);
 }
 
 static struct pernet_operations pppol2tp_net_ops = {
diff --git a/net/netfilter/ipvs/ip_vs_app.c b/net/netfilter/ipvs/ip_vs_app.c
index 1db8a25..0b779d7 100644
--- a/net/netfilter/ipvs/ip_vs_app.c
+++ b/net/netfilter/ipvs/ip_vs_app.c
@@ -612,5 +612,5 @@ int __net_init ip_vs_app_net_init(struct net *net)
 void __net_exit ip_vs_app_net_cleanup(struct net *net)
 {
 	unregister_ip_vs_app(net, NULL /* all */);
-	proc_net_remove(net, "ip_vs_app");
+	remove_proc_entry("ip_vs_app", net->proc_net);
 }
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 91ae112..9f00db7 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1300,8 +1300,8 @@ void __net_exit ip_vs_conn_net_cleanup(struct net *net)
 {
 	/* flush all the connection entries first */
 	ip_vs_conn_flush(net);
-	proc_net_remove(net, "ip_vs_conn");
-	proc_net_remove(net, "ip_vs_conn_sync");
+	remove_proc_entry("ip_vs_conn", net->proc_net);
+	remove_proc_entry("ip_vs_conn_sync", net->proc_net);
 }
 
 int __init ip_vs_conn_init(void)
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 7d69181..c68198b 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3822,9 +3822,9 @@ void __net_exit ip_vs_control_net_cleanup(struct net *net)
 	ip_vs_trash_cleanup(net);
 	ip_vs_stop_estimator(net, &ipvs->tot_stats);
 	ip_vs_control_net_cleanup_sysctl(net);
-	proc_net_remove(net, "ip_vs_stats_percpu");
-	proc_net_remove(net, "ip_vs_stats");
-	proc_net_remove(net, "ip_vs");
+	remove_proc_entry("ip_vs_stats_percpu", net->proc_net);
+	remove_proc_entry("ip_vs_stats", net->proc_net);
+	remove_proc_entry("ip_vs", net->proc_net);
 	free_percpu(ipvs->tot_stats.cpustats);
 }
 
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index 4c15f8d..3921e5b 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -582,7 +582,7 @@ static int exp_proc_init(struct net *net)
 static void exp_proc_remove(struct net *net)
 {
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
-	proc_net_remove(net, "nf_conntrack_expect");
+	remove_proc_entry("nf_conntrack_expect", net->proc_net);
 #endif /* CONFIG_NF_CONNTRACK_PROCFS */
 }
 
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index bee9aec..6bcce40 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -377,7 +377,7 @@ static int nf_conntrack_standalone_init_proc(struct net *net)
 	return 0;
 
 out_stat_nf_conntrack:
-	proc_net_remove(net, "nf_conntrack");
+	remove_proc_entry("nf_conntrack", net->proc_net);
 out_nf_conntrack:
 	return -ENOMEM;
 }
@@ -385,7 +385,7 @@ out_nf_conntrack:
 static void nf_conntrack_standalone_fini_proc(struct net *net)
 {
 	remove_proc_entry("nf_conntrack", net->proc_net_stat);
-	proc_net_remove(net, "nf_conntrack");
+	remove_proc_entry("nf_conntrack", net->proc_net);
 }
 #else
 static int nf_conntrack_standalone_init_proc(struct net *net)
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 7b3a9e5..686c771 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1323,12 +1323,12 @@ int xt_proto_init(struct net *net, u_int8_t af)
 out_remove_matches:
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
-	proc_net_remove(net, buf);
+	remove_proc_entry(buf, net->proc_net);
 
 out_remove_tables:
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TABLES, sizeof(buf));
-	proc_net_remove(net, buf);
+	remove_proc_entry(buf, net->proc_net);
 out:
 	return -1;
 #endif
@@ -1342,15 +1342,15 @@ void xt_proto_fini(struct net *net, u_int8_t af)
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TABLES, sizeof(buf));
-	proc_net_remove(net, buf);
+	remove_proc_entry(buf, net->proc_net);
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TARGETS, sizeof(buf));
-	proc_net_remove(net, buf);
+	remove_proc_entry(buf, net->proc_net);
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
-	proc_net_remove(net, buf);
+	remove_proc_entry(buf, net->proc_net);
 #endif /*CONFIG_PROC_FS*/
 }
 EXPORT_SYMBOL_GPL(xt_proto_fini);
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index a9d7af9..98218c8 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -867,7 +867,7 @@ static int __net_init hashlimit_proc_net_init(struct net *net)
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
 	hashlimit_net->ip6t_hashlimit = proc_mkdir("ip6t_hashlimit", net->proc_net);
 	if (!hashlimit_net->ip6t_hashlimit) {
-		proc_net_remove(net, "ipt_hashlimit");
+		remove_proc_entry("ipt_hashlimit", net->proc_net);
 		return -ENOMEM;
 	}
 #endif
@@ -897,9 +897,9 @@ static void __net_exit hashlimit_proc_net_exit(struct net *net)
 	hashlimit_net->ip6t_hashlimit = NULL;
 	mutex_unlock(&hashlimit_mutex);
 
-	proc_net_remove(net, "ipt_hashlimit");
+	remove_proc_entry("ipt_hashlimit", net->proc_net);
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
-	proc_net_remove(net, "ip6t_hashlimit");
+	remove_proc_entry("ip6t_hashlimit", net->proc_net);
 #endif
 }
 
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 978efc9..31bf233 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -643,7 +643,7 @@ static void __net_exit recent_proc_net_exit(struct net *net)
 	recent_net->xt_recent = NULL;
 	spin_unlock_bh(&recent_lock);
 
-	proc_net_remove(net, "xt_recent");
+	remove_proc_entry("xt_recent", net->proc_net);
 }
 #else
 static inline int recent_proc_net_init(struct net *net)
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 50084c4..3d55e0c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -2154,7 +2154,7 @@ static int __net_init netlink_net_init(struct net *net)
 static void __net_exit netlink_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_net_remove(net, "netlink");
+	remove_proc_entry("netlink", net->proc_net);
 #endif
 }
 
diff --git a/net/netrom/af_netrom.c b/net/netrom/af_netrom.c
index 71b8613..297b07a 100644
--- a/net/netrom/af_netrom.c
+++ b/net/netrom/af_netrom.c
@@ -1482,9 +1482,9 @@ static void __exit nr_exit(void)
 {
 	int i;
 
-	proc_net_remove(&init_net, "nr");
-	proc_net_remove(&init_net, "nr_neigh");
-	proc_net_remove(&init_net, "nr_nodes");
+	remove_proc_entry("nr", init_net.proc_net);
+	remove_proc_entry("nr_neigh", init_net.proc_net);
+	remove_proc_entry("nr_nodes", init_net.proc_net);
 	nr_loopback_clear();
 
 	nr_rt_free();
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b7b2d56..c7bfeff 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3836,7 +3836,7 @@ static int __net_init packet_net_init(struct net *net)
 
 static void __net_exit packet_net_exit(struct net *net)
 {
-	proc_net_remove(net, "packet");
+	remove_proc_entry("packet", net->proc_net);
 }
 
 static struct pernet_operations packet_net_ops = {
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 0e527c9..45a7df6 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -331,7 +331,7 @@ static int __net_init phonet_init_net(struct net *net)
 
 static void __net_exit phonet_exit_net(struct net *net)
 {
-	proc_net_remove(net, "phonet");
+	remove_proc_entry("phonet", net->proc_net);
 }
 
 static struct pernet_operations phonet_net_ops = {
@@ -361,7 +361,7 @@ void phonet_device_exit(void)
 	rtnl_unregister_all(PF_PHONET);
 	unregister_netdevice_notifier(&phonet_device_notifier);
 	unregister_pernet_subsys(&phonet_net_ops);
-	proc_net_remove(&init_net, "pnresource");
+	remove_proc_entry("pnresource", init_net.proc_net);
 }
 
 int phonet_route_add(struct net_device *dev, u8 daddr)
diff --git a/net/rose/af_rose.c b/net/rose/af_rose.c
index 5fd8aac..b768fe9 100644
--- a/net/rose/af_rose.c
+++ b/net/rose/af_rose.c
@@ -1608,10 +1608,10 @@ static void __exit rose_exit(void)
 {
 	int i;
 
-	proc_net_remove(&init_net, "rose");
-	proc_net_remove(&init_net, "rose_neigh");
-	proc_net_remove(&init_net, "rose_nodes");
-	proc_net_remove(&init_net, "rose_routes");
+	remove_proc_entry("rose", init_net.proc_net);
+	remove_proc_entry("rose_neigh", init_net.proc_net);
+	remove_proc_entry("rose_nodes", init_net.proc_net);
+	remove_proc_entry("rose_routes", init_net.proc_net);
 	rose_loopback_clear();
 
 	rose_rt_free();
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 59c7c7d..e61aa60 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -879,8 +879,8 @@ static void __exit af_rxrpc_exit(void)
 
 	_debug("flush scheduled work");
 	flush_workqueue(rxrpc_workqueue);
-	proc_net_remove(&init_net, "rxrpc_conns");
-	proc_net_remove(&init_net, "rxrpc_calls");
+	remove_proc_entry("rxrpc_conns", init_net.proc_net);
+	remove_proc_entry("rxrpc_calls", init_net.proc_net);
 	destroy_workqueue(rxrpc_workqueue);
 	kmem_cache_destroy(rxrpc_call_jar);
 	_leave("");
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d8cf7d3..a181b48 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1777,7 +1777,7 @@ static int __net_init psched_net_init(struct net *net)
 
 static void __net_exit psched_net_exit(struct net *net)
 {
-	proc_net_remove(net, "psched");
+	remove_proc_entry("psched", net->proc_net);
 }
 #else
 static int __net_init psched_net_init(struct net *net)
diff --git a/net/sctp/probe.c b/net/sctp/probe.c
index dd507f5..ad0dba8 100644
--- a/net/sctp/probe.c
+++ b/net/sctp/probe.c
@@ -208,7 +208,7 @@ static __init int sctpprobe_init(void)
 	return 0;
 
 remove_proc:
-	proc_net_remove(&init_net, procname);
+	remove_proc_entry(procname, init_net.proc_net);
 free_kfifo:
 	kfifo_free(&sctpw.fifo);
 	return ret;
@@ -217,7 +217,7 @@ free_kfifo:
 static __exit void sctpprobe_exit(void)
 {
 	kfifo_free(&sctpw.fifo);
-	proc_net_remove(&init_net, procname);
+	remove_proc_entry(procname, init_net.proc_net);
 	unregister_jprobe(&sctp_recv_probe);
 }
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0c479b6..87d2842 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2415,7 +2415,7 @@ out:
 static void __net_exit unix_net_exit(struct net *net)
 {
 	unix_sysctl_unregister(net);
-	proc_net_remove(net, "unix");
+	remove_proc_entry("unix", net->proc_net);
 }
 
 static struct pernet_operations unix_net_ops = {
diff --git a/net/wireless/wext-proc.c b/net/wireless/wext-proc.c
index 00fc5bb..e98a01c 100644
--- a/net/wireless/wext-proc.c
+++ b/net/wireless/wext-proc.c
@@ -152,5 +152,5 @@ int __net_init wext_proc_init(struct net *net)
 
 void __net_exit wext_proc_exit(struct net *net)
 {
-	proc_net_remove(net, "wireless");
+	remove_proc_entry("wireless", net->proc_net);
 }
diff --git a/net/xfrm/xfrm_proc.c b/net/xfrm/xfrm_proc.c
index 9abe14f..c721b0d 100644
--- a/net/xfrm/xfrm_proc.c
+++ b/net/xfrm/xfrm_proc.c
@@ -82,5 +82,5 @@ int __net_init xfrm_proc_init(struct net *net)
 
 void xfrm_proc_fini(struct net *net)
 {
-	proc_net_remove(net, "xfrm_stat");
+	remove_proc_entry("xfrm_stat", net->proc_net);
 }
-- 
1.7.11.7
