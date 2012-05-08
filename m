From: pablo@netfilter.org
Subject: [PATCH 01/25] netfilter: nf_ct_ecache: refactor notifier registration
Date: Tue,  8 May 2012 02:21:55 +0200
Message-ID: <1336436539-5880-2-git-send-email-pablo@netfilter.org>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51710 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757921Ab2EHAWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 20:22:47 -0400
In-Reply-To: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Zelenoff <antonz@parallels.com>

* ret variable initialization removed as useless
* similar code strings concatenated and functions code
  flow became more plain

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_ecache.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index 5bd3047d..3a3409f 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -84,7 +84,7 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 int nf_conntrack_register_notifier(struct net *net,
 				   struct nf_ct_event_notifier *new)
 {
-	int ret = 0;
+	int ret;
 	struct nf_ct_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
@@ -95,8 +95,7 @@ int nf_conntrack_register_notifier(struct net *net,
 		goto out_unlock;
 	}
 	rcu_assign_pointer(net->ct.nf_conntrack_event_cb, new);
-	mutex_unlock(&nf_ct_ecache_mutex);
-	return ret;
+	ret = 0;
 
 out_unlock:
 	mutex_unlock(&nf_ct_ecache_mutex);
@@ -121,7 +120,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
 int nf_ct_expect_register_notifier(struct net *net,
 				   struct nf_exp_event_notifier *new)
 {
-	int ret = 0;
+	int ret;
 	struct nf_exp_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
@@ -132,8 +131,7 @@ int nf_ct_expect_register_notifier(struct net *net,
 		goto out_unlock;
 	}
 	rcu_assign_pointer(net->ct.nf_expect_event_cb, new);
-	mutex_unlock(&nf_ct_ecache_mutex);
-	return ret;
+	ret = 0;
 
 out_unlock:
 	mutex_unlock(&nf_ct_ecache_mutex);
-- 
1.7.9.5
