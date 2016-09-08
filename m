From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 16/17] xfrm: Fix xfrm_policy_lock imbalance
Date: Thu, 8 Sep 2016 07:54:51 +0200
Message-ID: <1473314092-11319-17-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36351 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756465AbcIHGv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:27 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An earlier patch accidentally replaced a write_lock_bh
with a spin_unlock_bh. Fix this by using spin_lock_bh
instead.

Fixes: 9d0380df6217 ("xfrm: policy: convert policy_lock to spinlock")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index dd01fd2..f7ce626 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -979,7 +979,7 @@ int xfrm_policy_flush(struct net *net, u8 type, bool task_valid)
 
 			xfrm_policy_kill(pol);
 
-			spin_unlock_bh(&net->xfrm.xfrm_policy_lock);
+			spin_lock_bh(&net->xfrm.xfrm_policy_lock);
 			goto again1;
 		}
 
-- 
1.9.1
