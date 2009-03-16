From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 6/6] netfilter: calculate per-protocol nlattr size
Date: Mon, 16 Mar 2009 23:07:05 +0100
Message-ID: <20090316221142.404968426@jonathan.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54430 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758705AbZCPWLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 18:11:48 -0400
Content-Disposition: inline; filename=netfilter-calculate-per-protocol-nlattr-size.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
===================================================================
--- net-next-2.6.orig/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ net-next-2.6/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -326,6 +326,11 @@ static int ipv4_nlattr_to_tuple(struct n
 
 	return 0;
 }
+
+static int ipv4_nlattr_tuple_size(void)
+{
+	return nla_policy_len(ipv4_nla_policy, CTA_IP_MAX + 1);
+}
 #endif
 
 static struct nf_sockopt_ops so_getorigdst = {
@@ -345,6 +350,7 @@ struct nf_conntrack_l3proto nf_conntrack
 	.get_l4proto	 = ipv4_get_l4proto,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr = ipv4_tuple_to_nlattr,
+	.nlattr_tuple_size = ipv4_nlattr_tuple_size,
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
 	.nla_policy	 = ipv4_nla_policy,
 #endif
Index: net-next-2.6/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
===================================================================
--- net-next-2.6.orig/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ net-next-2.6/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
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
Index: net-next-2.6/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
===================================================================
--- net-next-2.6.orig/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ net-next-2.6/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -341,6 +341,11 @@ static int ipv6_nlattr_to_tuple(struct n
 
 	return 0;
 }
+
+static int ipv6_nlattr_tuple_size(void)
+{
+	return nla_policy_len(ipv6_nla_policy, CTA_IP_MAX + 1);
+}
 #endif
 
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
@@ -352,6 +357,7 @@ struct nf_conntrack_l3proto nf_conntrack
 	.get_l4proto		= ipv6_get_l4proto,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= ipv6_tuple_to_nlattr,
+	.nlattr_tuple_size	= ipv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
Index: net-next-2.6/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
===================================================================
--- net-next-2.6.orig/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ net-next-2.6/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -243,6 +243,11 @@ static int icmpv6_nlattr_to_tuple(struct
 
 	return 0;
 }
+
+static int icmpv6_nlattr_tuple_size(void)
+{
+	return nla_policy_len(icmpv6_nla_policy, CTA_PROTO_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -274,6 +279,7 @@ struct nf_conntrack_l4proto nf_conntrack
 	.error			= icmpv6_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= icmpv6_tuple_to_nlattr,
+	.nlattr_tuple_size	= icmpv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmpv6_nlattr_to_tuple,
 	.nla_policy		= icmpv6_nla_policy,
 #endif
Index: net-next-2.6/net/netfilter/nf_conntrack_proto_dccp.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto_dccp.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto_dccp.c
@@ -657,6 +657,12 @@ static int nlattr_to_dccp(struct nlattr 
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
@@ -746,8 +752,10 @@ static struct nf_conntrack_l4proto dccp_
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
@@ -773,6 +781,7 @@ static struct nf_conntrack_l4proto dccp_
 	.to_nlattr		= dccp_to_nlattr,
 	.from_nlattr		= nlattr_to_dccp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
Index: net-next-2.6/net/netfilter/nf_conntrack_proto_gre.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto_gre.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto_gre.c
@@ -293,6 +293,7 @@ static struct nf_conntrack_l4proto nf_co
 	.me 		 = THIS_MODULE,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr = nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size = nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple = nf_ct_port_nlattr_to_tuple,
 	.nla_policy	 = nf_ct_port_nla_policy,
 #endif
Index: net-next-2.6/net/netfilter/nf_conntrack_proto_sctp.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto_sctp.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto_sctp.c
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
Index: net-next-2.6/net/netfilter/nf_conntrack_proto_tcp.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto_tcp.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1181,6 +1181,17 @@ static int nlattr_to_tcp(struct nlattr *
 
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
@@ -1396,9 +1407,11 @@ struct nf_conntrack_l4proto nf_conntrack
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
@@ -1426,9 +1439,11 @@ struct nf_conntrack_l4proto nf_conntrack
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
Index: net-next-2.6/net/netfilter/nf_conntrack_proto_udp.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto_udp.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto_udp.c
@@ -193,6 +193,7 @@ struct nf_conntrack_l4proto nf_conntrack
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
@@ -220,6 +221,7 @@ struct nf_conntrack_l4proto nf_conntrack
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
Index: net-next-2.6/net/netfilter/nf_conntrack_proto_udplite.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto_udplite.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto_udplite.c
@@ -180,6 +180,7 @@ static struct nf_conntrack_l4proto nf_co
 	.error			= udplite_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif

-- 
