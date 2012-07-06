From: pablo@netfilter.org
Subject: [PATCH 14/18] netfilter: nf_ct_icmpv6: add icmpv6_kmemdup_sysctl_table function
Date: Fri,  6 Jul 2012 13:17:04 +0200
Message-ID: <1341573428-3204-15-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43652 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933543Ab2GFLTU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:20 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Split sysctl function into smaller chucks to cleanup code and prepare
patches to reduce ifdef pollution.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 807ae09..9fc5cf5 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -333,22 +333,31 @@ static struct ctl_table icmpv6_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static int icmpv6_init_net(struct net *net, u_int16_t proto)
+static int icmpv6_kmemdup_sysctl_table(struct nf_proto_net *pn,
+				       struct nf_icmp_net *in)
 {
-	struct nf_icmp_net *in = icmpv6_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)in;
-	in->timeout = nf_ct_icmpv6_timeout;
 #ifdef CONFIG_SYSCTL
 	pn->ctl_table = kmemdup(icmpv6_sysctl_table,
 				sizeof(icmpv6_sysctl_table),
 				GFP_KERNEL);
 	if (!pn->ctl_table)
 		return -ENOMEM;
+
 	pn->ctl_table[0].data = &in->timeout;
 #endif
 	return 0;
 }
 
+static int icmpv6_init_net(struct net *net, u_int16_t proto)
+{
+	struct nf_icmp_net *in = icmpv6_pernet(net);
+	struct nf_proto_net *pn = &in->pn;
+
+	in->timeout = nf_ct_icmpv6_timeout;
+
+	return icmpv6_kmemdup_sysctl_table(pn, in);
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
-- 
1.7.10
