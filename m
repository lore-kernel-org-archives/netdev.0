From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: define NF_CT_EXT_* as needed
Date: Mon, 15 Nov 2010 17:25:49 +0800
Message-ID: <1289813149-22897-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:64149 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754499Ab0KOJ0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 04:26:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/netfilter/nf_conntrack_ecache.h |    8 ++++++++
 include/net/netfilter/nf_conntrack_extend.h |    6 ++++++
 include/net/netfilter/nf_nat.h              |    4 ++++
 3 files changed, 18 insertions(+)
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
