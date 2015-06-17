From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 23/43] netfilter: Add a struct net parameter to nf_unregister_hook[s]
Date: Wed, 17 Jun 2015 10:28:32 -0500
Message-ID: <1434554932-4552-23-git-send-email-ebiederm@xmission.com>
References: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W Biederman <ebiederm@xmission.com>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h                      | 4 ++--
 net/bridge/br_netfilter.c                      | 4 ++--
 net/bridge/netfilter/ebtable_filter.c          | 2 +-
 net/bridge/netfilter/ebtable_nat.c             | 2 +-
 net/decnet/netfilter/dn_rtmsg.c                | 2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             | 2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              | 4 ++--
 net/ipv4/netfilter/iptable_nat.c               | 2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c | 4 ++--
 net/ipv4/netfilter/nf_defrag_ipv4.c            | 2 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             | 4 ++--
 net/ipv6/netfilter/ip6table_nat.c              | 2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c | 4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      | 2 +-
 net/netfilter/core.c                           | 9 +++++----
 net/netfilter/ipvs/ip_vs_core.c                | 4 ++--
 net/netfilter/nf_tables_api.c                  | 2 +-
 net/netfilter/x_tables.c                       | 2 +-
 security/selinux/hooks.c                       | 2 +-
 19 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 6e83def032fa..3097a3e7a049 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -122,9 +122,9 @@ struct nf_sockopt_ops {
 
 /* Function to register/unregister hook points. */
 int nf_register_hook(struct net *net, struct nf_hook_ops *reg);
-void nf_unregister_hook(struct nf_hook_ops *reg);
+void nf_unregister_hook(struct net *net, struct nf_hook_ops *reg);
 int nf_register_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n);
-void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n);
+void nf_unregister_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n);
 
 /* Functions to register get/setsockopt ranges (non-inclusive).  You
    need to check permissions yourself! */
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 9267b58d6375..15d0f3b78145 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -1259,7 +1259,7 @@ static int __init br_netfilter_init(void)
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
-		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+		nf_unregister_hooks(&init_net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
 		return -ENOMEM;
 	}
 #endif
@@ -1271,7 +1271,7 @@ static int __init br_netfilter_init(void)
 static void __exit br_netfilter_fini(void)
 {
 	RCU_INIT_POINTER(nf_br_ops, NULL);
-	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	nf_unregister_hooks(&init_net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index b68662c34315..a3dc249945ec 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -126,7 +126,7 @@ static int __init ebtable_filter_init(void)
 
 static void __exit ebtable_filter_fini(void)
 {
-	nf_unregister_hooks(ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
+	nf_unregister_hooks(&init_net, ebt_ops_filter, ARRAY_SIZE(ebt_ops_filter));
 	unregister_pernet_subsys(&frame_filter_net_ops);
 }
 
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 50d27183afec..11bf447f8b46 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -126,7 +126,7 @@ static int __init ebtable_nat_init(void)
 
 static void __exit ebtable_nat_fini(void)
 {
-	nf_unregister_hooks(ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
+	nf_unregister_hooks(&init_net, ebt_ops_nat, ARRAY_SIZE(ebt_ops_nat));
 	unregister_pernet_subsys(&frame_nat_net_ops);
 }
 
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index f18562975430..0dee61296745 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -144,7 +144,7 @@ static int __init dn_rtmsg_init(void)
 
 static void __exit dn_rtmsg_fini(void)
 {
-	nf_unregister_hook(&dnrmg_ops);
+	nf_unregister_hook(&init_net, &dnrmg_ops);
 	netlink_kernel_release(dnrmg);
 }
 
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 531ee65d8cc1..abbf0c0052af 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -787,7 +787,7 @@ static void __exit clusterip_tg_exit(void)
 {
 	pr_info("ClusterIP Version %s unloading\n", CLUSTERIP_VERSION);
 
-	nf_unregister_hook(&cip_arp_ops);
+	nf_unregister_hook(&init_net, &cip_arp_ops);
 	xt_unregister_target(&clusterip_tg_reg);
 	unregister_pernet_subsys(&clusterip_net_ops);
 
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index 3e97074cde51..301bb886a289 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -462,7 +462,7 @@ static int __init synproxy_tg4_init(void)
 	return 0;
 
 err2:
-	nf_unregister_hooks(ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
+	nf_unregister_hooks(&init_net, ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
 err1:
 	return err;
 }
@@ -470,7 +470,7 @@ err1:
 static void __exit synproxy_tg4_exit(void)
 {
 	xt_unregister_target(&synproxy_tg4_reg);
-	nf_unregister_hooks(ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
+	nf_unregister_hooks(&init_net, ipv4_synproxy_ops, ARRAY_SIZE(ipv4_synproxy_ops));
 }
 
 module_init(synproxy_tg4_init);
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index fa5de3731680..5a1c7f2cdcbb 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -143,7 +143,7 @@ err1:
 
 static void __exit iptable_nat_exit(void)
 {
-	nf_unregister_hooks(nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
+	nf_unregister_hooks(&init_net, nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
 	unregister_pernet_subsys(&iptable_nat_net_ops);
 }
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index f802f76104ff..abf6f60e80fe 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -515,7 +515,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
  cleanup_tcp4:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
  cleanup_hooks:
-	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
+	nf_unregister_hooks(&init_net, ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv4_net_ops);
  cleanup_sockopt:
@@ -533,7 +533,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmp);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp4);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
-	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
+	nf_unregister_hooks(&init_net, ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 	unregister_pernet_subsys(&ipv4_net_ops);
 	nf_unregister_sockopt(&so_getorigdst);
 }
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index a91c1b96b104..e9f4088d4759 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -117,7 +117,7 @@ static int __init nf_defrag_init(void)
 
 static void __exit nf_defrag_fini(void)
 {
-	nf_unregister_hooks(ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
+	nf_unregister_hooks(&init_net, ipv4_defrag_ops, ARRAY_SIZE(ipv4_defrag_ops));
 }
 
 void nf_defrag_ipv4_enable(void)
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 1ec9e1531e17..320521086b5c 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -485,7 +485,7 @@ static int __init synproxy_tg6_init(void)
 	return 0;
 
 err2:
-	nf_unregister_hooks(ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
+	nf_unregister_hooks(&init_net, ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
 err1:
 	return err;
 }
@@ -493,7 +493,7 @@ err1:
 static void __exit synproxy_tg6_exit(void)
 {
 	xt_unregister_target(&synproxy_tg6_reg);
-	nf_unregister_hooks(ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
+	nf_unregister_hooks(&init_net, ipv6_synproxy_ops, ARRAY_SIZE(ipv6_synproxy_ops));
 }
 
 module_init(synproxy_tg6_init);
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 57d1fbc71943..ce7e99c4fd38 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -145,7 +145,7 @@ err1:
 
 static void __exit ip6table_nat_exit(void)
 {
-	nf_unregister_hooks(nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
+	nf_unregister_hooks(&init_net, nf_nat_ipv6_ops, ARRAY_SIZE(nf_nat_ipv6_ops));
 	unregister_pernet_subsys(&ip6table_nat_net_ops);
 }
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 0e74254180aa..710ed6607e66 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -447,7 +447,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
  cleanup_tcp6:
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
  cleanup_hooks:
-	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
+	nf_unregister_hooks(&init_net, ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
  cleanup_pernet:
 	unregister_pernet_subsys(&ipv6_net_ops);
  cleanup_sockopt:
@@ -462,7 +462,7 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_udp6);
 	nf_ct_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
-	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
+	nf_unregister_hooks(&init_net, ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
 	unregister_pernet_subsys(&ipv6_net_ops);
 	nf_unregister_sockopt(&so_getorigdst6);
 }
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 922088fd6e32..2bd7aa696382 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -125,7 +125,7 @@ cleanup_frag6:
 
 static void __exit nf_defrag_fini(void)
 {
-	nf_unregister_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
+	nf_unregister_hooks(&init_net, ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
 	nf_ct_frag6_cleanup();
 }
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index e673eb8df49a..8fba484532be 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -97,7 +97,7 @@ int nf_register_hook(struct net *net, struct nf_hook_ops *reg)
 }
 EXPORT_SYMBOL(nf_register_hook);
 
-void nf_unregister_hook(struct nf_hook_ops *reg)
+void nf_unregister_hook(struct net *net, struct nf_hook_ops *reg)
 {
 	mutex_lock(&nf_hook_mutex);
 	list_del_rcu(&reg->list);
@@ -135,15 +135,16 @@ int nf_register_hooks(struct net *net, struct nf_hook_ops *reg, unsigned int n)
 
 err:
 	if (i > 0)
-		nf_unregister_hooks(reg, i);
+		nf_unregister_hooks(net, reg, i);
 	return err;
 }
 EXPORT_SYMBOL(nf_register_hooks);
 
-void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
+void nf_unregister_hooks(struct net *net, struct nf_hook_ops *reg,
+			 unsigned int n)
 {
 	while (n-- > 0)
-		nf_unregister_hook(&reg[n]);
+		nf_unregister_hook(net, &reg[n]);
 }
 EXPORT_SYMBOL(nf_unregister_hooks);
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 6f548ff08925..1ab42bfe6020 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -2105,7 +2105,7 @@ static int __init ip_vs_init(void)
 	return ret;
 
 cleanup_hooks:
-	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	nf_unregister_hooks(&init_net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 cleanup_dev:
 	unregister_pernet_device(&ipvs_core_dev_ops);
 cleanup_sub:
@@ -2122,7 +2122,7 @@ exit:
 static void __exit ip_vs_cleanup(void)
 {
 	ip_vs_unregister_nl_ioctl();
-	nf_unregister_hooks(ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
+	nf_unregister_hooks(&init_net, ip_vs_ops, ARRAY_SIZE(ip_vs_ops));
 	unregister_pernet_device(&ipvs_core_dev_ops);
 	unregister_pernet_subsys(&ipvs_core_ops);	/* free ip_vs struct */
 	ip_vs_conn_cleanup();
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index d444526b39f9..ce996362083f 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -143,7 +143,7 @@ void nft_unregister_basechain(struct nft_base_chain *basechain,
 	if (basechain->flags & NFT_BASECHAIN_DISABLED)
 		return;
 
-	nf_unregister_hooks(basechain->ops, hook_nops);
+	nf_unregister_hooks(&init_net, basechain->ops, hook_nops);
 }
 EXPORT_SYMBOL_GPL(nft_unregister_basechain);
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index c8ab3e6231c4..e703310121cf 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1210,7 +1210,7 @@ EXPORT_SYMBOL_GPL(xt_hook_link);
  */
 void xt_hook_unlink(const struct xt_table *table, struct nf_hook_ops *ops)
 {
-	nf_unregister_hooks(ops, hweight32(table->valid_hooks));
+	nf_unregister_hooks(&init_net, ops, hweight32(table->valid_hooks));
 	kfree(ops);
 }
 EXPORT_SYMBOL_GPL(xt_hook_unlink);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 74876587b34e..21a5e07b6834 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -6171,7 +6171,7 @@ static void selinux_nf_ip_exit(void)
 {
 	printk(KERN_DEBUG "SELinux:  Unregistering netfilter hooks\n");
 
-	nf_unregister_hooks(selinux_nf_ops, ARRAY_SIZE(selinux_nf_ops));
+	nf_unregister_hooks(&init_net, selinux_nf_ops, ARRAY_SIZE(selinux_nf_ops));
 }
 #endif
 
-- 
2.2.1

