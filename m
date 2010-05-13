From: kaber@trash.net
Subject: [PATCH 06/12] netfilter: xtables: deconstify struct xt_action_param for matches
Date: Thu, 13 May 2010 18:16:19 +0200
Message-ID: <1273767385-18225-7-git-send-email-kaber@trash.net>
References: <1273767385-18225-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273767385-18225-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

In future, layer-3 matches will be an xt module of their own, and
need to set the fragoff and thoff fields. Adding more pointers would
needlessy increase memory requirements (esp. so for 64-bit, where
pointers are wider).

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/x_tables.h   |    2 +-
 net/bridge/netfilter/ebt_802_3.c     |    2 +-
 net/bridge/netfilter/ebt_among.c     |    2 +-
 net/bridge/netfilter/ebt_arp.c       |    2 +-
 net/bridge/netfilter/ebt_ip.c        |    2 +-
 net/bridge/netfilter/ebt_ip6.c       |    2 +-
 net/bridge/netfilter/ebt_limit.c     |    2 +-
 net/bridge/netfilter/ebt_mark_m.c    |    2 +-
 net/bridge/netfilter/ebt_pkttype.c   |    2 +-
 net/bridge/netfilter/ebt_stp.c       |    2 +-
 net/bridge/netfilter/ebt_vlan.c      |    2 +-
 net/ipv4/netfilter/ip_tables.c       |    2 +-
 net/ipv4/netfilter/ipt_addrtype.c    |    4 ++--
 net/ipv4/netfilter/ipt_ah.c          |    2 +-
 net/ipv4/netfilter/ipt_ecn.c         |    3 +--
 net/ipv6/netfilter/ip6_tables.c      |    2 +-
 net/ipv6/netfilter/ip6t_ah.c         |    3 +--
 net/ipv6/netfilter/ip6t_eui64.c      |    2 +-
 net/ipv6/netfilter/ip6t_frag.c       |    2 +-
 net/ipv6/netfilter/ip6t_hbh.c        |    2 +-
 net/ipv6/netfilter/ip6t_ipv6header.c |    2 +-
 net/ipv6/netfilter/ip6t_mh.c         |    3 +--
 net/ipv6/netfilter/ip6t_rt.c         |    3 +--
 net/netfilter/xt_cluster.c           |    2 +-
 net/netfilter/xt_comment.c           |    2 +-
 net/netfilter/xt_connbytes.c         |    2 +-
 net/netfilter/xt_connlimit.c         |    2 +-
 net/netfilter/xt_connmark.c          |    2 +-
 net/netfilter/xt_conntrack.c         |    6 +++---
 net/netfilter/xt_dccp.c              |    2 +-
 net/netfilter/xt_dscp.c              |    7 +++----
 net/netfilter/xt_esp.c               |    3 +--
 net/netfilter/xt_hashlimit.c         |    2 +-
 net/netfilter/xt_helper.c            |    2 +-
 net/netfilter/xt_hl.c                |    6 ++----
 net/netfilter/xt_iprange.c           |    4 ++--
 net/netfilter/xt_length.c            |    4 ++--
 net/netfilter/xt_limit.c             |    2 +-
 net/netfilter/xt_mac.c               |    3 +--
 net/netfilter/xt_mark.c              |    2 +-
 net/netfilter/xt_multiport.c         |    2 +-
 net/netfilter/xt_osf.c               |    2 +-
 net/netfilter/xt_owner.c             |    2 +-
 net/netfilter/xt_physdev.c           |    2 +-
 net/netfilter/xt_pkttype.c           |    2 +-
 net/netfilter/xt_policy.c            |    2 +-
 net/netfilter/xt_quota.c             |    2 +-
 net/netfilter/xt_rateest.c           |    2 +-
 net/netfilter/xt_realm.c             |    2 +-
 net/netfilter/xt_recent.c            |    2 +-
 net/netfilter/xt_sctp.c              |    2 +-
 net/netfilter/xt_socket.c            |    6 +++---
 net/netfilter/xt_state.c             |    2 +-
 net/netfilter/xt_statistic.c         |    2 +-
 net/netfilter/xt_string.c            |    2 +-
 net/netfilter/xt_tcpmss.c            |    2 +-
 net/netfilter/xt_tcpudp.c            |    6 ++----
 net/netfilter/xt_time.c              |    2 +-
 net/netfilter/xt_u32.c               |    3 +--
 59 files changed, 70 insertions(+), 82 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 6d1f9a6..40c6a8d 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -288,7 +288,7 @@ struct xt_match {
 	   non-linear skb, using skb_header_pointer and
 	   skb_ip_make_writable. */
 	bool (*match)(const struct sk_buff *skb,
-		      const struct xt_action_param *);
+		      struct xt_action_param *);
 
 	/* Called when user tries to insert an entry of this type. */
 	int (*checkentry)(const struct xt_mtchk_param *);
diff --git a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
index 4b0df00..2a449b7 100644
--- a/net/bridge/netfilter/ebt_802_3.c
+++ b/net/bridge/netfilter/ebt_802_3.c
@@ -13,7 +13,7 @@
 #include <linux/netfilter_bridge/ebt_802_3.h>
 
 static bool
-ebt_802_3_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_802_3_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_802_3_info *info = par->matchinfo;
 	const struct ebt_802_3_hdr *hdr = ebt_802_3_hdr(skb);
diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index c04f946..8b84c58 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -129,7 +129,7 @@ static int get_ip_src(const struct sk_buff *skb, __be32 *addr)
 }
 
 static bool
-ebt_among_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_among_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_among_info *info = par->matchinfo;
 	const char *dmac, *smac;
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index 6203f4d..cd457b8 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -16,7 +16,7 @@
 #include <linux/netfilter_bridge/ebt_arp.h>
 
 static bool
-ebt_arp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_arp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_arp_info *info = par->matchinfo;
 	const struct arphdr *ah;
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index a0cde74..23bca62 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -25,7 +25,7 @@ struct tcpudphdr {
 };
 
 static bool
-ebt_ip_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_ip_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_ip_info *info = par->matchinfo;
 	const struct iphdr *ih;
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index c451dc2..50a46af 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -28,7 +28,7 @@ struct tcpudphdr {
 };
 
 static bool
-ebt_ip6_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_ip6_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_ip6_info *info = par->matchinfo;
 	const struct ipv6hdr *ih6;
diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index 760923f..517e78b 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -32,7 +32,7 @@ static DEFINE_SPINLOCK(limit_lock);
 #define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
 
 static bool
-ebt_limit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_limit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ebt_limit_info *info = (void *)par->matchinfo;
 	unsigned long now = jiffies;
diff --git a/net/bridge/netfilter/ebt_mark_m.c b/net/bridge/netfilter/ebt_mark_m.c
index de90163..d98baef 100644
--- a/net/bridge/netfilter/ebt_mark_m.c
+++ b/net/bridge/netfilter/ebt_mark_m.c
@@ -13,7 +13,7 @@
 #include <linux/netfilter_bridge/ebt_mark_m.h>
 
 static bool
-ebt_mark_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_mark_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_mark_m_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_pkttype.c b/net/bridge/netfilter/ebt_pkttype.c
index 7ba67c4..496a565 100644
--- a/net/bridge/netfilter/ebt_pkttype.c
+++ b/net/bridge/netfilter/ebt_pkttype.c
@@ -13,7 +13,7 @@
 #include <linux/netfilter_bridge/ebt_pkttype.h>
 
 static bool
-ebt_pkttype_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_pkttype_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_pkttype_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 3cd6070..5b33a2e 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -120,7 +120,7 @@ static bool ebt_filter_config(const struct ebt_stp_info *info,
 }
 
 static bool
-ebt_stp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_stp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_stp_info *info = par->matchinfo;
 	const struct stp_header *sp;
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index e4ab625..87b53b3 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -36,7 +36,7 @@ MODULE_LICENSE("GPL");
 #define EXIT_ON_MISMATCH(_MATCH_,_MASK_) {if (!((info->_MATCH_ == _MATCH_)^!!(info->invflags & _MASK_))) return false; }
 
 static bool
-ebt_vlan_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+ebt_vlan_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ebt_vlan_info *info = par->matchinfo;
 	const struct vlan_hdr *fp;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3ab1b81..4e674f2 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2138,7 +2138,7 @@ icmp_type_code_match(u_int8_t test_type, u_int8_t min_code, u_int8_t max_code,
 }
 
 static bool
-icmp_match(const struct sk_buff *skb, const struct xt_action_param *par)
+icmp_match(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct icmphdr *ic;
 	struct icmphdr _icmph;
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
index 24ec548..db8bff0 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -30,7 +30,7 @@ static inline bool match_type(struct net *net, const struct net_device *dev,
 }
 
 static bool
-addrtype_mt_v0(const struct sk_buff *skb, const struct xt_action_param *par)
+addrtype_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct ipt_addrtype_info *info = par->matchinfo;
@@ -48,7 +48,7 @@ addrtype_mt_v0(const struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 static bool
-addrtype_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
+addrtype_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct ipt_addrtype_info_v1 *info = par->matchinfo;
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 48a8293..c9d83dc 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -30,7 +30,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	return r;
 }
 
-static bool ah_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+static bool ah_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ip_auth_hdr _ahdr;
 	const struct ip_auth_hdr *ah;
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index 744d13e..b79dddc 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -67,8 +67,7 @@ static inline bool match_tcp(const struct sk_buff *skb,
 	return true;
 }
 
-static bool ecn_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool ecn_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ipt_ecn_info *info = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index c3bc999..4549f8d 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2154,7 +2154,7 @@ icmp6_type_code_match(u_int8_t test_type, u_int8_t min_code, u_int8_t max_code,
 }
 
 static bool
-icmp6_match(const struct sk_buff *skb, const struct xt_action_param *par)
+icmp6_match(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct icmp6hdr *ic;
 	struct icmp6hdr _icmph;
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 4fe7189..c89887f 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -36,8 +36,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	return r;
 }
 
-static bool ah_mt6(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool ah_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ip_auth_hdr _ah;
 	const struct ip_auth_hdr *ah;
diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index 2fd2be1..f32fce3 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -20,7 +20,7 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Andras Kis-Szabo <kisza@sch.bme.hu>");
 
 static bool
-eui64_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+eui64_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	unsigned char eui64[8];
 
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index 8401aa8..fcc8c72 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -35,7 +35,7 @@ id_match(u_int32_t min, u_int32_t max, u_int32_t id, bool invert)
 }
 
 static bool
-frag_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+frag_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct frag_hdr _frag;
 	const struct frag_hdr *fh;
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index d19d5cf..f8aebc0 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -44,7 +44,7 @@ MODULE_ALIAS("ip6t_dst");
 static struct xt_match hbh_mt6_reg[] __read_mostly;
 
 static bool
-hbh_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ipv6_opt_hdr _optsh;
 	const struct ipv6_opt_hdr *oh;
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 8e88bb8..54bd979 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -27,7 +27,7 @@ MODULE_DESCRIPTION("Xtables: IPv6 header types match");
 MODULE_AUTHOR("Andras Kis-Szabo <kisza@sch.bme.hu>");
 
 static bool
-ipv6header_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+ipv6header_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ip6t_ipv6header_info *info = par->matchinfo;
 	unsigned int temp;
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index 4a60788..eb1c3d6 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -32,8 +32,7 @@ type_match(u_int8_t min, u_int8_t max, u_int8_t type, bool invert)
 	return (type >= min && type <= max) ^ invert;
 }
 
-static bool mh_mt6(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool mh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ip6_mh _mh;
 	const struct ip6_mh *mh;
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index 793c272..ee58469 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -36,8 +36,7 @@ segsleft_match(u_int32_t min, u_int32_t max, u_int32_t id, bool invert)
 	return r;
 }
 
-static bool rt_mt6(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct ipv6_rt_hdr _route;
 	const struct ipv6_rt_hdr *rh;
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 67fc317..30b95a1 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -86,7 +86,7 @@ xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
 }
 
 static bool
-xt_cluster_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+xt_cluster_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct sk_buff *pskb = (struct sk_buff *)skb;
 	const struct xt_cluster_match_info *info = par->matchinfo;
diff --git a/net/netfilter/xt_comment.c b/net/netfilter/xt_comment.c
index 1dbb3e1..5c861d2 100644
--- a/net/netfilter/xt_comment.c
+++ b/net/netfilter/xt_comment.c
@@ -16,7 +16,7 @@ MODULE_ALIAS("ipt_comment");
 MODULE_ALIAS("ip6t_comment");
 
 static bool
-comment_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+comment_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	/* We always match */
 	return true;
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index 5e5cf15..7351783 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -18,7 +18,7 @@ MODULE_ALIAS("ipt_connbytes");
 MODULE_ALIAS("ip6t_connbytes");
 
 static bool
-connbytes_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+connbytes_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_connbytes_info *sinfo = par->matchinfo;
 	const struct nf_conn *ct;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6eec191..f130fd9 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -173,7 +173,7 @@ static int count_them(struct net *net,
 }
 
 static bool
-connlimit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct xt_connlimit_info *info = par->matchinfo;
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index b43cfc7..7278145 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -91,7 +91,7 @@ static void connmark_tg_destroy(const struct xt_tgdtor_param *par)
 }
 
 static bool
-connmark_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+connmark_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_connmark_mtinfo1 *info = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 14a96f4..39681f1 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -113,7 +113,7 @@ ct_proto_port_check(const struct xt_conntrack_mtinfo2 *info,
 }
 
 static bool
-conntrack_mt(const struct sk_buff *skb, const struct xt_action_param *par,
+conntrack_mt(const struct sk_buff *skb, struct xt_action_param *par,
              u16 state_mask, u16 status_mask)
 {
 	const struct xt_conntrack_mtinfo2 *info = par->matchinfo;
@@ -191,7 +191,7 @@ conntrack_mt(const struct sk_buff *skb, const struct xt_action_param *par,
 }
 
 static bool
-conntrack_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
+conntrack_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_conntrack_mtinfo1 *info = par->matchinfo;
 
@@ -199,7 +199,7 @@ conntrack_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 static bool
-conntrack_mt_v2(const struct sk_buff *skb, const struct xt_action_param *par)
+conntrack_mt_v2(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_conntrack_mtinfo2 *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index 7a4d4e8..cc2c291 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -96,7 +96,7 @@ match_option(u_int8_t option, const struct sk_buff *skb, unsigned int protoff,
 }
 
 static bool
-dccp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+dccp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_dccp_info *info = par->matchinfo;
 	const struct dccp_hdr *dh;
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 2133b50..64670fc 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -25,7 +25,7 @@ MODULE_ALIAS("ipt_tos");
 MODULE_ALIAS("ip6t_tos");
 
 static bool
-dscp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+dscp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_dscp_info *info = par->matchinfo;
 	u_int8_t dscp = ipv4_get_dsfield(ip_hdr(skb)) >> XT_DSCP_SHIFT;
@@ -34,7 +34,7 @@ dscp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 static bool
-dscp_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+dscp_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_dscp_info *info = par->matchinfo;
 	u_int8_t dscp = ipv6_get_dsfield(ipv6_hdr(skb)) >> XT_DSCP_SHIFT;
@@ -54,8 +54,7 @@ static int dscp_mt_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
-static bool tos_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool tos_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_tos_match_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index 39caaff..7c2d800 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -36,8 +36,7 @@ spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 	return r;
 }
 
-static bool esp_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool esp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ip_esp_hdr *eh;
 	struct ip_esp_hdr _esp;
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 700c21e..25a6e54 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -516,7 +516,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 }
 
 static bool
-hashlimit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index e941bd2..9f4ab00 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -24,7 +24,7 @@ MODULE_ALIAS("ip6t_helper");
 
 
 static bool
-helper_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+helper_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_helper_info *info = par->matchinfo;
 	const struct nf_conn *ct;
diff --git a/net/netfilter/xt_hl.c b/net/netfilter/xt_hl.c
index 335c34a..7d12221 100644
--- a/net/netfilter/xt_hl.c
+++ b/net/netfilter/xt_hl.c
@@ -25,8 +25,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_ttl");
 MODULE_ALIAS("ip6t_hl");
 
-static bool ttl_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool ttl_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ipt_ttl_info *info = par->matchinfo;
 	const u8 ttl = ip_hdr(skb)->ttl;
@@ -45,8 +44,7 @@ static bool ttl_mt(const struct sk_buff *skb,
 	return false;
 }
 
-static bool hl_mt6(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool hl_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct ip6t_hl_info *info = par->matchinfo;
 	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
diff --git a/net/netfilter/xt_iprange.c b/net/netfilter/xt_iprange.c
index 9578860..88f7c35 100644
--- a/net/netfilter/xt_iprange.c
+++ b/net/netfilter/xt_iprange.c
@@ -17,7 +17,7 @@
 #include <linux/netfilter/xt_iprange.h>
 
 static bool
-iprange_mt4(const struct sk_buff *skb, const struct xt_action_param *par)
+iprange_mt4(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_iprange_mtinfo *info = par->matchinfo;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -68,7 +68,7 @@ iprange_ipv6_sub(const struct in6_addr *a, const struct in6_addr *b)
 }
 
 static bool
-iprange_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+iprange_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_iprange_mtinfo *info = par->matchinfo;
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
diff --git a/net/netfilter/xt_length.c b/net/netfilter/xt_length.c
index 842149b..176e557 100644
--- a/net/netfilter/xt_length.c
+++ b/net/netfilter/xt_length.c
@@ -21,7 +21,7 @@ MODULE_ALIAS("ipt_length");
 MODULE_ALIAS("ip6t_length");
 
 static bool
-length_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+length_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_length_info *info = par->matchinfo;
 	u_int16_t pktlen = ntohs(ip_hdr(skb)->tot_len);
@@ -30,7 +30,7 @@ length_mt(const struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 static bool
-length_mt6(const struct sk_buff *skb, const struct xt_action_param *par)
+length_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_length_info *info = par->matchinfo;
 	const u_int16_t pktlen = ntohs(ipv6_hdr(skb)->payload_len) +
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index 7dcfe86..32b7a57 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -65,7 +65,7 @@ static DEFINE_SPINLOCK(limit_lock);
 #define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
 
 static bool
-limit_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+limit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_rateinfo *r = par->matchinfo;
 	struct xt_limit_priv *priv = r->master;
diff --git a/net/netfilter/xt_mac.c b/net/netfilter/xt_mac.c
index 36c4964..8160f6b 100644
--- a/net/netfilter/xt_mac.c
+++ b/net/netfilter/xt_mac.c
@@ -25,8 +25,7 @@ MODULE_DESCRIPTION("Xtables: MAC address match");
 MODULE_ALIAS("ipt_mac");
 MODULE_ALIAS("ip6t_mac");
 
-static bool mac_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool mac_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_mac_info *info = par->matchinfo;
 	bool ret;
diff --git a/net/netfilter/xt_mark.c b/net/netfilter/xt_mark.c
index 3c83470..2334523 100644
--- a/net/netfilter/xt_mark.c
+++ b/net/netfilter/xt_mark.c
@@ -34,7 +34,7 @@ mark_tg(struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 static bool
-mark_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+mark_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_mark_mtinfo1 *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index 3140fd4..52beb68 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -72,7 +72,7 @@ ports_match_v1(const struct xt_multiport_v1 *minfo,
 }
 
 static bool
-multiport_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+multiport_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const __be16 *pptr;
 	__be16 _ports[2];
diff --git a/net/netfilter/xt_osf.c b/net/netfilter/xt_osf.c
index 37aa558..4327e10 100644
--- a/net/netfilter/xt_osf.c
+++ b/net/netfilter/xt_osf.c
@@ -194,7 +194,7 @@ static inline int xt_osf_ttl(const struct sk_buff *skb, const struct xt_osf_info
 }
 
 static bool
-xt_osf_match_packet(const struct sk_buff *skb, const struct xt_action_param *p)
+xt_osf_match_packet(const struct sk_buff *skb, struct xt_action_param *p)
 {
 	const struct xt_osf_info *info = p->matchinfo;
 	const struct iphdr *ip = ip_hdr(skb);
diff --git a/net/netfilter/xt_owner.c b/net/netfilter/xt_owner.c
index 3dd1391..772d738 100644
--- a/net/netfilter/xt_owner.c
+++ b/net/netfilter/xt_owner.c
@@ -18,7 +18,7 @@
 #include <linux/netfilter/xt_owner.h>
 
 static bool
-owner_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_owner_match_info *info = par->matchinfo;
 	const struct file *filp;
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 298cd29..d7ca16b 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -22,7 +22,7 @@ MODULE_ALIAS("ip6t_physdev");
 
 
 static bool
-physdev_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+physdev_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	static const char nulldevname[IFNAMSIZ] __attribute__((aligned(sizeof(long))));
 	const struct xt_physdev_info *info = par->matchinfo;
diff --git a/net/netfilter/xt_pkttype.c b/net/netfilter/xt_pkttype.c
index d95f214..5b645cb 100644
--- a/net/netfilter/xt_pkttype.c
+++ b/net/netfilter/xt_pkttype.c
@@ -23,7 +23,7 @@ MODULE_ALIAS("ipt_pkttype");
 MODULE_ALIAS("ip6t_pkttype");
 
 static bool
-pkttype_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+pkttype_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_pkttype_info *info = par->matchinfo;
 	u_int8_t type;
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 1abfc7a..f23e97b 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -110,7 +110,7 @@ match_policy_out(const struct sk_buff *skb, const struct xt_policy_info *info,
 }
 
 static bool
-policy_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+policy_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_policy_info *info = par->matchinfo;
 	int ret;
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index e79e07c..b4f7dfe 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -23,7 +23,7 @@ MODULE_ALIAS("ip6t_quota");
 static DEFINE_SPINLOCK(quota_lock);
 
 static bool
-quota_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+quota_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct xt_quota_info *q = (void *)par->matchinfo;
 	struct xt_quota_priv *priv = q->master;
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 53f7a4d..76a0831 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -15,7 +15,7 @@
 
 
 static bool
-xt_rateest_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+xt_rateest_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_rateest_match_info *info = par->matchinfo;
 	struct gnet_stats_rate_est *r;
diff --git a/net/netfilter/xt_realm.c b/net/netfilter/xt_realm.c
index b063c78..459a7b2 100644
--- a/net/netfilter/xt_realm.c
+++ b/net/netfilter/xt_realm.c
@@ -22,7 +22,7 @@ MODULE_DESCRIPTION("Xtables: Routing realm match");
 MODULE_ALIAS("ipt_realm");
 
 static bool
-realm_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+realm_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_realm_info *info = par->matchinfo;
 	const struct dst_entry *dst = skb_dst(skb);
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 503b7f1..2808a7e 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -224,7 +224,7 @@ static void recent_table_flush(struct recent_table *t)
 }
 
 static bool
-recent_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+recent_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	struct net *net = dev_net(par->in ? par->in : par->out);
 	struct recent_net *recent_net = recent_pernet(net);
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index da4c3cb..94d8b5d 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -114,7 +114,7 @@ match_packet(const struct sk_buff *skb,
 }
 
 static bool
-sctp_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+sctp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_sctp_info *info = par->matchinfo;
 	const sctp_sctphdr_t *sh;
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 2665e32..3d54c23 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -88,7 +88,7 @@ extract_icmp_fields(const struct sk_buff *skb,
 
 
 static bool
-socket_match(const struct sk_buff *skb, const struct xt_action_param *par,
+socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	     const struct xt_socket_mtinfo1 *info)
 {
 	const struct iphdr *iph = ip_hdr(skb);
@@ -174,13 +174,13 @@ socket_match(const struct sk_buff *skb, const struct xt_action_param *par,
 }
 
 static bool
-socket_mt_v0(const struct sk_buff *skb, const struct xt_action_param *par)
+socket_mt_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	return socket_match(skb, par, NULL);
 }
 
 static bool
-socket_mt_v1(const struct sk_buff *skb, const struct xt_action_param *par)
+socket_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	return socket_match(skb, par, par->matchinfo);
 }
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 344cca6..e12e053 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -21,7 +21,7 @@ MODULE_ALIAS("ipt_state");
 MODULE_ALIAS("ip6t_state");
 
 static bool
-state_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+state_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_state_info *sinfo = par->matchinfo;
 	enum ip_conntrack_info ctinfo;
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index ee4540a..96e62b8 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -30,7 +30,7 @@ MODULE_ALIAS("ip6t_statistic");
 static DEFINE_SPINLOCK(nth_lock);
 
 static bool
-statistic_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+statistic_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_statistic_info *info = par->matchinfo;
 	bool ret = info->flags & XT_STATISTIC_INVERT;
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index fd5dc50..d3c48b1 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -23,7 +23,7 @@ MODULE_ALIAS("ipt_string");
 MODULE_ALIAS("ip6t_string");
 
 static bool
-string_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+string_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_string_info *conf = par->matchinfo;
 	struct ts_state state;
diff --git a/net/netfilter/xt_tcpmss.c b/net/netfilter/xt_tcpmss.c
index 5c8a7b4..f90728f 100644
--- a/net/netfilter/xt_tcpmss.c
+++ b/net/netfilter/xt_tcpmss.c
@@ -25,7 +25,7 @@ MODULE_ALIAS("ipt_tcpmss");
 MODULE_ALIAS("ip6t_tcpmss");
 
 static bool
-tcpmss_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+tcpmss_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_tcpmss_match_info *info = par->matchinfo;
 	const struct tcphdr *th;
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index 19c31d4..dedde33 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -62,8 +62,7 @@ tcp_find_option(u_int8_t option,
 	return invert;
 }
 
-static bool tcp_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool tcp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct tcphdr *th;
 	struct tcphdr _tcph;
@@ -129,8 +128,7 @@ static int tcp_mt_check(const struct xt_mtchk_param *par)
 	return (tcpinfo->invflags & ~XT_TCP_INV_MASK) ? -EINVAL : 0;
 }
 
-static bool udp_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool udp_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct udphdr *uh;
 	struct udphdr _udph;
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index ffdb8fa..79234bb 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -152,7 +152,7 @@ static void localtime_3(struct xtm *r, time_t time)
 }
 
 static bool
-time_mt(const struct sk_buff *skb, const struct xt_action_param *par)
+time_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_time_info *info = par->matchinfo;
 	unsigned int packet_time;
diff --git a/net/netfilter/xt_u32.c b/net/netfilter/xt_u32.c
index f62797b..a95b503 100644
--- a/net/netfilter/xt_u32.c
+++ b/net/netfilter/xt_u32.c
@@ -86,8 +86,7 @@ static bool u32_match_it(const struct xt_u32 *data,
 	return true;
 }
 
-static bool u32_mt(const struct sk_buff *skb,
-		   const struct xt_action_param *par)
+static bool u32_mt(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_u32 *data = par->matchinfo;
 	bool ret;
-- 
1.7.0.4

