From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] net: spread __net_init, __net_exit
Date: Sun, 17 Jan 2010 15:35:32 +0200
Message-ID: <20100117133532.GB6178@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:60192 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab0AQNfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 08:35:43 -0500
Received: by fxm25 with SMTP id 25so336958fxm.21
        for <netdev@vger.kernel.org>; Sun, 17 Jan 2010 05:35:41 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__net_init/__net_exit are apparently not going away, so use them
to full extent.

In some cases __net_init was removed, because it was called from
__net_exit code.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/bonding/bond_main.c |   12 ++++++------
 net/8021q/vlan.c                |    4 ++--
 net/8021q/vlanproc.c            |    2 +-
 net/bridge/br_if.c              |    2 +-
 net/core/fib_rules.c            |    2 +-
 net/core/rtnetlink.c            |    4 ++--
 net/core/sock.c                 |    4 ++--
 net/dccp/ipv4.c                 |    4 ++--
 net/dccp/ipv6.c                 |    4 ++--
 net/ipv4/fib_frontend.c         |    4 ++--
 net/ipv4/igmp.c                 |    4 ++--
 net/ipv4/ip_fragment.c          |    8 ++++----
 net/ipv4/ip_gre.c               |    4 ++--
 net/ipv4/ipip.c                 |    7 +++----
 net/ipv4/tcp_ipv4.c             |    4 ++--
 net/ipv4/udp.c                  |    4 ++--
 net/ipv4/udplite.c              |    4 ++--
 net/ipv6/addrconf.c             |    8 ++++----
 net/ipv6/af_inet6.c             |    4 ++--
 net/ipv6/anycast.c              |    2 +-
 net/ipv6/fib6_rules.c           |    4 ++--
 net/ipv6/icmp.c                 |    2 +-
 net/ipv6/ip6_fib.c              |    6 +++---
 net/ipv6/ip6_flowlabel.c        |    9 ++++-----
 net/ipv6/ip6_tunnel.c           |    9 ++++-----
 net/ipv6/mcast.c                |   13 ++++++-------
 net/ipv6/ndisc.c                |    4 ++--
 net/ipv6/proc.c                 |    4 ++--
 net/ipv6/raw.c                  |    4 ++--
 net/ipv6/reassembly.c           |    8 ++++----
 net/ipv6/route.c                |    6 +++---
 net/ipv6/sit.c                  |    9 ++++-----
 net/ipv6/sysctl_net_ipv6.c      |    4 ++--
 net/ipv6/tcp_ipv6.c             |    8 ++++----
 net/ipv6/udp.c                  |    2 +-
 net/ipv6/udplite.c              |    4 ++--
 net/key/af_key.c                |    6 +++---
 net/packet/af_packet.c          |    4 ++--
 net/phonet/pn_dev.c             |    4 ++--
 net/sysctl_net.c                |    4 ++--
 net/unix/af_unix.c              |    4 ++--
 net/unix/sysctl_net_unix.c      |    2 +-
 net/wireless/wext-proc.c        |    4 ++--
 net/xfrm/xfrm_sysctl.c          |    4 ++--
 44 files changed, 107 insertions(+), 112 deletions(-)

--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3307,7 +3307,7 @@ static void bond_remove_proc_entry(struct bonding *bond)
 /* Create the bonding directory under /proc/net, if doesn't exist yet.
  * Caller must hold rtnl_lock.
  */
-static void bond_create_proc_dir(struct bond_net *bn)
+static void __net_init bond_create_proc_dir(struct bond_net *bn)
 {
 	if (!bn->proc_dir) {
 		bn->proc_dir = proc_mkdir(DRV_NAME, bn->net->proc_net);
@@ -3320,7 +3320,7 @@ static void bond_create_proc_dir(struct bond_net *bn)
 /* Destroy the bonding directory under /proc/net, if empty.
  * Caller must hold rtnl_lock.
  */
-static void bond_destroy_proc_dir(struct bond_net *bn)
+static void __net_exit bond_destroy_proc_dir(struct bond_net *bn)
 {
 	if (bn->proc_dir) {
 		remove_proc_entry(DRV_NAME, bn->net->proc_net);
@@ -3338,11 +3338,11 @@ static void bond_remove_proc_entry(struct bonding *bond)
 {
 }
 
-static void bond_create_proc_dir(struct bond_net *bn)
+static inline void bond_create_proc_dir(struct bond_net *bn)
 {
 }
 
-static void bond_destroy_proc_dir(struct bond_net *bn)
+static inline void bond_destroy_proc_dir(struct bond_net *bn)
 {
 }
 
@@ -4955,7 +4955,7 @@ out_netdev:
 	goto out;
 }
 
-static int bond_net_init(struct net *net)
+static int __net_init bond_net_init(struct net *net)
 {
 	struct bond_net *bn = net_generic(net, bond_net_id);
 
@@ -4967,7 +4967,7 @@ static int bond_net_init(struct net *net)
 	return 0;
 }
 
-static void bond_net_exit(struct net *net)
+static void __net_exit bond_net_exit(struct net *net)
 {
 	struct bond_net *bn = net_generic(net, bond_net_id);
 
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -663,7 +663,7 @@ out:
 	return err;
 }
 
-static int vlan_init_net(struct net *net)
+static int __net_init vlan_init_net(struct net *net)
 {
 	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	int err;
@@ -675,7 +675,7 @@ static int vlan_init_net(struct net *net)
 	return err;
 }
 
-static void vlan_exit_net(struct net *net)
+static void __net_exit vlan_exit_net(struct net *net)
 {
 	vlan_proc_cleanup(net);
 }
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -140,7 +140,7 @@ void vlan_proc_cleanup(struct net *net)
  *	Create /proc/net/vlan entries
  */
 
-int vlan_proc_init(struct net *net)
+int __net_init vlan_proc_init(struct net *net)
 {
 	struct vlan_net *vn = net_generic(net, vlan_net_id);
 
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -467,7 +467,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 }
 
-void br_net_exit(struct net *net)
+void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
 	LIST_HEAD(list);
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -708,7 +708,7 @@ static struct notifier_block fib_rules_notifier = {
 	.notifier_call = fib_rules_event,
 };
 
-static int fib_rules_net_init(struct net *net)
+static int __net_init fib_rules_net_init(struct net *net)
 {
 	INIT_LIST_HEAD(&net->rules_ops);
 	spin_lock_init(&net->rules_mod_lock);
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1386,7 +1386,7 @@ static struct notifier_block rtnetlink_dev_notifier = {
 };
 
 
-static int rtnetlink_net_init(struct net *net)
+static int __net_init rtnetlink_net_init(struct net *net)
 {
 	struct sock *sk;
 	sk = netlink_kernel_create(net, NETLINK_ROUTE, RTNLGRP_MAX,
@@ -1397,7 +1397,7 @@ static int rtnetlink_net_init(struct net *net)
 	return 0;
 }
 
-static void rtnetlink_net_exit(struct net *net)
+static void __net_exit rtnetlink_net_exit(struct net *net)
 {
 	netlink_kernel_release(net->rtnl);
 	net->rtnl = NULL;
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -2140,13 +2140,13 @@ int sock_prot_inuse_get(struct net *net, struct proto *prot)
 }
 EXPORT_SYMBOL_GPL(sock_prot_inuse_get);
 
-static int sock_inuse_init_net(struct net *net)
+static int __net_init sock_inuse_init_net(struct net *net)
 {
 	net->core.inuse = alloc_percpu(struct prot_inuse);
 	return net->core.inuse ? 0 : -ENOMEM;
 }
 
-static void sock_inuse_exit_net(struct net *net)
+static void __net_exit sock_inuse_exit_net(struct net *net)
 {
 	free_percpu(net->core.inuse);
 }
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -996,7 +996,7 @@ static struct inet_protosw dccp_v4_protosw = {
 	.flags		= INET_PROTOSW_ICSK,
 };
 
-static int dccp_v4_init_net(struct net *net)
+static int __net_init dccp_v4_init_net(struct net *net)
 {
 	int err;
 
@@ -1005,7 +1005,7 @@ static int dccp_v4_init_net(struct net *net)
 	return err;
 }
 
-static void dccp_v4_exit_net(struct net *net)
+static void __net_exit dccp_v4_exit_net(struct net *net)
 {
 	inet_ctl_sock_destroy(net->dccp.v4_ctl_sk);
 }
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1189,7 +1189,7 @@ static struct inet_protosw dccp_v6_protosw = {
 	.flags		= INET_PROTOSW_ICSK,
 };
 
-static int dccp_v6_init_net(struct net *net)
+static int __net_init dccp_v6_init_net(struct net *net)
 {
 	int err;
 
@@ -1198,7 +1198,7 @@ static int dccp_v6_init_net(struct net *net)
 	return err;
 }
 
-static void dccp_v6_exit_net(struct net *net)
+static void __net_exit dccp_v6_exit_net(struct net *net)
 {
 	inet_ctl_sock_destroy(net->dccp.v6_ctl_sk);
 }
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -883,7 +883,7 @@ static void nl_fib_input(struct sk_buff *skb)
 	netlink_unicast(net->ipv4.fibnl, skb, pid, MSG_DONTWAIT);
 }
 
-static int nl_fib_lookup_init(struct net *net)
+static int __net_init nl_fib_lookup_init(struct net *net)
 {
 	struct sock *sk;
 	sk = netlink_kernel_create(net, NETLINK_FIB_LOOKUP, 0,
@@ -1004,7 +1004,7 @@ fail:
 	return err;
 }
 
-static void __net_exit ip_fib_net_exit(struct net *net)
+static void ip_fib_net_exit(struct net *net)
 {
 	unsigned int i;
 
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2603,7 +2603,7 @@ static const struct file_operations igmp_mcf_seq_fops = {
 	.release	=	seq_release_net,
 };
 
-static int igmp_net_init(struct net *net)
+static int __net_init igmp_net_init(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
@@ -2621,7 +2621,7 @@ out_igmp:
 	return -ENOMEM;
 }
 
-static void igmp_net_exit(struct net *net)
+static void __net_exit igmp_net_exit(struct net *net)
 {
 	proc_net_remove(net, "mcfilter");
 	proc_net_remove(net, "igmp");
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -646,7 +646,7 @@ static struct ctl_table ip4_frags_ctl_table[] = {
 	{ }
 };
 
-static int ip4_frags_ns_ctl_register(struct net *net)
+static int __net_init ip4_frags_ns_ctl_register(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
@@ -676,7 +676,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void ip4_frags_ns_ctl_unregister(struct net *net)
+static void __net_exit ip4_frags_ns_ctl_unregister(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -704,7 +704,7 @@ static inline void ip4_frags_ctl_register(void)
 }
 #endif
 
-static int ipv4_frags_init_net(struct net *net)
+static int __net_init ipv4_frags_init_net(struct net *net)
 {
 	/*
 	 * Fragment cache limits. We will commit 256K at one time. Should we
@@ -726,7 +726,7 @@ static int ipv4_frags_init_net(struct net *net)
 	return ip4_frags_ns_ctl_register(net);
 }
 
-static void ipv4_frags_exit_net(struct net *net)
+static void __net_exit ipv4_frags_exit_net(struct net *net)
 {
 	ip4_frags_ns_ctl_unregister(net);
 	inet_frags_exit_net(&net->ipv4.frags, &ip4_frags);
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1307,7 +1307,7 @@ static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
 	}
 }
 
-static int ipgre_init_net(struct net *net)
+static int __net_init ipgre_init_net(struct net *net)
 {
 	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	int err;
@@ -1334,7 +1334,7 @@ err_alloc_dev:
 	return err;
 }
 
-static void ipgre_exit_net(struct net *net)
+static void __net_exit ipgre_exit_net(struct net *net)
 {
 	struct ipgre_net *ign;
 	LIST_HEAD(list);
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -130,7 +130,6 @@ struct ipip_net {
 	struct net_device *fb_tunnel_dev;
 };
 
-static void ipip_fb_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_init(struct net_device *dev);
 static void ipip_tunnel_setup(struct net_device *dev);
 
@@ -730,7 +729,7 @@ static void ipip_tunnel_init(struct net_device *dev)
 	ipip_tunnel_bind_dev(dev);
 }
 
-static void ipip_fb_tunnel_init(struct net_device *dev)
+static void __net_init ipip_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -773,7 +772,7 @@ static void ipip_destroy_tunnels(struct ipip_net *ipn, struct list_head *head)
 	}
 }
 
-static int ipip_init_net(struct net *net)
+static int __net_init ipip_init_net(struct net *net)
 {
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 	int err;
@@ -806,7 +805,7 @@ err_alloc_dev:
 	return err;
 }
 
-static void ipip_exit_net(struct net *net)
+static void __net_exit ipip_exit_net(struct net *net)
 {
 	struct ipip_net *ipn = net_generic(net, ipip_net_id);
 	LIST_HEAD(list);
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2428,12 +2428,12 @@ static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	},
 };
 
-static int tcp4_proc_init_net(struct net *net)
+static int __net_init tcp4_proc_init_net(struct net *net)
 {
 	return tcp_proc_register(net, &tcp4_seq_afinfo);
 }
 
-static void tcp4_proc_exit_net(struct net *net)
+static void __net_exit tcp4_proc_exit_net(struct net *net)
 {
 	tcp_proc_unregister(net, &tcp4_seq_afinfo);
 }
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2027,12 +2027,12 @@ static struct udp_seq_afinfo udp4_seq_afinfo = {
 	},
 };
 
-static int udp4_proc_init_net(struct net *net)
+static int __net_init udp4_proc_init_net(struct net *net)
 {
 	return udp_proc_register(net, &udp4_seq_afinfo);
 }
 
-static void udp4_proc_exit_net(struct net *net)
+static void __net_exit udp4_proc_exit_net(struct net *net)
 {
 	udp_proc_unregister(net, &udp4_seq_afinfo);
 }
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -81,12 +81,12 @@ static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	},
 };
 
-static int udplite4_proc_init_net(struct net *net)
+static int __net_init udplite4_proc_init_net(struct net *net)
 {
 	return udp_proc_register(net, &udplite4_seq_afinfo);
 }
 
-static void udplite4_proc_exit_net(struct net *net)
+static void __net_exit udplite4_proc_exit_net(struct net *net)
 {
 	udp_proc_unregister(net, &udplite4_seq_afinfo);
 }
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3027,14 +3027,14 @@ static const struct file_operations if6_fops = {
 	.release	= seq_release_net,
 };
 
-static int if6_proc_net_init(struct net *net)
+static int __net_init if6_proc_net_init(struct net *net)
 {
 	if (!proc_net_fops_create(net, "if_inet6", S_IRUGO, &if6_fops))
 		return -ENOMEM;
 	return 0;
 }
 
-static void if6_proc_net_exit(struct net *net)
+static void __net_exit if6_proc_net_exit(struct net *net)
 {
        proc_net_remove(net, "if_inet6");
 }
@@ -4418,7 +4418,7 @@ static void addrconf_sysctl_unregister(struct inet6_dev *idev)
 
 #endif
 
-static int addrconf_init_net(struct net *net)
+static int __net_init addrconf_init_net(struct net *net)
 {
 	int err;
 	struct ipv6_devconf *all, *dflt;
@@ -4467,7 +4467,7 @@ err_alloc_all:
 	return err;
 }
 
-static void addrconf_exit_net(struct net *net)
+static void __net_exit addrconf_exit_net(struct net *net)
 {
 #ifdef CONFIG_SYSCTL
 	__addrconf_sysctl_unregister(net->ipv6.devconf_dflt);
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -999,7 +999,7 @@ err_udplite_mib:
 	return -ENOMEM;
 }
 
-static void __net_exit ipv6_cleanup_mibs(struct net *net)
+static void ipv6_cleanup_mibs(struct net *net)
 {
 	snmp_mib_free((void **)net->mib.udp_stats_in6);
 	snmp_mib_free((void **)net->mib.udplite_stats_in6);
@@ -1042,7 +1042,7 @@ out:
 #endif
 }
 
-static void inet6_net_exit(struct net *net)
+static void __net_exit inet6_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	udp6_proc_exit(net);
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -538,7 +538,7 @@ static const struct file_operations ac6_seq_fops = {
 	.release	=	seq_release_net,
 };
 
-int ac6_proc_init(struct net *net)
+int __net_init ac6_proc_init(struct net *net)
 {
 	if (!proc_net_fops_create(net, "anycast6", S_IRUGO, &ac6_seq_fops))
 		return -ENOMEM;
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -262,7 +262,7 @@ static struct fib_rules_ops fib6_rules_ops_template = {
 	.fro_net		= &init_net,
 };
 
-static int fib6_rules_net_init(struct net *net)
+static int __net_init fib6_rules_net_init(struct net *net)
 {
 	struct fib_rules_ops *ops;
 	int err = -ENOMEM;
@@ -291,7 +291,7 @@ out_fib6_rules_ops:
 	goto out;
 }
 
-static void fib6_rules_net_exit(struct net *net)
+static void __net_exit fib6_rules_net_exit(struct net *net)
 {
 	fib_rules_unregister(net->ipv6.fib6_rules_ops);
 }
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -950,7 +950,7 @@ ctl_table ipv6_icmp_table_template[] = {
 	{ },
 };
 
-struct ctl_table *ipv6_icmp_sysctl_init(struct net *net)
+struct ctl_table * __net_init ipv6_icmp_sysctl_init(struct net *net)
 {
 	struct ctl_table *table;
 
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -239,7 +239,7 @@ struct fib6_table *fib6_get_table(struct net *net, u32 id)
 	return NULL;
 }
 
-static void fib6_tables_init(struct net *net)
+static void __net_init fib6_tables_init(struct net *net)
 {
 	fib6_link_table(net, net->ipv6.fib6_main_tbl);
 	fib6_link_table(net, net->ipv6.fib6_local_tbl);
@@ -262,7 +262,7 @@ struct dst_entry *fib6_rule_lookup(struct net *net, struct flowi *fl,
 	return (struct dst_entry *) lookup(net, net->ipv6.fib6_main_tbl, fl, flags);
 }
 
-static void fib6_tables_init(struct net *net)
+static void __net_init fib6_tables_init(struct net *net)
 {
 	fib6_link_table(net, net->ipv6.fib6_main_tbl);
 }
@@ -1469,7 +1469,7 @@ static void fib6_gc_timer_cb(unsigned long arg)
 	fib6_run_gc(0, (struct net *)arg);
 }
 
-static int fib6_net_init(struct net *net)
+static int __net_init fib6_net_init(struct net *net)
 {
 	setup_timer(&net->ipv6.ip6_fib_timer, fib6_gc_timer_cb, (unsigned long)net);
 
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -154,7 +154,7 @@ static void ip6_fl_gc(unsigned long dummy)
 	write_unlock(&ip6_fl_lock);
 }
 
-static void ip6_fl_purge(struct net *net)
+static void __net_exit ip6_fl_purge(struct net *net)
 {
 	int i;
 
@@ -735,7 +735,7 @@ static const struct file_operations ip6fl_seq_fops = {
 	.release	=	seq_release_net,
 };
 
-static int ip6_flowlabel_proc_init(struct net *net)
+static int __net_init ip6_flowlabel_proc_init(struct net *net)
 {
 	if (!proc_net_fops_create(net, "ip6_flowlabel",
 				  S_IRUGO, &ip6fl_seq_fops))
@@ -743,7 +743,7 @@ static int ip6_flowlabel_proc_init(struct net *net)
 	return 0;
 }
 
-static void ip6_flowlabel_proc_fini(struct net *net)
+static void __net_exit ip6_flowlabel_proc_fini(struct net *net)
 {
 	proc_net_remove(net, "ip6_flowlabel");
 }
@@ -754,11 +754,10 @@ static inline int ip6_flowlabel_proc_init(struct net *net)
 }
 static inline void ip6_flowlabel_proc_fini(struct net *net)
 {
-	return ;
 }
 #endif
 
-static inline void ip6_flowlabel_net_exit(struct net *net)
+static void __net_exit ip6_flowlabel_net_exit(struct net *net)
 {
 	ip6_fl_purge(net);
 	ip6_flowlabel_proc_fini(net);
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -74,7 +74,6 @@ MODULE_LICENSE("GPL");
 		     (addr)->s6_addr32[2] ^ (addr)->s6_addr32[3]) & \
 		    (HASH_SIZE - 1))
 
-static void ip6_fb_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_init(struct net_device *dev);
 static void ip6_tnl_dev_setup(struct net_device *dev);
 
@@ -1364,7 +1363,7 @@ static void ip6_tnl_dev_init(struct net_device *dev)
  * Return: 0
  **/
 
-static void ip6_fb_tnl_dev_init(struct net_device *dev)
+static void __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net *net = dev_net(dev);
@@ -1388,7 +1387,7 @@ static struct xfrm6_tunnel ip6ip6_handler = {
 	.priority	=	1,
 };
 
-static void ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
+static void __net_exit ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 {
 	int h;
 	struct ip6_tnl *t;
@@ -1407,7 +1406,7 @@ static void ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 	unregister_netdevice_many(&list);
 }
 
-static int ip6_tnl_init_net(struct net *net)
+static int __net_init ip6_tnl_init_net(struct net *net)
 {
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 	int err;
@@ -1436,7 +1435,7 @@ err_alloc_dev:
 	return err;
 }
 
-static void ip6_tnl_exit_net(struct net *net)
+static void __net_exit ip6_tnl_exit_net(struct net *net)
 {
 	struct ip6_tnl_net *ip6n = net_generic(net, ip6_tnl_net_id);
 
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -2646,7 +2646,7 @@ static const struct file_operations igmp6_mcf_seq_fops = {
 	.release	=	seq_release_net,
 };
 
-static int igmp6_proc_init(struct net *net)
+static int __net_init igmp6_proc_init(struct net *net)
 {
 	int err;
 
@@ -2666,23 +2666,22 @@ out_proc_net_igmp6:
 	goto out;
 }
 
-static void igmp6_proc_exit(struct net *net)
+static void __net_exit igmp6_proc_exit(struct net *net)
 {
 	proc_net_remove(net, "mcfilter6");
 	proc_net_remove(net, "igmp6");
 }
 #else
-static int igmp6_proc_init(struct net *net)
+static inline int igmp6_proc_init(struct net *net)
 {
 	return 0;
 }
-static void igmp6_proc_exit(struct net *net)
+static inline void igmp6_proc_exit(struct net *net)
 {
-	;
 }
 #endif
 
-static int igmp6_net_init(struct net *net)
+static int __net_init igmp6_net_init(struct net *net)
 {
 	int err;
 
@@ -2708,7 +2707,7 @@ out_sock_create:
 	goto out;
 }
 
-static void igmp6_net_exit(struct net *net)
+static void __net_exit igmp6_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.igmp_sk);
 	igmp6_proc_exit(net);
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1772,7 +1772,7 @@ int ndisc_ifinfo_sysctl_change(struct ctl_table *ctl, int write, void __user *bu
 
 #endif
 
-static int ndisc_net_init(struct net *net)
+static int __net_init ndisc_net_init(struct net *net)
 {
 	struct ipv6_pinfo *np;
 	struct sock *sk;
@@ -1797,7 +1797,7 @@ static int ndisc_net_init(struct net *net)
 	return 0;
 }
 
-static void ndisc_net_exit(struct net *net)
+static void __net_exit ndisc_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.ndisc_sk);
 }
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -267,7 +267,7 @@ int snmp6_unregister_dev(struct inet6_dev *idev)
 	return 0;
 }
 
-static int ipv6_proc_init_net(struct net *net)
+static int __net_init ipv6_proc_init_net(struct net *net)
 {
 	if (!proc_net_fops_create(net, "sockstat6", S_IRUGO,
 			&sockstat6_seq_fops))
@@ -288,7 +288,7 @@ proc_dev_snmp6_fail:
 	return -ENOMEM;
 }
 
-static void ipv6_proc_exit_net(struct net *net)
+static void __net_exit ipv6_proc_exit_net(struct net *net)
 {
 	proc_net_remove(net, "sockstat6");
 	proc_net_remove(net, "dev_snmp6");
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1275,7 +1275,7 @@ static const struct file_operations raw6_seq_fops = {
 	.release =	seq_release_net,
 };
 
-static int raw6_init_net(struct net *net)
+static int __net_init raw6_init_net(struct net *net)
 {
 	if (!proc_net_fops_create(net, "raw6", S_IRUGO, &raw6_seq_fops))
 		return -ENOMEM;
@@ -1283,7 +1283,7 @@ static int raw6_init_net(struct net *net)
 	return 0;
 }
 
-static void raw6_exit_net(struct net *net)
+static void __net_exit raw6_exit_net(struct net *net)
 {
 	proc_net_remove(net, "raw6");
 }
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -672,7 +672,7 @@ static struct ctl_table ip6_frags_ctl_table[] = {
 	{ }
 };
 
-static int ip6_frags_ns_sysctl_register(struct net *net)
+static int __net_init ip6_frags_ns_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
 	struct ctl_table_header *hdr;
@@ -702,7 +702,7 @@ err_alloc:
 	return -ENOMEM;
 }
 
-static void ip6_frags_ns_sysctl_unregister(struct net *net)
+static void __net_exit ip6_frags_ns_sysctl_unregister(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -745,7 +745,7 @@ static inline void ip6_frags_sysctl_unregister(void)
 }
 #endif
 
-static int ipv6_frags_init_net(struct net *net)
+static int __net_init ipv6_frags_init_net(struct net *net)
 {
 	net->ipv6.frags.high_thresh = 256 * 1024;
 	net->ipv6.frags.low_thresh = 192 * 1024;
@@ -756,7 +756,7 @@ static int ipv6_frags_init_net(struct net *net)
 	return ip6_frags_ns_sysctl_register(net);
 }
 
-static void ipv6_frags_exit_net(struct net *net)
+static void __net_exit ipv6_frags_exit_net(struct net *net)
 {
 	ip6_frags_ns_sysctl_unregister(net);
 	inet_frags_exit_net(&net->ipv6.frags, &ip6_frags);
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2603,7 +2603,7 @@ ctl_table ipv6_route_table_template[] = {
 	{ }
 };
 
-struct ctl_table *ipv6_route_sysctl_init(struct net *net)
+struct ctl_table * __net_init ipv6_route_sysctl_init(struct net *net)
 {
 	struct ctl_table *table;
 
@@ -2628,7 +2628,7 @@ struct ctl_table *ipv6_route_sysctl_init(struct net *net)
 }
 #endif
 
-static int ip6_route_net_init(struct net *net)
+static int __net_init ip6_route_net_init(struct net *net)
 {
 	int ret = -ENOMEM;
 
@@ -2693,7 +2693,7 @@ out_ip6_dst_ops:
 	goto out;
 }
 
-static void ip6_route_net_exit(struct net *net)
+static void __net_exit ip6_route_net_exit(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	proc_net_remove(net, "ipv6_route");
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -62,7 +62,6 @@
 #define HASH_SIZE  16
 #define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
 
-static void ipip6_fb_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_init(struct net_device *dev);
 static void ipip6_tunnel_setup(struct net_device *dev);
 
@@ -1120,7 +1119,7 @@ static void ipip6_tunnel_init(struct net_device *dev)
 	ipip6_tunnel_bind_dev(dev);
 }
 
-static void ipip6_fb_tunnel_init(struct net_device *dev)
+static void __net_init ipip6_fb_tunnel_init(struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	struct iphdr *iph = &tunnel->parms.iph;
@@ -1145,7 +1144,7 @@ static struct xfrm_tunnel sit_handler = {
 	.priority	=	1,
 };
 
-static void sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
+static void __net_exit sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
 {
 	int prio;
 
@@ -1162,7 +1161,7 @@ static void sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
 	}
 }
 
-static int sit_init_net(struct net *net)
+static int __net_init sit_init_net(struct net *net)
 {
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 	int err;
@@ -1195,7 +1194,7 @@ err_alloc_dev:
 	return err;
 }
 
-static void sit_exit_net(struct net *net)
+static void __net_exit sit_exit_net(struct net *net)
 {
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 	LIST_HEAD(list);
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -54,7 +54,7 @@ struct ctl_path net_ipv6_ctl_path[] = {
 };
 EXPORT_SYMBOL_GPL(net_ipv6_ctl_path);
 
-static int ipv6_sysctl_net_init(struct net *net)
+static int __net_init ipv6_sysctl_net_init(struct net *net)
 {
 	struct ctl_table *ipv6_table;
 	struct ctl_table *ipv6_route_table;
@@ -97,7 +97,7 @@ out_ipv6_table:
 	goto out;
 }
 
-static void ipv6_sysctl_net_exit(struct net *net)
+static void __net_exit ipv6_sysctl_net_exit(struct net *net)
 {
 	struct ctl_table *ipv6_table;
 	struct ctl_table *ipv6_route_table;
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2105,7 +2105,7 @@ static struct tcp_seq_afinfo tcp6_seq_afinfo = {
 	},
 };
 
-int tcp6_proc_init(struct net *net)
+int __net_init tcp6_proc_init(struct net *net)
 {
 	return tcp_proc_register(net, &tcp6_seq_afinfo);
 }
@@ -2174,18 +2174,18 @@ static struct inet_protosw tcpv6_protosw = {
 				INET_PROTOSW_ICSK,
 };
 
-static int tcpv6_net_init(struct net *net)
+static int __net_init tcpv6_net_init(struct net *net)
 {
 	return inet_ctl_sock_create(&net->ipv6.tcp_sk, PF_INET6,
 				    SOCK_RAW, IPPROTO_TCP, net);
 }
 
-static void tcpv6_net_exit(struct net *net)
+static void __net_exit tcpv6_net_exit(struct net *net)
 {
 	inet_ctl_sock_destroy(net->ipv6.tcp_sk);
 }
 
-static void tcpv6_net_exit_batch(struct list_head *net_exit_list)
+static void __net_exit tcpv6_net_exit_batch(struct list_head *net_exit_list)
 {
 	inet_twsk_purge(&tcp_hashinfo, &tcp_death_row, AF_INET6);
 }
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1396,7 +1396,7 @@ static struct udp_seq_afinfo udp6_seq_afinfo = {
 	},
 };
 
-int udp6_proc_init(struct net *net)
+int __net_init udp6_proc_init(struct net *net)
 {
 	return udp_proc_register(net, &udp6_seq_afinfo);
 }
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -104,12 +104,12 @@ static struct udp_seq_afinfo udplite6_seq_afinfo = {
 	},
 };
 
-static int udplite6_proc_init_net(struct net *net)
+static int __net_init udplite6_proc_init_net(struct net *net)
 {
 	return udp_proc_register(net, &udplite6_seq_afinfo);
 }
 
-static void udplite6_proc_exit_net(struct net *net)
+static void __net_exit udplite6_proc_exit_net(struct net *net)
 {
 	udp_proc_unregister(net, &udplite6_seq_afinfo);
 }
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3738,17 +3738,17 @@ static int __net_init pfkey_init_proc(struct net *net)
 	return 0;
 }
 
-static void pfkey_exit_proc(struct net *net)
+static void __net_exit pfkey_exit_proc(struct net *net)
 {
 	proc_net_remove(net, "pfkey");
 }
 #else
-static int __net_init pfkey_init_proc(struct net *net)
+static inline int pfkey_init_proc(struct net *net)
 {
 	return 0;
 }
 
-static void pfkey_exit_proc(struct net *net)
+static inline void pfkey_exit_proc(struct net *net)
 {
 }
 #endif
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2448,7 +2448,7 @@ static const struct file_operations packet_seq_fops = {
 
 #endif
 
-static int packet_net_init(struct net *net)
+static int __net_init packet_net_init(struct net *net)
 {
 	rwlock_init(&net->packet.sklist_lock);
 	INIT_HLIST_HEAD(&net->packet.sklist);
@@ -2459,7 +2459,7 @@ static int packet_net_init(struct net *net)
 	return 0;
 }
 
-static void packet_net_exit(struct net *net)
+static void __net_exit packet_net_exit(struct net *net)
 {
 	proc_net_remove(net, "packet");
 }
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -311,7 +311,7 @@ static struct notifier_block phonet_device_notifier = {
 };
 
 /* Per-namespace Phonet devices handling */
-static int phonet_init_net(struct net *net)
+static int __net_init phonet_init_net(struct net *net)
 {
 	struct phonet_net *pnn = net_generic(net, phonet_net_id);
 
@@ -324,7 +324,7 @@ static int phonet_init_net(struct net *net)
 	return 0;
 }
 
-static void phonet_exit_net(struct net *net)
+static void __net_exit phonet_exit_net(struct net *net)
 {
 	struct phonet_net *pnn = net_generic(net, phonet_net_id);
 	struct net_device *dev;
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -71,7 +71,7 @@ static struct ctl_table_root net_sysctl_ro_root = {
 	.permissions = net_ctl_ro_header_perms,
 };
 
-static int sysctl_net_init(struct net *net)
+static int __net_init sysctl_net_init(struct net *net)
 {
 	setup_sysctl_set(&net->sysctls,
 			 &net_sysctl_ro_root.default_set,
@@ -79,7 +79,7 @@ static int sysctl_net_init(struct net *net)
 	return 0;
 }
 
-static void sysctl_net_exit(struct net *net)
+static void __net_exit sysctl_net_exit(struct net *net)
 {
 	WARN_ON(!list_empty(&net->sysctls.list));
 	return;
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2224,7 +2224,7 @@ static const struct net_proto_family unix_family_ops = {
 };
 
 
-static int unix_net_init(struct net *net)
+static int __net_init unix_net_init(struct net *net)
 {
 	int error = -ENOMEM;
 
@@ -2243,7 +2243,7 @@ out:
 	return error;
 }
 
-static void unix_net_exit(struct net *net)
+static void __net_exit unix_net_exit(struct net *net)
 {
 	unix_sysctl_unregister(net);
 	proc_net_remove(net, "unix");
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -31,7 +31,7 @@ static struct ctl_path unix_path[] = {
 	{ },
 };
 
-int unix_sysctl_register(struct net *net)
+int __net_init unix_sysctl_register(struct net *net)
 {
 	struct ctl_table *table;
 
--- a/net/wireless/wext-proc.c
+++ b/net/wireless/wext-proc.c
@@ -140,7 +140,7 @@ static const struct file_operations wireless_seq_fops = {
 	.release = seq_release_net,
 };
 
-int wext_proc_init(struct net *net)
+int __net_init wext_proc_init(struct net *net)
 {
 	/* Create /proc/net/wireless entry */
 	if (!proc_net_fops_create(net, "wireless", S_IRUGO, &wireless_seq_fops))
@@ -149,7 +149,7 @@ int wext_proc_init(struct net *net)
 	return 0;
 }
 
-void wext_proc_exit(struct net *net)
+void __net_exit wext_proc_exit(struct net *net)
 {
 	proc_net_remove(net, "wireless");
 }
--- a/net/xfrm/xfrm_sysctl.c
+++ b/net/xfrm/xfrm_sysctl.c
@@ -2,7 +2,7 @@
 #include <net/net_namespace.h>
 #include <net/xfrm.h>
 
-static void __xfrm_sysctl_init(struct net *net)
+static void __net_init __xfrm_sysctl_init(struct net *net)
 {
 	net->xfrm.sysctl_aevent_etime = XFRM_AE_ETIME;
 	net->xfrm.sysctl_aevent_rseqth = XFRM_AE_SEQT_SIZE;
@@ -64,7 +64,7 @@ out_kmemdup:
 	return -ENOMEM;
 }
 
-void xfrm_sysctl_fini(struct net *net)
+void __net_exit xfrm_sysctl_fini(struct net *net)
 {
 	struct ctl_table *table;
 
