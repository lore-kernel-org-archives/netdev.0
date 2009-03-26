From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 11/12: nf_conntrack: calculate per-protocol nlattr size
Date: Thu, 26 Mar 2009 20:02:45 +0100 (MET)
Message-ID: <20090326190240.23365.32892.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a400c30edb1958ceb53c4b8ce78989189b36df47
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Wed Mar 25 21:53:39 2009 +0100

    netfilter: nf_conntrack: calculate per-protocol nlattr size
    
    Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 8b681f2..7d2ead7 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -328,6 +328,11 @@ static int ipv4_nlattr_to_tuple(struct nlattr *tb[],
 
 	return 0;
 }
+
+static int ipv4_nlattr_tuple_size(void)
+{
+	return nla_policy_len(ipv4_nla_policy, CTA_IP_MAX + 1);
+}
 #endif
 
 static struct nf_sockopt_ops so_getorigdst = {
@@ -347,6 +352,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4 __read_mostly = {
 	.get_l4proto	 = ipv4_get_l4proto,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr = ipv4_tuple_to_nlattr,
+	.nlattr_tuple_size = ipv4_nlattr_tuple_size,
 	.nlattr_to_tuple = ipv4_nlattr_to_tuple,
 	.nla_policy	 = ipv4_nla_policy,
 #endif
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 2a8bee2..23b2c2e 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -262,6 +262,11 @@ static int icmp_nlattr_to_tuple(struct nlattr *tb[],
 
 	return 0;
 }
+
+static int icmp_nlattr_tuple_size(void)
+{
+	return nla_policy_len(icmp_nla_policy, CTA_PROTO_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -309,6 +314,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 	.me			= NULL,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= icmp_tuple_to_nlattr,
+	.nlattr_tuple_size	= icmp_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmp_nlattr_to_tuple,
 	.nla_policy		= icmp_nla_policy,
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index e6852f6..2a15c2d 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -342,6 +342,11 @@ static int ipv6_nlattr_to_tuple(struct nlattr *tb[],
 
 	return 0;
 }
+
+static int ipv6_nlattr_tuple_size(void)
+{
+	return nla_policy_len(ipv6_nla_policy, CTA_IP_MAX + 1);
+}
 #endif
 
 struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
@@ -353,6 +358,7 @@ struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6 __read_mostly = {
 	.get_l4proto		= ipv6_get_l4proto,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= ipv6_tuple_to_nlattr,
+	.nlattr_tuple_size	= ipv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= ipv6_nlattr_to_tuple,
 	.nla_policy		= ipv6_nla_policy,
 #endif
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 165b256..032fdf4 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -268,6 +268,11 @@ static int icmpv6_nlattr_to_tuple(struct nlattr *tb[],
 
 	return 0;
 }
+
+static int icmpv6_nlattr_tuple_size(void)
+{
+	return nla_policy_len(icmpv6_nla_policy, CTA_PROTO_MAX + 1);
+}
 #endif
 
 #ifdef CONFIG_SYSCTL
@@ -299,6 +304,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 	.error			= icmpv6_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= icmpv6_tuple_to_nlattr,
+	.nlattr_tuple_size	= icmpv6_nlattr_tuple_size,
 	.nlattr_to_tuple	= icmpv6_nlattr_to_tuple,
 	.nla_policy		= icmpv6_nla_policy,
 #endif
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index d3d5a7f..50dac8d 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -669,6 +669,12 @@ static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
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
@@ -749,8 +755,10 @@ static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
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
@@ -771,6 +779,7 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 	.to_nlattr		= dccp_to_nlattr,
 	.from_nlattr		= nlattr_to_dccp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 1b279f9..117b801 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -293,6 +293,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_gre4 __read_mostly = {
 	.me 		 = THIS_MODULE,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr = nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size = nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple = nf_ct_port_nlattr_to_tuple,
 	.nla_policy	 = nf_ct_port_nla_policy,
 #endif
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 74e0379..101b4ad 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -537,6 +537,12 @@ static int nlattr_to_sctp(struct nlattr *cda[], struct nf_conn *ct)
 
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
@@ -668,8 +674,10 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
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
@@ -696,8 +704,10 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
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
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 7d3944f..9b9e671 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1183,6 +1183,17 @@ static int nlattr_to_tcp(struct nlattr *cda[], struct nf_conn *ct)
 
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
@@ -1398,9 +1409,11 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
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
@@ -1428,9 +1441,11 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
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
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index d402117..70809d1 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -195,6 +195,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
@@ -222,6 +223,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 4579d8d..4614696 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -180,6 +180,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 	.error			= udplite_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
