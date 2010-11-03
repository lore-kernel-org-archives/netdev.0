From: kaber@trash.net
Subject: [PATCH 2/5] netfilter: nf_nat: fix compiler warning with CONFIG_NF_CT_NETLINK=n
Date: Wed,  3 Nov 2010 23:12:49 +0100
Message-ID: <1288822372-21245-3-git-send-email-kaber@trash.net>
References: <1288822372-21245-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58659 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab0KCWNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 18:13:01 -0400
In-Reply-To: <1288822372-21245-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

net/ipv4/netfilter/nf_nat_core.c:52: warning: 'nf_nat_proto_find_get' defined but not used
net/ipv4/netfilter/nf_nat_core.c:66: warning: 'nf_nat_proto_put' defined but not used

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c |   40 +++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 295c974..c04787c 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -47,26 +47,6 @@ __nf_nat_proto_find(u_int8_t protonum)
 	return rcu_dereference(nf_nat_protos[protonum]);
 }
 
-static const struct nf_nat_protocol *
-nf_nat_proto_find_get(u_int8_t protonum)
-{
-	const struct nf_nat_protocol *p;
-
-	rcu_read_lock();
-	p = __nf_nat_proto_find(protonum);
-	if (!try_module_get(p->me))
-		p = &nf_nat_unknown_protocol;
-	rcu_read_unlock();
-
-	return p;
-}
-
-static void
-nf_nat_proto_put(const struct nf_nat_protocol *p)
-{
-	module_put(p->me);
-}
-
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
 hash_by_src(const struct net *net, u16 zone,
@@ -588,6 +568,26 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
 
+static const struct nf_nat_protocol *
+nf_nat_proto_find_get(u_int8_t protonum)
+{
+	const struct nf_nat_protocol *p;
+
+	rcu_read_lock();
+	p = __nf_nat_proto_find(protonum);
+	if (!try_module_get(p->me))
+		p = &nf_nat_unknown_protocol;
+	rcu_read_unlock();
+
+	return p;
+}
+
+static void
+nf_nat_proto_put(const struct nf_nat_protocol *p)
+{
+	module_put(p->me);
+}
+
 static const struct nla_policy protonat_nla_policy[CTA_PROTONAT_MAX+1] = {
 	[CTA_PROTONAT_PORT_MIN]	= { .type = NLA_U16 },
 	[CTA_PROTONAT_PORT_MAX]	= { .type = NLA_U16 },
-- 
1.7.1

