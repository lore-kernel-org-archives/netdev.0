From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] lwtunnel: Make lwtun_encaps[] static
Date: Wed, 29 Jul 2015 09:45:40 +0200
Message-ID: <66e6473d98879c465cf4965d44230374c716ed25.1438155918.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34344 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907AbbG2H6w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 03:58:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any external user should use the registration API instead of
accessing this directly.

Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/lwtunnel.h | 3 ---
 net/core/lwtunnel.c    | 2 +-
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index b020390..33bd309 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -31,9 +31,6 @@ struct lwtunnel_encap_ops {
 	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
 };
 
-extern const struct lwtunnel_encap_ops __rcu *
-		lwtun_encaps[LWTUNNEL_ENCAP_MAX+1];
-
 #ifdef CONFIG_LWTUNNEL
 static inline struct lwtunnel_state *
 lwtstate_get(struct lwtunnel_state *lws)
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 5f7fae7..c240c89 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -37,7 +37,7 @@ struct lwtunnel_state *lwtunnel_state_alloc(int encap_len)
 }
 EXPORT_SYMBOL(lwtunnel_state_alloc);
 
-const struct lwtunnel_encap_ops __rcu *
+static const struct lwtunnel_encap_ops __rcu *
 		lwtun_encaps[LWTUNNEL_ENCAP_MAX + 1] __read_mostly;
 
 int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *ops,
-- 
2.4.3
