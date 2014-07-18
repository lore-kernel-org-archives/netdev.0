From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 16/18] netfilter: use IS_ENABLED() macro
Date: Fri, 18 Jul 2014 13:01:10 +0200
Message-ID: <1405681272-4994-17-git-send-email-pablo@netfilter.org>
References: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46634 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761501AbaGRLB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2014 07:01:28 -0400
In-Reply-To: <1405681272-4994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>

replace:
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
with
 #if IS_ENABLED(CONFIG_NF_CT_NETLINK)

replace:
 #if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
with
 #if !IS_ENABLED(CONFIG_NF_NAT)

replace:
 #if !defined(CONFIG_NF_CONNTRACK) && !defined(CONFIG_NF_CONNTRACK_MODULE)
with
 #if !IS_ENABLED(CONFIG_NF_CONNTRACK)

And add missing:
 IS_ENABLED(CONFIG_NF_CT_NETLINK)

in net/ipv{4,6}/netfilter/nf_nat_l3proto_ipv{4,6}.c

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    4 ++--
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    4 ++--
 net/ipv4/netfilter/nf_defrag_ipv4.c            |    8 ++++----
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |    4 ++++
 net/ipv4/netfilter/nf_nat_proto_gre.c          |    2 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c         |    2 +-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |    4 ++++
 net/netfilter/nf_nat_core.c                    |    2 +-
 net/netfilter/nf_nat_proto_common.c            |    2 +-
 net/netfilter/nf_nat_proto_dccp.c              |    2 +-
 net/netfilter/nf_nat_proto_sctp.c              |    2 +-
 net/netfilter/nf_nat_proto_tcp.c               |    2 +-
 net/netfilter/nf_nat_proto_udp.c               |    2 +-
 net/netfilter/nf_nat_proto_udplite.c           |    2 +-
 14 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8127dc8..4ce44c4 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -314,7 +314,7 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 	return -ENOENT;
 }
 
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
@@ -388,7 +388,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.invert_tuple	 = ipv4_invert_tuple,
 	.print_tuple	 = ipv4_print_tuple,
 	.get_l4proto	 = ipv4_get_l4proto,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr = ipv4_tuple_to_nlattr,
 	.nlattr_tuple_size = ipv4_nlattr_tuple_size,
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index a338dad..b91b264 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -226,7 +226,7 @@ icmp_error(struct net *net, struct nf_conn *tmpl,
 	return icmp_error_message(net, tmpl, skb, ctinfo, hooknum);
 }
 
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
@@ -408,7 +408,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.error			= icmp_error,
 	.destroy		= NULL,
 	.me			= NULL,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.tuple_to_nlattr	= icmp_tuple_to_nlattr,
 	.nlattr_tuple_size	= icmp_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmp_nlattr_to_tuple,
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index b8f6381..76bd1ae 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -17,7 +17,7 @@
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
 #endif
 #include <net/netfilter/nf_conntrack_zones.h>
@@ -45,7 +45,7 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 {
 	u16 zone = NF_CT_DEFAULT_ZONE;
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (skb->nfct)
 		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
 #endif
@@ -74,8 +74,8 @@ static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
 	    inet->nodefrag)
 		return NF_ACCEPT;
 
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-#if !defined(CONFIG_NF_NAT) && !defined(CONFIG_NF_NAT_MODULE)
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#if !IS_ENABLED(CONFIG_NF_NAT)
 	/* Previously seen (loopback)?  Ignore.  Do this before
 	   fragment check. */
 	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index d8b2e14..14f5ccd 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -154,6 +154,7 @@ static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
 					 htons(oldlen), htons(datalen), 1);
 }
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 static int nf_nat_ipv4_nlattr_to_range(struct nlattr *tb[],
 				       struct nf_nat_range *range)
 {
@@ -169,6 +170,7 @@ static int nf_nat_ipv4_nlattr_to_range(struct nlattr *tb[],
 
 	return 0;
 }
+#endif
 
 static const struct nf_nat_l3proto nf_nat_l3proto_ipv4 = {
 	.l3proto		= NFPROTO_IPV4,
@@ -177,7 +179,9 @@ static const struct nf_nat_l3proto nf_nat_l3proto_ipv4 = {
 	.manip_pkt		= nf_nat_ipv4_manip_pkt,
 	.csum_update		= nf_nat_ipv4_csum_update,
 	.csum_recalc		= nf_nat_ipv4_csum_recalc,
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_ipv4_nlattr_to_range,
+#endif
 #ifdef CONFIG_XFRM
 	.decode_session		= nf_nat_ipv4_decode_session,
 #endif
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 690d8901..9414923 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -124,7 +124,7 @@ static const struct nf_nat_l4proto gre = {
 	.manip_pkt		= gre_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= gre_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index eb30347..4557b4a 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -77,7 +77,7 @@ const struct nf_nat_l4proto nf_nat_l4proto_icmp = {
 	.manip_pkt		= icmp_manip_pkt,
 	.in_range		= icmp_in_range,
 	.unique_tuple		= icmp_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index abfe75a..fc8e49b 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -158,6 +158,7 @@ static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
 					 htons(oldlen), htons(datalen), 1);
 }
 
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 static int nf_nat_ipv6_nlattr_to_range(struct nlattr *tb[],
 				       struct nf_nat_range *range)
 {
@@ -175,6 +176,7 @@ static int nf_nat_ipv6_nlattr_to_range(struct nlattr *tb[],
 
 	return 0;
 }
+#endif
 
 static const struct nf_nat_l3proto nf_nat_l3proto_ipv6 = {
 	.l3proto		= NFPROTO_IPV6,
@@ -183,7 +185,9 @@ static const struct nf_nat_l3proto nf_nat_l3proto_ipv6 = {
 	.manip_pkt		= nf_nat_ipv6_manip_pkt,
 	.csum_update		= nf_nat_ipv6_csum_update,
 	.csum_recalc		= nf_nat_ipv6_csum_recalc,
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_ipv6_nlattr_to_range,
+#endif
 #ifdef CONFIG_XFRM
 	.decode_session	= nf_nat_ipv6_decode_session,
 #endif
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 09096a6..31c5015 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -677,7 +677,7 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 	.flags		= NF_CT_EXT_F_PREALLOC,
 };
 
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
diff --git a/net/netfilter/nf_nat_proto_common.c b/net/netfilter/nf_nat_proto_common.c
index 83a72a2..fbce552 100644
--- a/net/netfilter/nf_nat_proto_common.c
+++ b/net/netfilter/nf_nat_proto_common.c
@@ -95,7 +95,7 @@ void nf_nat_l4proto_unique_tuple(const struct nf_nat_l3proto *l3proto,
 }
 EXPORT_SYMBOL_GPL(nf_nat_l4proto_unique_tuple);
 
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 int nf_nat_l4proto_nlattr_to_range(struct nlattr *tb[],
 				   struct nf_nat_range *range)
 {
diff --git a/net/netfilter/nf_nat_proto_dccp.c b/net/netfilter/nf_nat_proto_dccp.c
index c8be2cd..b8067b5 100644
--- a/net/netfilter/nf_nat_proto_dccp.c
+++ b/net/netfilter/nf_nat_proto_dccp.c
@@ -78,7 +78,7 @@ static const struct nf_nat_l4proto nf_nat_l4proto_dccp = {
 	.manip_pkt		= dccp_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= dccp_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index 754536f..cbc7ade 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -59,7 +59,7 @@ static const struct nf_nat_l4proto nf_nat_l4proto_sctp = {
 	.manip_pkt		= sctp_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= sctp_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/netfilter/nf_nat_proto_tcp.c b/net/netfilter/nf_nat_proto_tcp.c
index 83ec8a6..37f5505 100644
--- a/net/netfilter/nf_nat_proto_tcp.c
+++ b/net/netfilter/nf_nat_proto_tcp.c
@@ -79,7 +79,7 @@ const struct nf_nat_l4proto nf_nat_l4proto_tcp = {
 	.manip_pkt		= tcp_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= tcp_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/netfilter/nf_nat_proto_udp.c b/net/netfilter/nf_nat_proto_udp.c
index 7df613f..b0ede2f 100644
--- a/net/netfilter/nf_nat_proto_udp.c
+++ b/net/netfilter/nf_nat_proto_udp.c
@@ -70,7 +70,7 @@ const struct nf_nat_l4proto nf_nat_l4proto_udp = {
 	.manip_pkt		= udp_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= udp_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/netfilter/nf_nat_proto_udplite.c b/net/netfilter/nf_nat_proto_udplite.c
index 776a0d1..368f14e 100644
--- a/net/netfilter/nf_nat_proto_udplite.c
+++ b/net/netfilter/nf_nat_proto_udplite.c
@@ -69,7 +69,7 @@ static const struct nf_nat_l4proto nf_nat_l4proto_udplite = {
 	.manip_pkt		= udplite_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= udplite_unique_tuple,
-#if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
+#if IS_ENABLED(CONFIG_NF_CT_NETLINK)
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
-- 
1.7.10.4
