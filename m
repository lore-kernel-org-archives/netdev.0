From: roy.qing.li@gmail.com
Subject: [PATCH] xfrm: remove the xfrm_queue_purge definition
Date: Wed, 22 Apr 2015 15:51:16 +0800
Message-ID: <1429689076-10684-1-git-send-email-roy.qing.li@gmail.com>
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:38660 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965418AbbDVHv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:51:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The task of xfrm_queue_purge is same as skb_queue_purge, so remove it

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/xfrm/xfrm_policy.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 638af06..d8c35ad 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -315,14 +315,6 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 }
 EXPORT_SYMBOL(xfrm_policy_destroy);
 
-static void xfrm_queue_purge(struct sk_buff_head *list)
-{
-	struct sk_buff *skb;
-
-	while ((skb = skb_dequeue(list)) != NULL)
-		kfree_skb(skb);
-}
-
 /* Rule must be locked. Release descentant resources, announce
  * entry dead. The rule must be unlinked from lists to the moment.
  */
@@ -335,7 +327,7 @@ static void xfrm_policy_kill(struct xfrm_policy *policy)
 
 	if (del_timer(&policy->polq.hold_timer))
 		xfrm_pol_put(policy);
-	xfrm_queue_purge(&policy->polq.hold_queue);
+	skb_queue_purge(&policy->polq.hold_queue);
 
 	if (del_timer(&policy->timer))
 		xfrm_pol_put(policy);
@@ -1955,7 +1947,7 @@ out:
 
 purge_queue:
 	pq->timeout = 0;
-	xfrm_queue_purge(&pq->hold_queue);
+	skb_queue_purge(&pq->hold_queue);
 	xfrm_pol_put(pol);
 }
 
-- 
2.1.0
