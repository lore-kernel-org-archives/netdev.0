From: kaber@trash.net
Subject: [PATCH 42/84] netfilter: xtables: change xt_match.checkentry return type
Date: Mon, 10 May 2010 22:18:13 +0200
Message-ID: <1273522735-24672-43-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835Ab0EJUTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:13 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Restore function signatures from bool to int so that we can report
memory allocation failures or similar using -ENOMEM rather than
always having to pass -EINVAL back.

This semantic patch may not be too precise (checking for functions
that use xt_mtchk_param rather than functions referenced by
xt_match.checkentry), but reviewed, it produced the intended result.

// <smpl>
@@
type bool;
identifier check, par;
@@
-bool check
+int check
 (struct xt_mtchk_param *par) { ... }
// </smpl>

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
 net/ipv4/netfilter/ipt_addrtype.c    |    2 +-
 net/ipv4/netfilter/ipt_ah.c          |    2 +-
 net/ipv4/netfilter/ipt_ecn.c         |    2 +-
 net/ipv6/netfilter/ip6_tables.c      |    2 +-
 net/ipv6/netfilter/ip6t_ah.c         |    2 +-
 net/ipv6/netfilter/ip6t_frag.c       |    2 +-
 net/ipv6/netfilter/ip6t_hbh.c        |    2 +-
 net/ipv6/netfilter/ip6t_ipv6header.c |    2 +-
 net/ipv6/netfilter/ip6t_mh.c         |    2 +-
 net/ipv6/netfilter/ip6t_rt.c         |    2 +-
 net/netfilter/xt_cluster.c           |    2 +-
 net/netfilter/xt_connbytes.c         |    2 +-
 net/netfilter/xt_connlimit.c         |    2 +-
 net/netfilter/xt_connmark.c          |    2 +-
 net/netfilter/xt_conntrack.c         |    2 +-
 net/netfilter/xt_dccp.c              |    2 +-
 net/netfilter/xt_dscp.c              |    2 +-
 net/netfilter/xt_esp.c               |    2 +-
 net/netfilter/xt_hashlimit.c         |    4 ++--
 net/netfilter/xt_helper.c            |    2 +-
 net/netfilter/xt_limit.c             |    2 +-
 net/netfilter/xt_multiport.c         |    8 ++++----
 net/netfilter/xt_physdev.c           |    2 +-
 net/netfilter/xt_policy.c            |    2 +-
 net/netfilter/xt_quota.c             |    2 +-
 net/netfilter/xt_rateest.c           |    2 +-
 net/netfilter/xt_recent.c            |    2 +-
 net/netfilter/xt_sctp.c              |    2 +-
 net/netfilter/xt_state.c             |    2 +-
 net/netfilter/xt_statistic.c         |    2 +-
 net/netfilter/xt_string.c            |    2 +-
 net/netfilter/xt_tcpudp.c            |    4 ++--
 net/netfilter/xt_time.c              |    2 +-
 45 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index dd9d15a..33c1a62 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -303,7 +303,7 @@ struct xt_match {
 		      const struct xt_match_param *);
 
 	/* Called when user tries to insert an entry of this type. */
-	bool (*checkentry)(const struct xt_mtchk_param *);
+	int (*checkentry)(const struct xt_mtchk_param *);
 
 	/* Called when entry of this type deleted. */
 	void (*destroy)(const struct xt_mtdtor_param *);
diff --git a/net/bridge/netfilter/ebt_802_3.c b/net/bridge/netfilter/ebt_802_3.c
index 5d11767..7b6f4c4 100644
--- a/net/bridge/netfilter/ebt_802_3.c
+++ b/net/bridge/netfilter/ebt_802_3.c
@@ -36,7 +36,7 @@ ebt_802_3_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_802_3_mt_check(const struct xt_mtchk_param *par)
+static int ebt_802_3_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_802_3_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_among.c b/net/bridge/netfilter/ebt_among.c
index 60ad630..8a75d39 100644
--- a/net/bridge/netfilter/ebt_among.c
+++ b/net/bridge/netfilter/ebt_among.c
@@ -172,7 +172,7 @@ ebt_among_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_among_mt_check(const struct xt_mtchk_param *par)
+static int ebt_among_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_among_info *info = par->matchinfo;
 	const struct ebt_entry_match *em =
diff --git a/net/bridge/netfilter/ebt_arp.c b/net/bridge/netfilter/ebt_arp.c
index e727697..fc62055 100644
--- a/net/bridge/netfilter/ebt_arp.c
+++ b/net/bridge/netfilter/ebt_arp.c
@@ -100,7 +100,7 @@ ebt_arp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_arp_mt_check(const struct xt_mtchk_param *par)
+static int ebt_arp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_arp_info *info = par->matchinfo;
 	const struct ebt_entry *e = par->entryinfo;
diff --git a/net/bridge/netfilter/ebt_ip.c b/net/bridge/netfilter/ebt_ip.c
index 5de6df6..d1a555d 100644
--- a/net/bridge/netfilter/ebt_ip.c
+++ b/net/bridge/netfilter/ebt_ip.c
@@ -77,7 +77,7 @@ ebt_ip_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_ip_mt_check(const struct xt_mtchk_param *par)
+static int ebt_ip_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_ip_info *info = par->matchinfo;
 	const struct ebt_entry *e = par->entryinfo;
diff --git a/net/bridge/netfilter/ebt_ip6.c b/net/bridge/netfilter/ebt_ip6.c
index 63e3888..fa4ecf5 100644
--- a/net/bridge/netfilter/ebt_ip6.c
+++ b/net/bridge/netfilter/ebt_ip6.c
@@ -80,7 +80,7 @@ ebt_ip6_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_ip6_mt_check(const struct xt_mtchk_param *par)
+static int ebt_ip6_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_entry *e = par->entryinfo;
 	struct ebt_ip6_info *info = par->matchinfo;
diff --git a/net/bridge/netfilter/ebt_limit.c b/net/bridge/netfilter/ebt_limit.c
index 5b7330b..abfb0ec 100644
--- a/net/bridge/netfilter/ebt_limit.c
+++ b/net/bridge/netfilter/ebt_limit.c
@@ -65,7 +65,7 @@ user2credits(u_int32_t user)
 	return (user * HZ * CREDITS_PER_JIFFY) / EBT_LIMIT_SCALE;
 }
 
-static bool ebt_limit_mt_check(const struct xt_mtchk_param *par)
+static int ebt_limit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct ebt_limit_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_mark_m.c b/net/bridge/netfilter/ebt_mark_m.c
index 8de8c39..1e5b0b3 100644
--- a/net/bridge/netfilter/ebt_mark_m.c
+++ b/net/bridge/netfilter/ebt_mark_m.c
@@ -22,7 +22,7 @@ ebt_mark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ((skb->mark & info->mask) == info->mark) ^ info->invert;
 }
 
-static bool ebt_mark_mt_check(const struct xt_mtchk_param *par)
+static int ebt_mark_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_mark_m_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_pkttype.c b/net/bridge/netfilter/ebt_pkttype.c
index e2a07e6..9b3c645 100644
--- a/net/bridge/netfilter/ebt_pkttype.c
+++ b/net/bridge/netfilter/ebt_pkttype.c
@@ -20,7 +20,7 @@ ebt_pkttype_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return (skb->pkt_type == info->pkt_type) ^ info->invert;
 }
 
-static bool ebt_pkttype_mt_check(const struct xt_mtchk_param *par)
+static int ebt_pkttype_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_pkttype_info *info = par->matchinfo;
 
diff --git a/net/bridge/netfilter/ebt_stp.c b/net/bridge/netfilter/ebt_stp.c
index 92a93d3..521186f 100644
--- a/net/bridge/netfilter/ebt_stp.c
+++ b/net/bridge/netfilter/ebt_stp.c
@@ -153,7 +153,7 @@ ebt_stp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_stp_mt_check(const struct xt_mtchk_param *par)
+static int ebt_stp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ebt_stp_info *info = par->matchinfo;
 	const uint8_t bridge_ula[6] = {0x01, 0x80, 0xc2, 0x00, 0x00, 0x00};
diff --git a/net/bridge/netfilter/ebt_vlan.c b/net/bridge/netfilter/ebt_vlan.c
index 5c44f51..04a9575 100644
--- a/net/bridge/netfilter/ebt_vlan.c
+++ b/net/bridge/netfilter/ebt_vlan.c
@@ -79,7 +79,7 @@ ebt_vlan_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ebt_vlan_mt_check(const struct xt_mtchk_param *par)
+static int ebt_vlan_mt_check(const struct xt_mtchk_param *par)
 {
 	struct ebt_vlan_info *info = par->matchinfo;
 	const struct ebt_entry *e = par->entryinfo;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 09f6567..771ffa7 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2176,7 +2176,7 @@ icmp_match(const struct sk_buff *skb, const struct xt_match_param *par)
 				    !!(icmpinfo->invflags&IPT_ICMP_INV));
 }
 
-static bool icmp_checkentry(const struct xt_mtchk_param *par)
+static int icmp_checkentry(const struct xt_mtchk_param *par)
 {
 	const struct ipt_icmp *icmpinfo = par->matchinfo;
 
diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
index ea4f58a..81197f4 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -70,7 +70,7 @@ addrtype_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ret;
 }
 
-static bool addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
+static int addrtype_mt_checkentry_v1(const struct xt_mtchk_param *par)
 {
 	struct ipt_addrtype_info_v1 *info = par->matchinfo;
 
diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 4f27e17..667ded1 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -55,7 +55,7 @@ static bool ah_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			 !!(ahinfo->invflags & IPT_AH_INV_SPI));
 }
 
-static bool ah_mt_check(const struct xt_mtchk_param *par)
+static int ah_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ipt_ah *ahinfo = par->matchinfo;
 
diff --git a/net/ipv4/netfilter/ipt_ecn.c b/net/ipv4/netfilter/ipt_ecn.c
index e661108..d1e234f 100644
--- a/net/ipv4/netfilter/ipt_ecn.c
+++ b/net/ipv4/netfilter/ipt_ecn.c
@@ -85,7 +85,7 @@ static bool ecn_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool ecn_mt_check(const struct xt_mtchk_param *par)
+static int ecn_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ipt_ecn_info *info = par->matchinfo;
 	const struct ipt_ip *ip = par->entryinfo;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 41e2429..595b45d 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2209,7 +2209,7 @@ icmp6_match(const struct sk_buff *skb, const struct xt_match_param *par)
 }
 
 /* Called when user tries to insert an entry of this type. */
-static bool icmp6_checkentry(const struct xt_mtchk_param *par)
+static int icmp6_checkentry(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_icmp *icmpinfo = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_ah.c b/net/ipv6/netfilter/ip6t_ah.c
index 4429bfd..3d57044 100644
--- a/net/ipv6/netfilter/ip6t_ah.c
+++ b/net/ipv6/netfilter/ip6t_ah.c
@@ -87,7 +87,7 @@ static bool ah_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 		!(ahinfo->hdrres && ah->reserved);
 }
 
-static bool ah_mt6_check(const struct xt_mtchk_param *par)
+static int ah_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_ah *ahinfo = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_frag.c b/net/ipv6/netfilter/ip6t_frag.c
index 5c0da91..c2dba27 100644
--- a/net/ipv6/netfilter/ip6t_frag.c
+++ b/net/ipv6/netfilter/ip6t_frag.c
@@ -102,7 +102,7 @@ frag_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 		  (ntohs(fh->frag_off) & IP6_MF));
 }
 
-static bool frag_mt6_check(const struct xt_mtchk_param *par)
+static int frag_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_frag *fraginfo = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index f4b7388..1b29431 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -164,7 +164,7 @@ hbh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	return false;
 }
 
-static bool hbh_mt6_check(const struct xt_mtchk_param *par)
+static int hbh_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_opts *optsinfo = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_ipv6header.c b/net/ipv6/netfilter/ip6t_ipv6header.c
index 91490ad..90e1e04 100644
--- a/net/ipv6/netfilter/ip6t_ipv6header.c
+++ b/net/ipv6/netfilter/ip6t_ipv6header.c
@@ -118,7 +118,7 @@ ipv6header_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	}
 }
 
-static bool ipv6header_mt6_check(const struct xt_mtchk_param *par)
+static int ipv6header_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_ipv6header_info *info = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index 0181eb8..d940804 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -62,7 +62,7 @@ static bool mh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			  !!(mhinfo->invflags & IP6T_MH_INV_TYPE));
 }
 
-static bool mh_mt6_check(const struct xt_mtchk_param *par)
+static int mh_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_mh *mhinfo = par->matchinfo;
 
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index c58d653..76397f3 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -183,7 +183,7 @@ static bool rt_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	return false;
 }
 
-static bool rt_mt6_check(const struct xt_mtchk_param *par)
+static int rt_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_rt *rtinfo = par->matchinfo;
 
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 4c273e8..1f2c35e 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -132,7 +132,7 @@ xt_cluster_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	       !!(info->flags & XT_CLUSTER_F_INV);
 }
 
-static bool xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
+static int xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 {
 	struct xt_cluster_match_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_connbytes.c b/net/netfilter/xt_connbytes.c
index edb7bbd..136ef4c 100644
--- a/net/netfilter/xt_connbytes.c
+++ b/net/netfilter/xt_connbytes.c
@@ -93,7 +93,7 @@ connbytes_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		return what >= sinfo->count.from;
 }
 
-static bool connbytes_mt_check(const struct xt_mtchk_param *par)
+static int connbytes_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_connbytes_info *sinfo = par->matchinfo;
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index d5b26da..a9fec38 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -216,7 +216,7 @@ connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return false;
 }
 
-static bool connlimit_mt_check(const struct xt_mtchk_param *par)
+static int connlimit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_connlimit_info *info = par->matchinfo;
 	unsigned int i;
diff --git a/net/netfilter/xt_connmark.c b/net/netfilter/xt_connmark.c
index 7a51ba6..df7eaff 100644
--- a/net/netfilter/xt_connmark.c
+++ b/net/netfilter/xt_connmark.c
@@ -103,7 +103,7 @@ connmark_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ((ct->mark & info->mask) == info->mark) ^ info->invert;
 }
 
-static bool connmark_mt_check(const struct xt_mtchk_param *par)
+static int connmark_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
diff --git a/net/netfilter/xt_conntrack.c b/net/netfilter/xt_conntrack.c
index 387172b..500e033 100644
--- a/net/netfilter/xt_conntrack.c
+++ b/net/netfilter/xt_conntrack.c
@@ -206,7 +206,7 @@ conntrack_mt_v2(const struct sk_buff *skb, const struct xt_match_param *par)
 	return conntrack_mt(skb, par, info->state_mask, info->status_mask);
 }
 
-static bool conntrack_mt_check(const struct xt_mtchk_param *par)
+static int conntrack_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
diff --git a/net/netfilter/xt_dccp.c b/net/netfilter/xt_dccp.c
index 8f6014f..da8c301 100644
--- a/net/netfilter/xt_dccp.c
+++ b/net/netfilter/xt_dccp.c
@@ -123,7 +123,7 @@ dccp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			   XT_DCCP_OPTION, info->flags, info->invflags);
 }
 
-static bool dccp_mt_check(const struct xt_mtchk_param *par)
+static int dccp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_dccp_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 6ecedc1..295da4c 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -42,7 +42,7 @@ dscp_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	return (dscp == info->dscp) ^ !!info->invert;
 }
 
-static bool dscp_mt_check(const struct xt_mtchk_param *par)
+static int dscp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_dscp_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index 1a446d6..9f5da97 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -60,7 +60,7 @@ static bool esp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			 !!(espinfo->invflags & XT_ESP_INV_SPI));
 }
 
-static bool esp_mt_check(const struct xt_mtchk_param *par)
+static int esp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_esp *espinfo = par->matchinfo;
 
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 8f3e0c0..d13800c 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -671,7 +671,7 @@ hashlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return false;
 }
 
-static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
+static int hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 {
 	struct net *net = par->net;
 	struct xt_hashlimit_info *r = par->matchinfo;
@@ -707,7 +707,7 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	return true;
 }
 
-static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
+static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct net *net = par->net;
 	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
diff --git a/net/netfilter/xt_helper.c b/net/netfilter/xt_helper.c
index 482aff2..6e177b2 100644
--- a/net/netfilter/xt_helper.c
+++ b/net/netfilter/xt_helper.c
@@ -54,7 +54,7 @@ helper_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ret;
 }
 
-static bool helper_mt_check(const struct xt_mtchk_param *par)
+static int helper_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_helper_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_limit.c b/net/netfilter/xt_limit.c
index b3dfca6..138a324 100644
--- a/net/netfilter/xt_limit.c
+++ b/net/netfilter/xt_limit.c
@@ -97,7 +97,7 @@ user2credits(u_int32_t user)
 	return (user * HZ * CREDITS_PER_JIFFY) / XT_LIMIT_SCALE;
 }
 
-static bool limit_mt_check(const struct xt_mtchk_param *par)
+static int limit_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_rateinfo *r = par->matchinfo;
 	struct xt_limit_priv *priv;
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index 4fa90c8..b446738 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -152,7 +152,7 @@ check(u_int16_t proto,
 		&& count <= XT_MULTI_PORTS;
 }
 
-static bool multiport_mt_check_v0(const struct xt_mtchk_param *par)
+static int multiport_mt_check_v0(const struct xt_mtchk_param *par)
 {
 	const struct ipt_ip *ip = par->entryinfo;
 	const struct xt_multiport *multiinfo = par->matchinfo;
@@ -161,7 +161,7 @@ static bool multiport_mt_check_v0(const struct xt_mtchk_param *par)
 		     multiinfo->count);
 }
 
-static bool multiport_mt_check(const struct xt_mtchk_param *par)
+static int multiport_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct ipt_ip *ip = par->entryinfo;
 	const struct xt_multiport_v1 *multiinfo = par->matchinfo;
@@ -170,7 +170,7 @@ static bool multiport_mt_check(const struct xt_mtchk_param *par)
 		     multiinfo->count);
 }
 
-static bool multiport_mt6_check_v0(const struct xt_mtchk_param *par)
+static int multiport_mt6_check_v0(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_ip6 *ip = par->entryinfo;
 	const struct xt_multiport *multiinfo = par->matchinfo;
@@ -179,7 +179,7 @@ static bool multiport_mt6_check_v0(const struct xt_mtchk_param *par)
 		     multiinfo->count);
 }
 
-static bool multiport_mt6_check(const struct xt_mtchk_param *par)
+static int multiport_mt6_check(const struct xt_mtchk_param *par)
 {
 	const struct ip6t_ip6 *ip = par->entryinfo;
 	const struct xt_multiport_v1 *multiinfo = par->matchinfo;
diff --git a/net/netfilter/xt_physdev.c b/net/netfilter/xt_physdev.c
index 3d42a27..850e412 100644
--- a/net/netfilter/xt_physdev.c
+++ b/net/netfilter/xt_physdev.c
@@ -83,7 +83,7 @@ match_outdev:
 	return (!!ret ^ !(info->invert & XT_PHYSDEV_OP_OUT));
 }
 
-static bool physdev_mt_check(const struct xt_mtchk_param *par)
+static int physdev_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_physdev_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index de3aded..c9965b6 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -128,7 +128,7 @@ policy_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ret;
 }
 
-static bool policy_mt_check(const struct xt_mtchk_param *par)
+static int policy_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_policy_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_quota.c b/net/netfilter/xt_quota.c
index 390b7d0..2861fac 100644
--- a/net/netfilter/xt_quota.c
+++ b/net/netfilter/xt_quota.c
@@ -43,7 +43,7 @@ quota_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ret;
 }
 
-static bool quota_mt_check(const struct xt_mtchk_param *par)
+static int quota_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_quota_info *q = par->matchinfo;
 
diff --git a/net/netfilter/xt_rateest.c b/net/netfilter/xt_rateest.c
index 4fc6a91..3b5e3d6 100644
--- a/net/netfilter/xt_rateest.c
+++ b/net/netfilter/xt_rateest.c
@@ -74,7 +74,7 @@ xt_rateest_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ret;
 }
 
-static bool xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
+static int xt_rateest_mt_checkentry(const struct xt_mtchk_param *par)
 {
 	struct xt_rateest_match_info *info = par->matchinfo;
 	struct xt_rateest *est1, *est2;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 8530944..52042c8 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -305,7 +305,7 @@ out:
 	return ret;
 }
 
-static bool recent_mt_check(const struct xt_mtchk_param *par)
+static int recent_mt_check(const struct xt_mtchk_param *par)
 {
 	struct recent_net *recent_net = recent_pernet(par->net);
 	const struct xt_recent_mtinfo *info = par->matchinfo;
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index 977b182..5037a7a 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -144,7 +144,7 @@ sctp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			   XT_SCTP_CHUNK_TYPES, info->flags, info->invflags);
 }
 
-static bool sctp_mt_check(const struct xt_mtchk_param *par)
+static int sctp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_sctp_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 94893be..8b15b13 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -37,7 +37,7 @@ state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return (sinfo->statemask & statebit);
 }
 
-static bool state_mt_check(const struct xt_mtchk_param *par)
+static int state_mt_check(const struct xt_mtchk_param *par)
 {
 	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		pr_info("cannot load conntrack support for proto=%u\n",
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 51ac1bb..a577ab0 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -52,7 +52,7 @@ statistic_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return ret;
 }
 
-static bool statistic_mt_check(const struct xt_mtchk_param *par)
+static int statistic_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_statistic_info *info = par->matchinfo;
 
diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index b4d7741..7d14121 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -40,7 +40,7 @@ string_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 #define STRING_TEXT_PRIV(m) ((struct xt_string_info *)(m))
 
-static bool string_mt_check(const struct xt_mtchk_param *par)
+static int string_mt_check(const struct xt_mtchk_param *par)
 {
 	struct xt_string_info *conf = par->matchinfo;
 	struct ts_config *ts_conf;
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index b53887f..0072841 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -120,7 +120,7 @@ static bool tcp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool tcp_mt_check(const struct xt_mtchk_param *par)
+static int tcp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_tcp *tcpinfo = par->matchinfo;
 
@@ -155,7 +155,7 @@ static bool udp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 			      !!(udpinfo->invflags & XT_UDP_INV_DSTPT));
 }
 
-static bool udp_mt_check(const struct xt_mtchk_param *par)
+static int udp_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_udp *udpinfo = par->matchinfo;
 
diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 45ed05b..db74f4f 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -217,7 +217,7 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	return true;
 }
 
-static bool time_mt_check(const struct xt_mtchk_param *par)
+static int time_mt_check(const struct xt_mtchk_param *par)
 {
 	const struct xt_time_info *info = par->matchinfo;
 
-- 
1.7.0.4

