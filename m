From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 20/43] netfilter: Pass priv instead of nf_hook_ops to netfilter hooks
Date: Wed, 17 Jun 2015 10:28:29 -0500
Message-ID: <1434554932-4552-20-git-send-email-ebiederm@xmission.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45916 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757506AbbFQPic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 11:38:32 -0400
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W Biederman <ebiederm@xmission.com>

Only pass the void *priv parameter out of the nf_hook_ops.  That is
all any of the functions are interested now, and by limiting what is
passed it becomes simpler to change implementation details.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h                      |  2 +-
 include/net/netfilter/nf_nat_l3proto.h         | 32 +++++++++++++-------------
 include/net/netfilter/nf_tables.h              |  3 +--
 net/bridge/br_netfilter.c                      | 17 +++++++-------
 net/bridge/netfilter/ebtable_filter.c          |  4 ++--
 net/bridge/netfilter/ebtable_nat.c             |  4 ++--
 net/bridge/netfilter/nf_tables_bridge.c        |  4 ++--
 net/decnet/netfilter/dn_rtmsg.c                |  2 +-
 net/ipv4/netfilter/arptable_filter.c           |  2 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |  2 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  2 +-
 net/ipv4/netfilter/iptable_filter.c            |  2 +-
 net/ipv4/netfilter/iptable_mangle.c            |  2 +-
 net/ipv4/netfilter/iptable_nat.c               | 18 +++++++--------
 net/ipv4/netfilter/iptable_raw.c               |  2 +-
 net/ipv4/netfilter/iptable_security.c          |  2 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  8 +++----
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  2 +-
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       | 24 +++++++++----------
 net/ipv4/netfilter/nf_tables_arp.c             |  4 ++--
 net/ipv4/netfilter/nf_tables_ipv4.c            |  8 +++----
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        | 20 ++++++++--------
 net/ipv4/netfilter/nft_chain_route_ipv4.c      |  4 ++--
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  2 +-
 net/ipv6/netfilter/ip6table_filter.c           |  2 +-
 net/ipv6/netfilter/ip6table_mangle.c           |  2 +-
 net/ipv6/netfilter/ip6table_nat.c              | 18 +++++++--------
 net/ipv6/netfilter/ip6table_raw.c              |  2 +-
 net/ipv6/netfilter/ip6table_security.c         |  2 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  8 +++----
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |  2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       | 24 +++++++++----------
 net/ipv6/netfilter/nf_tables_ipv6.c            |  8 +++----
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        | 20 ++++++++--------
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |  4 ++--
 net/netfilter/core.c                           |  2 +-
 net/netfilter/ipvs/ip_vs_core.c                | 24 +++++++++----------
 net/netfilter/nf_tables_core.c                 |  4 ++--
 net/netfilter/nf_tables_netdev.c               |  4 ++--
 security/selinux/hooks.c                       | 10 ++++----
 security/smack/smack_netfilter.c               |  4 ++--
 41 files changed, 155 insertions(+), 157 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index c10a13697e5e..f23e121f372b 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -78,7 +78,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 	p->okfn = okfn;
 }
 
-typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
+typedef unsigned int nf_hookfn(void *priv,
 			       struct sk_buff *skb,
 			       const struct nf_hook_state *state);
 
diff --git a/include/net/netfilter/nf_nat_l3proto.h b/include/net/netfilter/nf_nat_l3proto.h
index a3127325f624..aef3e5fc9fd9 100644
--- a/include/net/netfilter/nf_nat_l3proto.h
+++ b/include/net/netfilter/nf_nat_l3proto.h
@@ -43,31 +43,31 @@ int nf_nat_icmp_reply_translation(struct sk_buff *skb, struct nf_conn *ct,
 				  enum ip_conntrack_info ctinfo,
 				  unsigned int hooknum);
 
-unsigned int nf_nat_ipv4_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
+unsigned int nf_nat_ipv4_in(void *priv, struct sk_buff *skb,
 			    const struct nf_hook_state *state,
-			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+			    unsigned int (*do_chain)(void *priv,
 						     struct sk_buff *skb,
 						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
 
-unsigned int nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
+unsigned int nf_nat_ipv4_out(void *priv, struct sk_buff *skb,
 			     const struct nf_hook_state *state,
-			     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+			     unsigned int (*do_chain)(void *priv,
 						      struct sk_buff *skb,
 						      const struct nf_hook_state *state,
 						      struct nf_conn *ct));
 
-unsigned int nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
+unsigned int nf_nat_ipv4_local_fn(void *priv,
 				  struct sk_buff *skb,
 				  const struct nf_hook_state *state,
-				  unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+				  unsigned int (*do_chain)(void *priv,
 							   struct sk_buff *skb,
 							   const struct nf_hook_state *state,
 							   struct nf_conn *ct));
 
-unsigned int nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
+unsigned int nf_nat_ipv4_fn(void *priv, struct sk_buff *skb,
 			    const struct nf_hook_state *state,
-			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+			    unsigned int (*do_chain)(void *priv,
 						     struct sk_buff *skb,
 						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
@@ -76,31 +76,31 @@ int nf_nat_icmpv6_reply_translation(struct sk_buff *skb, struct nf_conn *ct,
 				    enum ip_conntrack_info ctinfo,
 				    unsigned int hooknum, unsigned int hdrlen);
 
-unsigned int nf_nat_ipv6_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
+unsigned int nf_nat_ipv6_in(void *priv, struct sk_buff *skb,
 			    const struct nf_hook_state *state,
-			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+			    unsigned int (*do_chain)(void *priv,
 						     struct sk_buff *skb,
 						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
 
-unsigned int nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
+unsigned int nf_nat_ipv6_out(void *priv, struct sk_buff *skb,
 			     const struct nf_hook_state *state,
-			     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+			     unsigned int (*do_chain)(void *priv,
 						      struct sk_buff *skb,
 						      const struct nf_hook_state *state,
 						      struct nf_conn *ct));
 
-unsigned int nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
+unsigned int nf_nat_ipv6_local_fn(void *priv,
 				  struct sk_buff *skb,
 				  const struct nf_hook_state *state,
-				  unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+				  unsigned int (*do_chain)(void *priv,
 							   struct sk_buff *skb,
 							   const struct nf_hook_state *state,
 							   struct nf_conn *ct));
 
-unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
+unsigned int nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 			    const struct nf_hook_state *state,
-			    unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+			    unsigned int (*do_chain)(void *priv,
 						     struct sk_buff *skb,
 						     const struct nf_hook_state *state,
 						     struct nf_conn *ct));
diff --git a/include/net/netfilter/nf_tables.h b/include/net/netfilter/nf_tables.h
index a028f0280cfd..8a61d8c14943 100644
--- a/include/net/netfilter/nf_tables.h
+++ b/include/net/netfilter/nf_tables.h
@@ -816,8 +816,7 @@ int nft_register_basechain(struct nft_base_chain *basechain,
 void nft_unregister_basechain(struct nft_base_chain *basechain,
 			      unsigned int hook_nops);
 
-unsigned int nft_do_chain(struct nft_pktinfo *pkt,
-			  const struct nf_hook_ops *ops);
+unsigned int nft_do_chain(struct nft_pktinfo *pkt, void *priv);
 
 /**
  *	struct nft_table - nf_tables table
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 8f67a93ffeac..46005603a4da 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -664,8 +664,7 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 /* Replicate the checks that IPv6 does on packet reception and pass the packet
  * to ip6tables.
  */
-static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
-					   struct sk_buff *skb,
+static unsigned int br_nf_pre_routing_ipv6(struct sk_buff *skb,
 					   const struct nf_hook_state *state)
 {
 	struct nf_bridge_info *nf_bridge;
@@ -696,7 +695,7 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
  * receiving device) to make netfilter happy, the REDIRECT
  * target in particular.  Save the original destination IP
  * address to be able to detect DNAT afterwards. */
-static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
+static unsigned int br_nf_pre_routing(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
@@ -718,7 +717,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 			return NF_ACCEPT;
 
 		nf_bridge_pull_encap_header_rcsum(skb);
-		return br_nf_pre_routing_ipv6(ops, skb, state);
+		return br_nf_pre_routing_ipv6(skb, state);
 	}
 
 	if (!brnf_call_iptables && !br->nf_call_iptables)
@@ -758,7 +757,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
  * took place when the packet entered the bridge), but we
  * register an IPv4 PRE_ROUTING 'sabotage' hook that will
  * prevent this from happening. */
-static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
+static unsigned int br_nf_local_in(void *priv,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
@@ -804,7 +803,7 @@ static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
  * but we are still able to filter on the 'real' indev/outdev
  * because of the physdev module. For ARP, indev and outdev are the
  * bridge ports. */
-static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
+static unsigned int br_nf_forward_ip(void *priv,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
@@ -867,7 +866,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	return NF_STOLEN;
 }
 
-static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
+static unsigned int br_nf_forward_arp(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
@@ -1026,7 +1025,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 }
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
-static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
+static unsigned int br_nf_post_routing(void *priv,
 				       struct sk_buff *skb,
 				       const struct nf_hook_state *state)
 {
@@ -1075,7 +1074,7 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 /* IP/SABOTAGE *****************************************************/
 /* Don't hand locally destined packets to PF_INET(6)/PRE_ROUTING
  * for the second time. */
-static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
+static unsigned int ip_sabotage_in(void *priv,
 				   struct sk_buff *skb,
 				   const struct nf_hook_state *state)
 {
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 118ce40ac181..f9242dffa65e 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -57,14 +57,14 @@ static const struct ebt_table frame_filter = {
 };
 
 static unsigned int
-ebt_in_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_in_hook(void *priv, struct sk_buff *skb,
 	    const struct nf_hook_state *state)
 {
 	return ebt_do_table(skb, state, state->net->xt.frame_filter);
 }
 
 static unsigned int
-ebt_out_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_out_hook(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
 	return ebt_do_table(skb, state, state->net->xt.frame_filter);
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 56c3329d6c37..4bbefe03ab58 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -57,14 +57,14 @@ static struct ebt_table frame_nat = {
 };
 
 static unsigned int
-ebt_nat_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_nat_in(void *priv, struct sk_buff *skb,
 	   const struct nf_hook_state *state)
 {
 	return ebt_do_table(skb, state, state->net->xt.frame_nat);
 }
 
 static unsigned int
-ebt_nat_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_nat_out(void *priv, struct sk_buff *skb,
 	    const struct nf_hook_state *state)
 {
 	return ebt_do_table(skb, state, state->net->xt.frame_nat);
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 318d825e4207..62f6b1b19589 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -87,7 +87,7 @@ static inline void nft_bridge_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 }
 
 static unsigned int
-nft_do_chain_bridge(const struct nf_hook_ops *ops,
+nft_do_chain_bridge(void *priv,
 		    struct sk_buff *skb,
 		    const struct nf_hook_state *state)
 {
@@ -105,7 +105,7 @@ nft_do_chain_bridge(const struct nf_hook_ops *ops,
 		break;
 	}
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
 static struct nft_af_info nft_af_bridge __read_mostly = {
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index af34fc9bdf69..85f2fdc360c2 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -87,7 +87,7 @@ static void dnrmg_send_peer(struct sk_buff *skb)
 }
 
 
-static unsigned int dnrmg_hook(const struct nf_hook_ops *ops,
+static unsigned int dnrmg_hook(void *priv,
 			struct sk_buff *skb,
 			const struct nf_hook_state *state)
 {
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 1352e12d4068..1897ee160920 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -27,7 +27,7 @@ static const struct xt_table packet_filter = {
 
 /* The work comes in here from netfilter.c */
 static unsigned int
-arptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+arptable_filter_hook(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	return arpt_do_table(skb, state, state->net->ipv4.arptable_filter);
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 69157d8eba95..3f32c03e8b2e 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -507,7 +507,7 @@ static void arp_print(struct arp_payload *payload)
 #endif
 
 static unsigned int
-arp_mangle(const struct nf_hook_ops *ops,
+arp_mangle(void *priv,
 	   struct sk_buff *skb,
 	   const struct nf_hook_state *state)
 {
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index d7e0cae197af..72b606bc73fe 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -298,7 +298,7 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-static unsigned int ipv4_synproxy_hook(const struct nf_hook_ops *ops,
+static unsigned int ipv4_synproxy_hook(void *priv,
 				       struct sk_buff *skb,
 				       const struct nf_hook_state *nhs)
 {
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 02d4c5395d6e..397ef2dd133e 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -33,7 +33,7 @@ static const struct xt_table packet_filter = {
 };
 
 static unsigned int
-iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+iptable_filter_hook(void *priv, struct sk_buff *skb,
 		    const struct nf_hook_state *state)
 {
 	if (state->hook == NF_INET_LOCAL_OUT &&
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index dc2ff6884999..2d6fc911866f 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -78,7 +78,7 @@ ipt_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-iptable_mangle_hook(const struct nf_hook_ops *ops,
+iptable_mangle_hook(void *priv,
 		     struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index 8ff63ac1f0d6..3a2e4d830a0b 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -28,7 +28,7 @@ static const struct xt_table nf_nat_ipv4_table = {
 	.af		= NFPROTO_IPV4,
 };
 
-static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
+static unsigned int iptable_nat_do_chain(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state,
 					 struct nf_conn *ct)
@@ -36,32 +36,32 @@ static unsigned int iptable_nat_do_chain(const struct nf_hook_ops *ops,
 	return ipt_do_table(skb, state, state->net->ipv4.nat_table);
 }
 
-static unsigned int iptable_nat_ipv4_fn(const struct nf_hook_ops *ops,
+static unsigned int iptable_nat_ipv4_fn(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_fn(ops, skb, state, iptable_nat_do_chain);
+	return nf_nat_ipv4_fn(priv, skb, state, iptable_nat_do_chain);
 }
 
-static unsigned int iptable_nat_ipv4_in(const struct nf_hook_ops *ops,
+static unsigned int iptable_nat_ipv4_in(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_in(ops, skb, state, iptable_nat_do_chain);
+	return nf_nat_ipv4_in(priv, skb, state, iptable_nat_do_chain);
 }
 
-static unsigned int iptable_nat_ipv4_out(const struct nf_hook_ops *ops,
+static unsigned int iptable_nat_ipv4_out(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_out(ops, skb, state, iptable_nat_do_chain);
+	return nf_nat_ipv4_out(priv, skb, state, iptable_nat_do_chain);
 }
 
-static unsigned int iptable_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
+static unsigned int iptable_nat_ipv4_local_fn(void *priv,
 					      struct sk_buff *skb,
 					      const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_local_fn(ops, skb, state, iptable_nat_do_chain);
+	return nf_nat_ipv4_local_fn(priv, skb, state, iptable_nat_do_chain);
 }
 
 static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index bbb0523d87de..1ba02811acb0 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -20,7 +20,7 @@ static const struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+iptable_raw_hook(void *priv, struct sk_buff *skb,
 		 const struct nf_hook_state *state)
 {
 	if (state->hook == NF_INET_LOCAL_OUT &&
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index b92417038705..f534e2f05bad 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -37,7 +37,7 @@ static const struct xt_table security_table = {
 };
 
 static unsigned int
-iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+iptable_security_hook(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	if (state->hook == NF_INET_LOCAL_OUT &&
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 5be04dd8a797..df96b18a6162 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -92,7 +92,7 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	return NF_ACCEPT;
 }
 
-static unsigned int ipv4_helper(const struct nf_hook_ops *ops,
+static unsigned int ipv4_helper(void *priv,
 				struct sk_buff *skb,
 				const struct nf_hook_state *state)
 {
@@ -119,7 +119,7 @@ static unsigned int ipv4_helper(const struct nf_hook_ops *ops,
 			    ct, ctinfo);
 }
 
-static unsigned int ipv4_confirm(const struct nf_hook_ops *ops,
+static unsigned int ipv4_confirm(void *priv,
 				 struct sk_buff *skb,
 				 const struct nf_hook_state *state)
 {
@@ -143,14 +143,14 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int ipv4_conntrack_in(const struct nf_hook_ops *ops,
+static unsigned int ipv4_conntrack_in(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
 	return nf_conntrack_in(state->net, PF_INET, state->hook, skb);
 }
 
-static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
+static unsigned int ipv4_conntrack_local(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state)
 {
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 015787e47a7d..835e166e69ea 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -62,7 +62,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 		return IP_DEFRAG_CONNTRACK_OUT + zone;
 }
 
-static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
+static unsigned int ipv4_conntrack_defrag(void *priv,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index 82fd5501bce1..470a25390c08 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -255,9 +255,9 @@ int nf_nat_icmp_reply_translation(struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(nf_nat_icmp_reply_translation);
 
 unsigned int
-nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv4_fn(void *priv, struct sk_buff *skb,
 	       const struct nf_hook_state *state,
-	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+	       unsigned int (*do_chain)(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state,
 					struct nf_conn *ct))
@@ -308,7 +308,7 @@ nf_nat_ipv4_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		if (!nf_nat_initialized(ct, maniptype)) {
 			unsigned int ret;
 
-			ret = do_chain(ops, skb, state, ct);
+			ret = do_chain(priv, skb, state, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
 
@@ -345,9 +345,9 @@ oif_changed:
 EXPORT_SYMBOL_GPL(nf_nat_ipv4_fn);
 
 unsigned int
-nf_nat_ipv4_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv4_in(void *priv, struct sk_buff *skb,
 	       const struct nf_hook_state *state,
-	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+	       unsigned int (*do_chain)(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state,
 					 struct nf_conn *ct))
@@ -355,7 +355,7 @@ nf_nat_ipv4_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	unsigned int ret;
 	__be32 daddr = ip_hdr(skb)->daddr;
 
-	ret = nf_nat_ipv4_fn(ops, skb, state, do_chain);
+	ret = nf_nat_ipv4_fn(priv, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    daddr != ip_hdr(skb)->daddr)
 		skb_dst_drop(skb);
@@ -365,9 +365,9 @@ nf_nat_ipv4_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(nf_nat_ipv4_in);
 
 unsigned int
-nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv4_out(void *priv, struct sk_buff *skb,
 		const struct nf_hook_state *state,
-		unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+		unsigned int (*do_chain)(void *priv,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state,
 					  struct nf_conn *ct))
@@ -384,7 +384,7 @@ nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv4_fn(ops, skb, state, do_chain);
+	ret = nf_nat_ipv4_fn(priv, skb, state, do_chain);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
@@ -407,9 +407,9 @@ nf_nat_ipv4_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(nf_nat_ipv4_out);
 
 unsigned int
-nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv4_local_fn(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state,
-		     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+		     unsigned int (*do_chain)(void *priv,
 					       struct sk_buff *skb,
 					       const struct nf_hook_state *state,
 					       struct nf_conn *ct))
@@ -424,7 +424,7 @@ nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv4_fn(ops, skb, state, do_chain);
+	ret = nf_nat_ipv4_fn(priv, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 883bbf83fe09..9d09d4f59545 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -15,7 +15,7 @@
 #include <net/netfilter/nf_tables.h>
 
 static unsigned int
-nft_do_chain_arp(const struct nf_hook_ops *ops,
+nft_do_chain_arp(void *priv,
 		  struct sk_buff *skb,
 		  const struct nf_hook_state *state)
 {
@@ -23,7 +23,7 @@ nft_do_chain_arp(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo(&pkt, skb, state);
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
 static struct nft_af_info nft_af_arp __read_mostly = {
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 805be5c9fcc3..ca9dc3c46c4f 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -18,7 +18,7 @@
 #include <net/ip.h>
 #include <net/netfilter/nf_tables_ipv4.h>
 
-static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
+static unsigned int nft_do_chain_ipv4(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
@@ -26,10 +26,10 @@ static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo_ipv4(&pkt, skb, state);
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
-static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
+static unsigned int nft_ipv4_output(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
@@ -41,7 +41,7 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 
-	return nft_do_chain_ipv4(ops, skb, state);
+	return nft_do_chain_ipv4(priv, skb, state);
 }
 
 struct nft_af_info nft_af_ipv4 __read_mostly = {
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index c3ffecf28d38..f5c66a7a4bf2 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -26,7 +26,7 @@
 #include <net/netfilter/nf_nat_l3proto.h>
 #include <net/ip.h>
 
-static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_do_chain(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state,
 				      struct nf_conn *ct)
@@ -35,35 +35,35 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo_ipv4(&pkt, skb, state);
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
-static unsigned int nft_nat_ipv4_fn(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv4_fn(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_fn(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv4_fn(priv, skb, state, nft_nat_do_chain);
 }
 
-static unsigned int nft_nat_ipv4_in(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv4_in(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_in(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv4_in(priv, skb, state, nft_nat_do_chain);
 }
 
-static unsigned int nft_nat_ipv4_out(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv4_out(void *priv,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_out(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv4_out(priv, skb, state, nft_nat_do_chain);
 }
 
-static unsigned int nft_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv4_local_fn(void *priv,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv4_local_fn(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv4_local_fn(priv, skb, state, nft_nat_do_chain);
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv4 = {
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 2a1e3d8a3e43..9f486b302108 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -21,7 +21,7 @@
 #include <net/route.h>
 #include <net/ip.h>
 
-static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
+static unsigned int nf_route_table_hook(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
@@ -45,7 +45,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	daddr = iph->daddr;
 	tos = iph->tos;
 
-	ret = nft_do_chain(&pkt, ops);
+	ret = nft_do_chain(&pkt, priv);
 	if (ret != NF_DROP && ret != NF_QUEUE) {
 		iph = ip_hdr(skb);
 
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 41ce1d4018e2..9976fd648811 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -313,7 +313,7 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-static unsigned int ipv6_synproxy_hook(const struct nf_hook_ops *ops,
+static unsigned int ipv6_synproxy_hook(void *priv,
 				       struct sk_buff *skb,
 				       const struct nf_hook_state *nhs)
 {
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index a7327f61b90c..8b277b983ca5 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -32,7 +32,7 @@ static const struct xt_table packet_filter = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6table_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_filter_hook(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_filter);
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index c2e061dcedf3..8745b592b2f6 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -75,7 +75,7 @@ ip6t_mangle_out(struct sk_buff *skb, const struct nf_hook_state *state)
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6table_mangle_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_mangle_hook(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	if (state->hook == NF_INET_LOCAL_OUT)
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index efa6754c4d06..abea175d5853 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -30,7 +30,7 @@ static const struct xt_table nf_nat_ipv6_table = {
 	.af		= NFPROTO_IPV6,
 };
 
-static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
+static unsigned int ip6table_nat_do_chain(void *priv,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state,
 					  struct nf_conn *ct)
@@ -38,32 +38,32 @@ static unsigned int ip6table_nat_do_chain(const struct nf_hook_ops *ops,
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_nat);
 }
 
-static unsigned int ip6table_nat_fn(const struct nf_hook_ops *ops,
+static unsigned int ip6table_nat_fn(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_fn(ops, skb, state, ip6table_nat_do_chain);
+	return nf_nat_ipv6_fn(priv, skb, state, ip6table_nat_do_chain);
 }
 
-static unsigned int ip6table_nat_in(const struct nf_hook_ops *ops,
+static unsigned int ip6table_nat_in(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_in(ops, skb, state, ip6table_nat_do_chain);
+	return nf_nat_ipv6_in(priv, skb, state, ip6table_nat_do_chain);
 }
 
-static unsigned int ip6table_nat_out(const struct nf_hook_ops *ops,
+static unsigned int ip6table_nat_out(void *priv,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_out(ops, skb, state, ip6table_nat_do_chain);
+	return nf_nat_ipv6_out(priv, skb, state, ip6table_nat_do_chain);
 }
 
-static unsigned int ip6table_nat_local_fn(const struct nf_hook_ops *ops,
+static unsigned int ip6table_nat_local_fn(void *priv,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_local_fn(ops, skb, state, ip6table_nat_do_chain);
+	return nf_nat_ipv6_local_fn(priv, skb, state, ip6table_nat_do_chain);
 }
 
 static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index fac6ad7c0a7c..9021963565c3 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -19,7 +19,7 @@ static const struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6table_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_raw_hook(void *priv, struct sk_buff *skb,
 		  const struct nf_hook_state *state)
 {
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_raw);
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 96c94fc240c8..0d856fedfeb0 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -36,7 +36,7 @@ static const struct xt_table security_table = {
 };
 
 static unsigned int
-ip6table_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_security_hook(void *priv, struct sk_buff *skb,
 		       const struct nf_hook_state *state)
 {
 	return ip6t_do_table(skb, state, state->net->ipv6.ip6table_security);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 256a025ceb02..dcc0536cf61d 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -95,7 +95,7 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 	return NF_ACCEPT;
 }
 
-static unsigned int ipv6_helper(const struct nf_hook_ops *ops,
+static unsigned int ipv6_helper(void *priv,
 				struct sk_buff *skb,
 				const struct nf_hook_state *state)
 {
@@ -131,7 +131,7 @@ static unsigned int ipv6_helper(const struct nf_hook_ops *ops,
 	return helper->help(skb, protoff, ct, ctinfo);
 }
 
-static unsigned int ipv6_confirm(const struct nf_hook_ops *ops,
+static unsigned int ipv6_confirm(void *priv,
 				 struct sk_buff *skb,
 				 const struct nf_hook_state *state)
 {
@@ -165,14 +165,14 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int ipv6_conntrack_in(const struct nf_hook_ops *ops,
+static unsigned int ipv6_conntrack_in(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
 	return nf_conntrack_in(state->net, PF_INET6, state->hook, skb);
 }
 
-static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
+static unsigned int ipv6_conntrack_local(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state)
 {
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 5f443551a6d5..140112c6f867 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -52,7 +52,7 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 
 }
 
-static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
+static unsigned int ipv6_defrag(void *priv,
 				struct sk_buff *skb,
 				const struct nf_hook_state *state)
 {
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index 2cce12897c50..0311eb0af10f 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -262,9 +262,9 @@ int nf_nat_icmpv6_reply_translation(struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(nf_nat_icmpv6_reply_translation);
 
 unsigned int
-nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 	       const struct nf_hook_state *state,
-	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+	       unsigned int (*do_chain)(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state,
 					struct nf_conn *ct))
@@ -317,7 +317,7 @@ nf_nat_ipv6_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		if (!nf_nat_initialized(ct, maniptype)) {
 			unsigned int ret;
 
-			ret = do_chain(ops, skb, state, ct);
+			ret = do_chain(priv, skb, state, ct);
 			if (ret != NF_ACCEPT)
 				return ret;
 
@@ -353,9 +353,9 @@ oif_changed:
 EXPORT_SYMBOL_GPL(nf_nat_ipv6_fn);
 
 unsigned int
-nf_nat_ipv6_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv6_in(void *priv, struct sk_buff *skb,
 	       const struct nf_hook_state *state,
-	       unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+	       unsigned int (*do_chain)(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state,
 					struct nf_conn *ct))
@@ -363,7 +363,7 @@ nf_nat_ipv6_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	unsigned int ret;
 	struct in6_addr daddr = ipv6_hdr(skb)->daddr;
 
-	ret = nf_nat_ipv6_fn(ops, skb, state, do_chain);
+	ret = nf_nat_ipv6_fn(priv, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    ipv6_addr_cmp(&daddr, &ipv6_hdr(skb)->daddr))
 		skb_dst_drop(skb);
@@ -373,9 +373,9 @@ nf_nat_ipv6_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(nf_nat_ipv6_in);
 
 unsigned int
-nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv6_out(void *priv, struct sk_buff *skb,
 		const struct nf_hook_state *state,
-		unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+		unsigned int (*do_chain)(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state,
 					 struct nf_conn *ct))
@@ -391,7 +391,7 @@ nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv6_fn(ops, skb, state, do_chain);
+	ret = nf_nat_ipv6_fn(priv, skb, state, do_chain);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -414,9 +414,9 @@ nf_nat_ipv6_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
 EXPORT_SYMBOL_GPL(nf_nat_ipv6_out);
 
 unsigned int
-nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nf_nat_ipv6_local_fn(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state,
-		     unsigned int (*do_chain)(const struct nf_hook_ops *ops,
+		     unsigned int (*do_chain)(void *priv,
 					      struct sk_buff *skb,
 					      const struct nf_hook_state *state,
 					      struct nf_conn *ct))
@@ -430,7 +430,7 @@ nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv6_fn(ops, skb, state, do_chain);
+	ret = nf_nat_ipv6_fn(priv, skb, state, do_chain);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 41340b794f9b..120ea9131be0 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -16,7 +16,7 @@
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_ipv6.h>
 
-static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
+static unsigned int nft_do_chain_ipv6(void *priv,
 				      struct sk_buff *skb,
 				      const struct nf_hook_state *state)
 {
@@ -26,10 +26,10 @@ static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 	if (nft_set_pktinfo_ipv6(&pkt, skb, state) < 0)
 		return NF_DROP;
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
-static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
+static unsigned int nft_ipv6_output(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
@@ -40,7 +40,7 @@ static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 
-	return nft_do_chain_ipv6(ops, skb, state);
+	return nft_do_chain_ipv6(priv, skb, state);
 }
 
 struct nft_af_info nft_af_ipv6 __read_mostly = {
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index e96feaefeb14..443cd306c0b0 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -24,7 +24,7 @@
 #include <net/netfilter/nf_nat_l3proto.h>
 #include <net/ipv6.h>
 
-static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_do_chain(void *priv,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state,
 				     struct nf_conn *ct)
@@ -33,35 +33,35 @@ static unsigned int nft_nat_do_chain(const struct nf_hook_ops *ops,
 
 	nft_set_pktinfo_ipv6(&pkt, skb, state);
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
-static unsigned int nft_nat_ipv6_fn(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv6_fn(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_fn(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv6_fn(priv, skb, state, nft_nat_do_chain);
 }
 
-static unsigned int nft_nat_ipv6_in(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv6_in(void *priv,
 				    struct sk_buff *skb,
 				    const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_in(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv6_in(priv, skb, state, nft_nat_do_chain);
 }
 
-static unsigned int nft_nat_ipv6_out(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv6_out(void *priv,
 				     struct sk_buff *skb,
 				     const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_out(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv6_out(priv, skb, state, nft_nat_do_chain);
 }
 
-static unsigned int nft_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
+static unsigned int nft_nat_ipv6_local_fn(void *priv,
 					  struct sk_buff *skb,
 					  const struct nf_hook_state *state)
 {
-	return nf_nat_ipv6_local_fn(ops, skb, state, nft_nat_do_chain);
+	return nf_nat_ipv6_local_fn(priv, skb, state, nft_nat_do_chain);
 }
 
 static const struct nf_chain_type nft_chain_nat_ipv6 = {
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index d1bcd2ed7bcc..d42bbc1d7555 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -22,7 +22,7 @@
 #include <net/netfilter/nf_tables_ipv6.h>
 #include <net/route.h>
 
-static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
+static unsigned int nf_route_table_hook(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
@@ -45,7 +45,7 @@ static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u32 *)ipv6_hdr(skb));
 
-	ret = nft_do_chain(&pkt, ops);
+	ret = nft_do_chain(&pkt, priv);
 	if (ret != NF_DROP && ret != NF_QUEUE &&
 	    (memcmp(&ipv6_hdr(skb)->saddr, &saddr, sizeof(saddr)) ||
 	     memcmp(&ipv6_hdr(skb)->daddr, &daddr, sizeof(daddr)) ||
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 653e32eac08c..798f6308d7df 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -165,7 +165,7 @@ unsigned int nf_iterate(struct list_head *head,
 		/* Optimization: we don't need to hold module
 		   reference here, since function can't sleep. --RR */
 repeat:
-		verdict = (*elemp)->hook(*elemp, skb, state);
+		verdict = (*elemp)->hook((*elemp)->priv, skb, state);
 		if (verdict != NF_ACCEPT) {
 #ifdef CONFIG_NETFILTER_DEBUG
 			if (unlikely((verdict & NF_VERDICT_MASK)
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 8cc6b285d690..10633d1e602d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1271,7 +1271,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_reply4(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
 	return ip_vs_out(state->hook, skb, AF_INET);
@@ -1282,7 +1282,7 @@ ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_reply4(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	return ip_vs_out(state->hook, skb, AF_INET);
@@ -1296,7 +1296,7 @@ ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_reply6(void *priv, struct sk_buff *skb,
 	     const struct nf_hook_state *state)
 {
 	return ip_vs_out(state->hook, skb, AF_INET6);
@@ -1307,7 +1307,7 @@ ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_reply6(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	return ip_vs_out(state->hook, skb, AF_INET6);
@@ -1764,7 +1764,7 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
  *	Schedule and forward packets from remote clients
  */
 static unsigned int
-ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_remote_request4(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	return ip_vs_in(state->hook, skb, AF_INET);
@@ -1775,7 +1775,7 @@ ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Schedule and forward packets from local clients
  */
 static unsigned int
-ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_request4(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	return ip_vs_in(state->hook, skb, AF_INET);
@@ -1788,7 +1788,7 @@ ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Schedule and forward packets from remote clients
  */
 static unsigned int
-ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_remote_request6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	return ip_vs_in(state->hook, skb, AF_INET6);
@@ -1799,7 +1799,7 @@ ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Schedule and forward packets from local clients
  */
 static unsigned int
-ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_request6(void *priv, struct sk_buff *skb,
 		     const struct nf_hook_state *state)
 {
 	return ip_vs_in(state->hook, skb, AF_INET6);
@@ -1818,7 +1818,7 @@ ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *      and send them to ip_vs_in_icmp.
  */
 static unsigned int
-ip_vs_forward_icmp(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_forward_icmp(void *priv, struct sk_buff *skb,
 		   const struct nf_hook_state *state)
 {
 	int r;
@@ -1834,12 +1834,12 @@ ip_vs_forward_icmp(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp(skb, &r, ops->hooknum);
+	return ip_vs_in_icmp(skb, &r, state->hook);
 }
 
 #ifdef CONFIG_IP_VS_IPV6
 static unsigned int
-ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_forward_icmp_v6(void *priv, struct sk_buff *skb,
 		      const struct nf_hook_state *state)
 {
 	int r;
@@ -1857,7 +1857,7 @@ ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops, struct sk_buff *skb,
 	if (unlikely(sysctl_backup_only(ipvs) || !ipvs->enable))
 		return NF_ACCEPT;
 
-	return ip_vs_in_icmp_v6(skb, &r, ops->hooknum, &iphdr);
+	return ip_vs_in_icmp_v6(skb, &r, state->hook, &iphdr);
 }
 #endif
 
diff --git a/net/netfilter/nf_tables_core.c b/net/netfilter/nf_tables_core.c
index 46614d88a5e8..5f23b862f4bb 100644
--- a/net/netfilter/nf_tables_core.c
+++ b/net/netfilter/nf_tables_core.c
@@ -109,9 +109,9 @@ struct nft_jumpstack {
 };
 
 unsigned int
-nft_do_chain(struct nft_pktinfo *pkt, const struct nf_hook_ops *ops)
+nft_do_chain(struct nft_pktinfo *pkt, void *priv)
 {
-	const struct nft_chain *chain = ops->priv, *basechain = chain;
+	const struct nft_chain *chain = priv, *basechain = chain;
 	const struct net *net = read_pnet(&nft_base_chain(basechain)->pnet);
 	const struct nft_rule *rule;
 	const struct nft_expr *expr, *last;
diff --git a/net/netfilter/nf_tables_netdev.c b/net/netfilter/nf_tables_netdev.c
index db416a3396e9..7b9c053ba750 100644
--- a/net/netfilter/nf_tables_netdev.c
+++ b/net/netfilter/nf_tables_netdev.c
@@ -89,7 +89,7 @@ static inline void nft_netdev_set_pktinfo_ipv6(struct nft_pktinfo *pkt,
 }
 
 static unsigned int
-nft_do_chain_netdev(const struct nf_hook_ops *ops, struct sk_buff *skb,
+nft_do_chain_netdev(void *priv, struct sk_buff *skb,
 		    const struct nf_hook_state *state)
 {
 	struct nft_pktinfo pkt;
@@ -106,7 +106,7 @@ nft_do_chain_netdev(const struct nf_hook_ops *ops, struct sk_buff *skb,
 		break;
 	}
 
-	return nft_do_chain(&pkt, ops);
+	return nft_do_chain(&pkt, priv);
 }
 
 static struct nft_af_info nft_af_netdev __read_mostly = {
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 7dade28affba..5dbfc32601fb 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4844,7 +4844,7 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static unsigned int selinux_ipv4_forward(const struct nf_hook_ops *ops,
+static unsigned int selinux_ipv4_forward(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state)
 {
@@ -4852,7 +4852,7 @@ static unsigned int selinux_ipv4_forward(const struct nf_hook_ops *ops,
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static unsigned int selinux_ipv6_forward(const struct nf_hook_ops *ops,
+static unsigned int selinux_ipv6_forward(void *priv,
 					 struct sk_buff *skb,
 					 const struct nf_hook_state *state)
 {
@@ -4902,7 +4902,7 @@ static unsigned int selinux_ip_output(struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static unsigned int selinux_ipv4_output(const struct nf_hook_ops *ops,
+static unsigned int selinux_ipv4_output(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
@@ -5077,7 +5077,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static unsigned int selinux_ipv4_postroute(const struct nf_hook_ops *ops,
+static unsigned int selinux_ipv4_postroute(void *priv,
 					   struct sk_buff *skb,
 					   const struct nf_hook_state *state)
 {
@@ -5085,7 +5085,7 @@ static unsigned int selinux_ipv4_postroute(const struct nf_hook_ops *ops,
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static unsigned int selinux_ipv6_postroute(const struct nf_hook_ops *ops,
+static unsigned int selinux_ipv6_postroute(void *priv,
 					   struct sk_buff *skb,
 					   const struct nf_hook_state *state)
 {
diff --git a/security/smack/smack_netfilter.c b/security/smack/smack_netfilter.c
index a455cfc9ec1f..a9e41da05d28 100644
--- a/security/smack/smack_netfilter.c
+++ b/security/smack/smack_netfilter.c
@@ -21,7 +21,7 @@
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 
-static unsigned int smack_ipv6_output(const struct nf_hook_ops *ops,
+static unsigned int smack_ipv6_output(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
@@ -38,7 +38,7 @@ static unsigned int smack_ipv6_output(const struct nf_hook_ops *ops,
 }
 #endif	/* IPV6 */
 
-static unsigned int smack_ipv4_output(const struct nf_hook_ops *ops,
+static unsigned int smack_ipv4_output(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
-- 
2.2.1
