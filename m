From: kaber@trash.net
Subject: [PATCH 07/79] netfilter: ct_extend: define NF_CT_EXT_* as needed
Date: Wed, 19 Jan 2011 20:14:07 +0100
Message-ID: <1295464519-21763-8-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51974 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab1ASTP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 14:15:26 -0500
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Less IDs make nf_ct_ext smaller.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack_ecache.h |    8 ++++++++
 include/net/netfilter/nf_conntrack_extend.h |    6 ++++++
 include/net/netfilter/nf_nat.h              |    4 ++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index 96ba5f7..f596b60 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -23,12 +23,17 @@ struct nf_conntrack_ecache {
 static inline struct nf_conntrack_ecache *
 nf_ct_ecache_find(const struct nf_conn *ct)
 {
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
 	return nf_ct_ext_find(ct, NF_CT_EXT_ECACHE);
+#else
+	return NULL;
+#endif
 }
 
 static inline struct nf_conntrack_ecache *
 nf_ct_ecache_ext_add(struct nf_conn *ct, u16 ctmask, u16 expmask, gfp_t gfp)
 {
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *e;
 
@@ -45,6 +50,9 @@ nf_ct_ecache_ext_add(struct nf_conn *ct, u16 ctmask, u16 expmask, gfp_t gfp)
 		e->expmask = expmask;
 	}
 	return e;
+#else
+	return NULL;
+#endif
 };
 
 #ifdef CONFIG_NF_CONNTRACK_EVENTS
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 0772d29..1a9f96d 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -7,10 +7,16 @@
 
 enum nf_ct_ext_id {
 	NF_CT_EXT_HELPER,
+#if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)
 	NF_CT_EXT_NAT,
+#endif
 	NF_CT_EXT_ACCT,
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
 	NF_CT_EXT_ECACHE,
+#endif
+#ifdef CONFIG_NF_CONNTRACK_ZONES
 	NF_CT_EXT_ZONE,
+#endif
 	NF_CT_EXT_NUM,
 };
 
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index f5f09f0..e966092 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -84,7 +84,11 @@ extern int nf_nat_used_tuple(const struct nf_conntrack_tuple *tuple,
 
 static inline struct nf_conn_nat *nfct_nat(const struct nf_conn *ct)
 {
+#if defined(CONFIG_NF_NAT) || defined(CONFIG_NF_NAT_MODULE)
 	return nf_ct_ext_find(ct, NF_CT_EXT_NAT);
+#else
+	return NULL;
+#endif
 }
 
 #else  /* !__KERNEL__: iptables wants this to compile. */
-- 
1.7.2.3

