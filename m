From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/05: nf_ct_dccp/udplite: fix protocol registration error
Date: Fri, 24 Apr 2009 17:44:03 +0200 (MEST)
Message-ID: <20090424154358.28952.13426.sendpatchset@x2.localnet>
References: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090424154355.28952.21443.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 5ff482940f5aa2cdc3424c4a8ea94b9833b2af5f
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Apr 24 15:37:44 2009 +0200

    netfilter: nf_ct_dccp/udplite: fix protocol registration error
    
    Commit d0dba725 (netfilter: ctnetlink: add callbacks to the per-proto
    nlattrs) changed the protocol registration function to abort if the
    to-be registered protocol doesn't provide a new callback function.
    
    The DCCP and UDP-Lite IPv6 protocols were missed in this conversion,
    add the required callback pointer.
    
    Reported-and-tested-by: Steven Jan Springl <steven@springl.ukfsn.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 50dac8d..5411d63 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -777,6 +777,7 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 	.print_conntrack	= dccp_print_conntrack,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.to_nlattr		= dccp_to_nlattr,
+	.nlattr_size		= dccp_nlattr_size,
 	.from_nlattr		= nlattr_to_dccp,
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
 	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 4614696..0badedc 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -204,6 +204,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 	.error			= udplite_error,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 	.tuple_to_nlattr	= nf_ct_port_tuple_to_nlattr,
+	.nlattr_tuple_size	= nf_ct_port_nlattr_tuple_size,
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
