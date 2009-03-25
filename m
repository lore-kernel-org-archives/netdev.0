From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 3/3] netfilter: calculate per-protocol nlattr size
Date: Wed, 25 Mar 2009 21:34:07 +0100
Message-ID: <20090325204603.079747755@jonathan.eitzenberger.org>
References: <20090325203404.581023828@jonathan.eitzenberger.org>
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=netfilter-calculate-per-protocol-nlattr-size.diff
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: nf-next-2.6/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
===================================================================
--- nf-next-2.6.orig/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ nf-next-2.6/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -328,6 +328,11 @@ static int ipv4_nlattr_to_tuple(struct n
 
 	return 0;
 }
+
+static int ipv4_nlattr_tuple_size(void)
+{
+	return nla_policy_len(ipv4_nla_policy, CTA_IP_MAX + 1);
+}
 #endif
 
 static struct nf_sockopt_ops so_getorigdst = {
@@ -347,6 +352,7 @@ struct nf_conntrack_l3proto nf_conntrack
 	.get_l4proto	 = ipv4_get_l4proto,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr = ipv4_tuple_to_nlattr,
+	.nlattr_tuple_size = ipv4_nlattr_tuple_size,
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
 	.nla_policy	 = ipv4_nla_policy,
 #endif
Index: nf-next-2.6/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
===================================================================
--- nf-next-2.6.orig/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ nf-next-2.6/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -262,6 +262,11 @@ static int icmp_nlattr_to_tuple(struct n
 
 	return 0;
 }
+
+static int icmp_nlattr_tuple_size(void)
+{
+	return nla_policy_len(icmp_nla_policy, CTA_PROTO_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -309,6 +314,7 @@ struct nf_conntrack_l4proto nf_conntrack
 	.me			= NULL,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= icmp_tuple_to_nlattr,
+	.nlattr_tuple_size	= icmp_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmp_nlattr_to_tuple,
 	.nla_policy		= icmp_nla_policy,
 #endif
Index: nf-next-2.6/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
===================================================================
--- nf-next-2.6.orig/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ nf-next-2.6/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -342,6 +342,11 @@ static int ipv6_nlattr_to_tuple(struct n
 
 	return 0;
 }
+
+static int ipv6_nlattr_tuple_size(void)
+{
+	return nla_policy_len(ipv6_nla_policy, CTA_IP_MAX + 1);
+}
 #endif
 
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
@@ -353,6 +358,7 @@ struct nf_conntrack_l3proto nf_conntrack
 	.get_l4proto		= ipv6_get_l4proto,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= ipv6_tuple_to_nlattr,
+	.nlattr_tuple_size	= ipv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
Index: nf-next-2.6/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
===================================================================
--- nf-next-2.6.orig/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ nf-next-2.6/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -268,6 +268,11 @@ static int icmpv6_nlattr_to_tuple(struct
 
 	return 0;
 }
+
+static int icmpv6_nlattr_tuple_size(void)
+{
+	return nla_policy_len(icmpv6_nla_policy, CTA_PROTO_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -299,6 +304,7 @@ struct nf_conntrack_l4proto nf_conntrack
 	.error			= icmpv6_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= icmpv6_tuple_to_nlattr,
+	.nlattr_tuple_size	= icmpv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmpv6_nlattr_to_tuple,
 	.nla_policy		= icmpv6_nla_policy,
 #endif
Index: nf-next-2.6/net/netfilter/nf_conntrack_proto_dccp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_proto_dccp.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_proto_dccp.c
@@ -669,6 +669,12 @@ static int nlattr_to_dccp(struct nlattr 
 	write_unlock_bh(&dccp_lock);
 	return 0;
 }
+
+static int dccp_nlattr_size(void)
+{
+	return nla_total_size(0)	/* CTA_PROTOINFO_DCCP */
+		+ nla_policy_len(dccp_nla_policy, CTA_PROTOINFO_DCCP_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -749,8 +755,10 @@ static struct nf_conntrack_l4proto dccp_
 	.print_conntrack	= dccp_print_conntrack,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.to_nlattr		= dccp_to_nlattr,
+	.nlattr_size		= dccp_nlattr_size,
 	.from_nlattr		= nlattr_to_dccp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
@@ -771,6 +779,7 @@ static struct nf_conntrack_l4proto dccp_
 	.to_nlattr		= dccp_to_nlattr,
 	.from_nlattr		= nlattr_to_dccp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
Index: nf-next-2.6/net/netfilter/nf_conntrack_proto_gre.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_proto_gre.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_proto_gre.c
@@ -293,6 +293,7 @@ static struct nf_conntrack_l4proto nf_co
 	.me 		 = THIS_MODULE,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr = nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size = nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple = nf_ct_port_nlattr_to_tuple,
 	.nla_policy	 = nf_ct_port_nla_policy,
 #endif
Index: nf-next-2.6/net/netfilter/nf_conntrack_proto_sctp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_proto_sctp.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_proto_sctp.c
@@ -537,6 +537,12 @@ static int nlattr_to_sctp(struct nlattr 
 
 	return 0;
 }
+
+static int sctp_nlattr_size(void)
+{
+	return nla_total_size(0)	/* CTA_PROTOINFO_SCTP */
+		+ nla_policy_len(sctp_nla_policy, CTA_PROTOINFO_SCTP_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -668,8 +674,10 @@ static struct nf_conntrack_l4proto nf_co
 	.me 			= THIS_MODULE,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.to_nlattr		= sctp_to_nlattr,
+	.nlattr_size		= sctp_nlattr_size,
 	.from_nlattr		= nlattr_to_sctp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
@@ -696,8 +704,10 @@ static struct nf_conntrack_l4proto nf_co
 	.me 			= THIS_MODULE,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.to_nlattr		= sctp_to_nlattr,
+	.nlattr_size		= sctp_nlattr_size,
 	.from_nlattr		= nlattr_to_sctp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
Index: nf-next-2.6/net/netfilter/nf_conntrack_proto_tcp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_proto_tcp.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1183,6 +1183,17 @@ static int nlattr_to_tcp(struct nlattr *
 
 	return 0;
 }
+
+static int tcp_nlattr_size(void)
+{
+	return nla_total_size(0)	   /* CTA_PROTOINFO_TCP */
+		+ nla_policy_len(tcp_nla_policy, CTA_PROTOINFO_TCP_MAX + 1);
+}
+
+static int tcp_nlattr_tuple_size(void)
+{
+	return nla_policy_len(nf_ct_port_nla_policy, CTA_PROTO_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -1398,9 +1409,11 @@ struct nf_conntrack_l4proto nf_conntrack
 	.error			= tcp_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.to_nlattr		= tcp_to_nlattr,
+	.nlattr_size		= tcp_nlattr_size,
 	.from_nlattr		= nlattr_to_tcp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= tcp_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
@@ -1428,9 +1441,11 @@ struct nf_conntrack_l4proto nf_conntrack
 	.error			= tcp_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.to_nlattr		= tcp_to_nlattr,
+	.nlattr_size		= tcp_nlattr_size,
 	.from_nlattr		= nlattr_to_tcp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= tcp_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
Index: nf-next-2.6/net/netfilter/nf_conntrack_proto_udp.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_proto_udp.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_proto_udp.c
@@ -195,6 +195,7 @@ struct nf_conntrack_l4proto nf_conntrack
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
@@ -222,6 +223,7 @@ struct nf_conntrack_l4proto nf_conntrack
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
Index: nf-next-2.6/net/netfilter/nf_conntrack_proto_udplite.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_proto_udplite.c
+++ nf-next-2.6/net/netfilter/nf_conntrack_proto_udplite.c
@@ -180,6 +180,7 @@ static struct nf_conntrack_l4proto nf_co
 	.error			= udplite_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif

-- 
