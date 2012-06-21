From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 13/13] netfilter: nf_conntrack_l4proto_icmpv6 cleanup
Date: Thu, 21 Jun 2012 22:36:50 +0800
Message-ID: <1340289410-17642-13-git-send-email-gaofeng@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

add function icmpv6_kmemdup_sysctl_table to make codes
more clearer.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

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
1.7.7.6

