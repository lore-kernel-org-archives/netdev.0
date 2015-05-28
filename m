From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/7] xfrm: remove the xfrm_queue_purge definition
Date: Thu, 28 May 2015 08:25:48 +0200
Message-ID: <1432794354-19391-2-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49912 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750886AbbE1G0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:10 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The task of xfrm_queue_purge is same as skb_queue_purge, so remove it

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1
