From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 37/41: remove nf_ct_l4proto_find_get/nf_ct_l4proto_put
Date: Tue, 24 Mar 2009 15:03:56 +0100 (MET)
Message-ID: <20090324140352.31401.85646.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34804 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758490AbZCXOD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:58 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 711d60a9e7f88e394ccca10f5fc83f95f0cea5b1
Author: Florian Westphal <fw@strlen.de>
Date:   Wed Mar 18 17:30:50 2009 +0100

    netfilter: remove nf_ct_l4proto_find_get/nf_ct_l4proto_put
    
    users have been moved to __nf_ct_l4proto_find.
    
    Signed-off-by: Florian Westphal <fw@strlen.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 16ab604..b01070b 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -98,11 +98,6 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
 extern struct nf_conntrack_l4proto *
 __nf_ct_l4proto_find(u_int16_t l3proto, u_int8_t l4proto);
 
-extern struct nf_conntrack_l4proto *
-nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t protocol);
-
-extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
-
 /* Protocol registration. */
 extern int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
 extern void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 592d733..9a62b4e 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -74,27 +74,6 @@ EXPORT_SYMBOL_GPL(__nf_ct_l4proto_find);
 
 /* this is guaranteed to always return a valid protocol helper, since
  * it falls back to generic_protocol */
-struct nf_conntrack_l4proto *
-nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto)
-{
-	struct nf_conntrack_l4proto *p;
-
-	rcu_read_lock();
-	p = __nf_ct_l4proto_find(l3proto, l4proto);
-	if (!try_module_get(p->me))
-		p = &nf_conntrack_l4proto_generic;
-	rcu_read_unlock();
-
-	return p;
-}
-EXPORT_SYMBOL_GPL(nf_ct_l4proto_find_get);
-
-void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p)
-{
-	module_put(p->me);
-}
-EXPORT_SYMBOL_GPL(nf_ct_l4proto_put);
-
 struct nf_conntrack_l3proto *
 nf_ct_l3proto_find_get(u_int16_t l3proto)
 {
