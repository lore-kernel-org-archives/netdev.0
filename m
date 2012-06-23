From: pablo@netfilter.org
Subject: [PATCH 1/4] netfilter: nfq_ct_hook needs __rcu and __read_mostly
Date: Sun, 24 Jun 2012 01:53:26 +0200
Message-ID: <1340495609-26250-2-git-send-email-pablo@netfilter.org>
References: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39295 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756237Ab2FWXyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2012 19:54:38 -0400
In-Reply-To: <1340495609-26250-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This removes some sparse warnings.

Reported-by: Fengguang Wu <wfg@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter.h |    2 +-
 net/netfilter/core.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index dca19e6..38b96a5 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -404,7 +404,7 @@ struct nfq_ct_hook {
 	void (*seq_adjust)(struct sk_buff *skb, struct nf_conn *ct,
 			   u32 ctinfo, int off);
 };
-extern struct nfq_ct_hook *nfq_ct_hook;
+extern struct nfq_ct_hook __rcu *nfq_ct_hook;
 #else
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index 7eef845..4cd10ed 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -265,7 +265,7 @@ void nf_conntrack_destroy(struct nf_conntrack *nfct)
 }
 EXPORT_SYMBOL(nf_conntrack_destroy);
 
-struct nfq_ct_hook *nfq_ct_hook;
+struct nfq_ct_hook __rcu *nfq_ct_hook __read_mostly;
 EXPORT_SYMBOL_GPL(nfq_ct_hook);
 
 #endif /* CONFIG_NF_CONNTRACK */
-- 
1.7.10
