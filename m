From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/19] netfilter: nf_conntrack: constify sk_buff argument to nf_ct_attach()
Date: Tue, 20 Aug 2013 12:54:35 +0200
Message-ID: <1376996091-3964-4-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60064 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab3HTKzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:06 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h         |    4 ++--
 net/netfilter/core.c              |    7 ++++---
 net/netfilter/nf_conntrack_core.c |    2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index de70f7b..f4bbf2c 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -314,8 +314,8 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 #endif /*CONFIG_NETFILTER*/
 
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-extern void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *) __rcu;
-extern void nf_ct_attach(struct sk_buff *, struct sk_buff *);
+extern void (*ip_ct_attach)(struct sk_buff *, const struct sk_buff *) __rcu;
+extern void nf_ct_attach(struct sk_buff *, const struct sk_buff *);
 extern void (*nf_ct_destroy)(struct nf_conntrack *) __rcu;
 
 struct nf_conn;
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 2217363..593b16e 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -234,12 +234,13 @@ EXPORT_SYMBOL(skb_make_writable);
 /* This does not belong here, but locally generated errors need it if connection
    tracking in use: without this, connection may not be in hash table, and hence
    manufactured ICMP or RST packets will not be associated with it. */
-void (*ip_ct_attach)(struct sk_buff *, struct sk_buff *) __rcu __read_mostly;
+void (*ip_ct_attach)(struct sk_buff *, const struct sk_buff *)
+		__rcu __read_mostly;
 EXPORT_SYMBOL(ip_ct_attach);
 
-void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb)
+void nf_ct_attach(struct sk_buff *new, const struct sk_buff *skb)
 {
-	void (*attach)(struct sk_buff *, struct sk_buff *);
+	void (*attach)(struct sk_buff *, const struct sk_buff *);
 
 	if (skb->nfct) {
 		rcu_read_lock();
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0283bae..d32afaf 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1192,7 +1192,7 @@ EXPORT_SYMBOL_GPL(nf_ct_port_nlattr_tuple_size);
 #endif
 
 /* Used by ipt_REJECT and ip6t_REJECT. */
-static void nf_conntrack_attach(struct sk_buff *nskb, struct sk_buff *skb)
+static void nf_conntrack_attach(struct sk_buff *nskb, const struct sk_buff *skb)
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
-- 
1.7.10.4
