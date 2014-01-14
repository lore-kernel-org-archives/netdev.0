From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 3/4] flowcache: Fixup flow cache part in xfrm policy
Date: Tue, 14 Jan 2014 09:39:46 +0800
Message-ID: <1389663588-29678-4-git-send-email-fan.du@windriver.com>
References: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:64689 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753239AbaANBjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 20:39:46 -0500
In-Reply-To: <1389663588-29678-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump flow cache genid, and flush flow cache should also be made
in per net style.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/xfrm/xfrm_policy.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index e205c4b..d39c90f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -661,7 +661,7 @@ int xfrm_policy_insert(int dir, struct xfrm_policy *policy, int excl)
 		hlist_add_head(&policy->bydst, chain);
 	xfrm_pol_hold(policy);
 	net->xfrm.policy_count[dir]++;
-	atomic_inc(&flow_cache_genid);
+	atomic_inc(&net->xfrm.flow_cache_genid);
 
 	/* After previous checking, family can either be AF_INET or AF_INET6 */
 	if (policy->family == AF_INET)
@@ -2567,14 +2567,14 @@ static void __xfrm_garbage_collect(struct net *net)
 
 void xfrm_garbage_collect(struct net *net)
 {
-	flow_cache_flush();
+	flow_cache_flush(net);
 	__xfrm_garbage_collect(net);
 }
 EXPORT_SYMBOL(xfrm_garbage_collect);
 
 static void xfrm_garbage_collect_deferred(struct net *net)
 {
-	flow_cache_flush_deferred();
+	flow_cache_flush_deferred(net);
 	__xfrm_garbage_collect(net);
 }
 
@@ -2947,6 +2947,7 @@ static int __net_init xfrm_net_init(struct net *net)
 	spin_lock_init(&net->xfrm.xfrm_policy_sk_bundle_lock);
 	mutex_init(&net->xfrm.xfrm_cfg_mutex);
 
+	flow_cache_init(net);
 	return 0;
 
 out_sysctl:
-- 
1.7.9.5
