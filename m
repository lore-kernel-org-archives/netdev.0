From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/12] netfilter: nf_conntrack: remove dead code
Date: Mon,  6 Jan 2014 00:13:02 +0100
Message-ID: <1388963586-5049-9-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56258 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118AbaAEXN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 18:13:29 -0500
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <stephen@networkplumber.org>

The following code is not used in current upstream code.
Some of this seems to be old hooks, other might be used by some
out of tree module (which I don't care about breaking), and
the need_ipv4_conntrack was used by old NAT code but no longer
called.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |    2 --
 include/net/netfilter/nf_conntrack_l3proto.h   |    1 -
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    6 ------
 net/netfilter/nf_conntrack_core.c              |   15 ---------------
 net/netfilter/nf_conntrack_proto.c             |    6 ------
 5 files changed, 30 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
index 6c3d12e..981c327 100644
--- a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
@@ -19,6 +19,4 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp;
 int nf_conntrack_ipv4_compat_init(void);
 void nf_conntrack_ipv4_compat_fini(void);
 
-void need_ipv4_conntrack(void);
-
 #endif /*_NF_CONNTRACK_IPV4_H*/
diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 3efab70..adc1fa3 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -87,7 +87,6 @@ int nf_ct_l3proto_register(struct nf_conntrack_l3proto *proto);
 void nf_ct_l3proto_unregister(struct nf_conntrack_l3proto *proto);
 
 struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
-void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p);
 
 /* Existing built-in protocols */
 extern struct nf_conntrack_l3proto nf_conntrack_l3proto_generic;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ecd8bec..8127dc8 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -548,9 +548,3 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 
 module_init(nf_conntrack_l3proto_ipv4_init);
 module_exit(nf_conntrack_l3proto_ipv4_fini);
-
-void need_ipv4_conntrack(void)
-{
-	return;
-}
-EXPORT_SYMBOL_GPL(need_ipv4_conntrack);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 43549eb..8824ed0 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -60,12 +60,6 @@ int (*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
 				      const struct nlattr *attr) __read_mostly;
 EXPORT_SYMBOL_GPL(nfnetlink_parse_nat_setup_hook);
 
-int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
-			      struct nf_conn *ct,
-			      enum ip_conntrack_info ctinfo,
-			      unsigned int protoff);
-EXPORT_SYMBOL_GPL(nf_nat_seq_adjust_hook);
-
 DEFINE_SPINLOCK(nf_conntrack_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
@@ -361,15 +355,6 @@ begin:
 	return NULL;
 }
 
-struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, u16 zone,
-		    const struct nf_conntrack_tuple *tuple)
-{
-	return ____nf_conntrack_find(net, zone, tuple,
-				     hash_conntrack_raw(tuple, zone));
-}
-EXPORT_SYMBOL_GPL(__nf_conntrack_find);
-
 /* Find a connection corresponding to a tuple. */
 static struct nf_conntrack_tuple_hash *
 __nf_conntrack_find_get(struct net *net, u16 zone,
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index ce30041..b65d586 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -92,12 +92,6 @@ nf_ct_l3proto_find_get(u_int16_t l3proto)
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_find_get);
 
-void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p)
-{
-	module_put(p->me);
-}
-EXPORT_SYMBOL_GPL(nf_ct_l3proto_put);
-
 int
 nf_ct_l3proto_try_module_get(unsigned short l3proto)
 {
-- 
1.7.10.4
