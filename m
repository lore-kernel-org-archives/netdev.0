From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/12] netfilter: ipset: remove unused code
Date: Mon,  6 Jan 2014 00:13:01 +0100
Message-ID: <1388963586-5049-8-git-send-email-pablo@netfilter.org>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56243 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbaAEXNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Jan 2014 18:13:25 -0500
In-Reply-To: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <stephen@networkplumber.org>

Function never used in current upstream code.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h |    1 -
 net/netfilter/ipset/ip_set_core.c      |   28 ----------------------------
 2 files changed, 29 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index c7174b8..0c7d01e 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -331,7 +331,6 @@ extern ip_set_id_t ip_set_get_byname(struct net *net,
 				     const char *name, struct ip_set **set);
 extern void ip_set_put_byindex(struct net *net, ip_set_id_t index);
 extern const char *ip_set_name_byindex(struct net *net, ip_set_id_t index);
-extern ip_set_id_t ip_set_nfnl_get(struct net *net, const char *name);
 extern ip_set_id_t ip_set_nfnl_get_byindex(struct net *net, ip_set_id_t index);
 extern void ip_set_nfnl_put(struct net *net, ip_set_id_t index);
 
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index bac7e01..de770ec 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -625,34 +625,6 @@ EXPORT_SYMBOL_GPL(ip_set_name_byindex);
  */
 
 /*
- * Find set by name, reference it once. The reference makes sure the
- * thing pointed to, does not go away under our feet.
- *
- * The nfnl mutex is used in the function.
- */
-ip_set_id_t
-ip_set_nfnl_get(struct net *net, const char *name)
-{
-	ip_set_id_t i, index = IPSET_INVALID_ID;
-	struct ip_set *s;
-	struct ip_set_net *inst = ip_set_pernet(net);
-
-	nfnl_lock(NFNL_SUBSYS_IPSET);
-	for (i = 0; i < inst->ip_set_max; i++) {
-		s = nfnl_set(inst, i);
-		if (s != NULL && STREQ(s->name, name)) {
-			__ip_set_get(s);
-			index = i;
-			break;
-		}
-	}
-	nfnl_unlock(NFNL_SUBSYS_IPSET);
-
-	return index;
-}
-EXPORT_SYMBOL_GPL(ip_set_nfnl_get);
-
-/*
  * Find set by index, reference it once. The reference makes sure the
  * thing pointed to, does not go away under our feet.
  *
-- 
1.7.10.4
