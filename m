From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 15/17] netfilter: cleanup sysctl for l4proto and l3proto
Date: Mon, 14 May 2012 16:52:25 +0800
Message-ID: <1336985547-31960-16-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:12903 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755382Ab2ENIxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 04:53:09 -0400
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

delete no useless sysctl data for l4proto and l3proto.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |    2 --
 include/net/netfilter/nf_conntrack_l4proto.h   |   10 ----------
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    1 -
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 --------
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    5 -----
 net/netfilter/nf_conntrack_proto_generic.c     |    8 --------
 net/netfilter/nf_conntrack_proto_sctp.c        |   15 ---------------
 net/netfilter/nf_conntrack_proto_tcp.c         |   15 ---------------
 net/netfilter/nf_conntrack_proto_udp.c         |   15 ---------------
 net/netfilter/nf_conntrack_proto_udplite.c     |   12 ------------
 10 files changed, 0 insertions(+), 91 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index d6df8c7..6f7c13f 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -64,9 +64,7 @@ struct nf_conntrack_l3proto {
 	size_t nla_size;
 
 #ifdef CONFIG_SYSCTL
-	struct ctl_table_header	*ctl_table_header;
 	const char		*ctl_table_path;
-	struct ctl_table	*ctl_table;
 #endif /* CONFIG_SYSCTL */
 
 	/* Init l3proto pernet data */
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 0d329b9..4881df34 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -95,16 +95,6 @@ struct nf_conntrack_l4proto {
 		const struct nla_policy *nla_policy;
 	} ctnl_timeout;
 #endif
-
-#ifdef CONFIG_SYSCTL
-	struct ctl_table_header	**ctl_table_header;
-	struct ctl_table	*ctl_table;
-	unsigned int		*ctl_table_users;
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct ctl_table_header	*ctl_compat_table_header;
-	struct ctl_table	*ctl_compat_table;
-#endif
-#endif
 	int	*net_id;
 	/* Init l4proto pernet data */
 	int (*init_net)(struct net *net, u_int8_t compat);
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 1dd17ed..173da4d 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -379,7 +379,6 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 #endif
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	.ctl_table_path  = "net/ipv4/netfilter",
-	.ctl_table	 = ip_ct_sysctl_table,
 #endif
 	.init_net	= ipv4_init_net,
 	.me		 = THIS_MODULE,
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index f468d10..90da247 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -313,7 +313,6 @@ icmp_timeout_nla_policy[CTA_TIMEOUT_ICMP_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *icmp_sysctl_header;
 static struct ctl_table icmp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmp_timeout",
@@ -394,12 +393,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 		.nla_policy	= icmp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_header	= &icmp_sysctl_header,
-	.ctl_table		= icmp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= icmp_compat_sysctl_table,
-#endif
-#endif
 	.init_net		= icmp_init_net,
 };
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 3cb422e..12ca315 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -320,7 +320,6 @@ icmpv6_timeout_nla_policy[CTA_TIMEOUT_ICMPV6_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *icmpv6_sysctl_header;
 static struct ctl_table icmpv6_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmpv6_timeout",
@@ -376,9 +375,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 		.nla_policy	= icmpv6_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_header	= &icmpv6_sysctl_header,
-	.ctl_table		= icmpv6_sysctl_table,
-#endif
 	.init_net		= icmpv6_init_net,
 };
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 7976a64..0f87a77 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -111,7 +111,6 @@ generic_timeout_nla_policy[CTA_TIMEOUT_GENERIC_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *generic_sysctl_header;
 static struct ctl_table generic_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_generic_timeout",
@@ -183,13 +182,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 		.nla_policy	= generic_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_header	= &generic_sysctl_header,
-	.ctl_table		= generic_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= generic_compat_sysctl_table,
-#endif
-#endif
 	.init_net		= generic_init_net,
 };
 
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 3f0fdf8..291cef4 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -610,8 +610,6 @@ sctp_timeout_nla_policy[CTA_TIMEOUT_SCTP_MAX+1] = {
 
 
 #ifdef CONFIG_SYSCTL
-static unsigned int sctp_sysctl_table_users;
-static struct ctl_table_header *sctp_sysctl_header;
 static struct ctl_table sctp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_sctp_timeout_closed",
@@ -791,14 +789,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 		.nla_policy	= sctp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &sctp_sysctl_table_users,
-	.ctl_table_header	= &sctp_sysctl_header,
-	.ctl_table		= sctp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= sctp_compat_sysctl_table,
-#endif
-#endif
 	.net_id			= &sctp_net_id,
 	.init_net		= sctp_init_net,
 };
@@ -834,11 +824,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #endif
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &sctp_sysctl_table_users,
-	.ctl_table_header	= &sctp_sysctl_header,
-	.ctl_table		= sctp_sysctl_table,
-#endif
 	.net_id			= &sctp_net_id,
 	.init_net		= sctp_init_net,
 };
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index dd19350..4d16b8a 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1363,8 +1363,6 @@ static const struct nla_policy tcp_timeout_nla_policy[CTA_TIMEOUT_TCP_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static unsigned int tcp_sysctl_table_users;
-static struct ctl_table_header *tcp_sysctl_header;
 static struct ctl_table tcp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_tcp_timeout_syn_sent",
@@ -1634,14 +1632,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 		.nla_policy	= tcp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &tcp_sysctl_table_users,
-	.ctl_table_header	= &tcp_sysctl_header,
-	.ctl_table		= tcp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= tcp_compat_sysctl_table,
-#endif
-#endif
 	.init_net		= tcp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
@@ -1679,11 +1669,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 		.nla_policy	= tcp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &tcp_sysctl_table_users,
-	.ctl_table_header	= &tcp_sysctl_header,
-	.ctl_table		= tcp_sysctl_table,
-#endif
 	.init_net		= tcp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp6);
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 072ef9c..c38ab58 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -199,8 +199,6 @@ udp_timeout_nla_policy[CTA_TIMEOUT_UDP_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static unsigned int udp_sysctl_table_users;
-static struct ctl_table_header *udp_sysctl_header;
 static struct ctl_table udp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udp_timeout",
@@ -307,14 +305,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udp_sysctl_table_users,
-	.ctl_table_header	= &udp_sysctl_header,
-	.ctl_table		= udp_sysctl_table,
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= udp_compat_sysctl_table,
-#endif
-#endif
 	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
@@ -347,11 +337,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udp_sysctl_table_users,
-	.ctl_table_header	= &udp_sysctl_header,
-	.ctl_table		= udp_sysctl_table,
-#endif
 	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 1e90cf5..cb3dc81 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -215,8 +215,6 @@ udplite_timeout_nla_policy[CTA_TIMEOUT_UDPLITE_MAX+1] = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
 #ifdef CONFIG_SYSCTL
-static unsigned int udplite_sysctl_table_users;
-static struct ctl_table_header *udplite_sysctl_header;
 static struct ctl_table udplite_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udplite_timeout",
@@ -288,11 +286,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 		.nla_policy	= udplite_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udplite_sysctl_table_users,
-	.ctl_table_header	= &udplite_sysctl_header,
-	.ctl_table		= udplite_sysctl_table,
-#endif
 	.net_id			= &udplite_net_id,
 	.init_net		= udplite_init_net,
 };
@@ -326,11 +319,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 		.nla_policy	= udplite_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &udplite_sysctl_table_users,
-	.ctl_table_header	= &udplite_sysctl_header,
-	.ctl_table		= udplite_sysctl_table,
-#endif
 	.net_id			= &udplite_net_id,
 	.init_net		= udplite_init_net,
 };
-- 
1.7.7.6
