From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/15] netfilter: xt_TEE: get rid of WITH_CONNTRACK definition
Date: Wed, 19 Aug 2015 21:18:18 +0200
Message-ID: <1440011911-4359-3-git-send-email-pablo@netfilter.org>
References: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44882 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574AbbHSTMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 15:12:34 -0400
In-Reply-To: <1440011911-4359-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use IS_ENABLED(CONFIG_NF_CONNTRACK) instead.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TEE.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index c5d6556..0ed9fb6 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -24,10 +24,8 @@
 #include <net/route.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_TEE.h>
-
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
-#	define WITH_CONNTRACK 1
-#	include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack.h>
 #endif
 
 struct xt_tee_priv {
@@ -99,7 +97,7 @@ tee_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	if (skb == NULL)
 		return XT_CONTINUE;
 
-#ifdef WITH_CONNTRACK
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	/* Avoid counting cloned packets towards the original connection. */
 	nf_conntrack_put(skb->nfct);
 	skb->nfct     = &nf_ct_untracked_get()->ct_general;
@@ -175,7 +173,7 @@ tee_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	if (skb == NULL)
 		return XT_CONTINUE;
 
-#ifdef WITH_CONNTRACK
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 	skb->nfct     = &nf_ct_untracked_get()->ct_general;
 	skb->nfctinfo = IP_CT_NEW;
-- 
1.7.10.4
