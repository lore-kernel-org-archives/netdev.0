From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/6] xfrm: Delete hold_timer when destroy policy
Date: Thu, 22 Aug 2013 13:12:07 +0200
Message-ID: <1377169931-7302-4-git-send-email-steffen.klassert@secunet.com>
References: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51108 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab3HVLMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:12:35 -0400
In-Reply-To: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

Both policy timer and hold_timer need to be deleted when destroy policy

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index d8da6b8..f7078eb 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -308,7 +308,7 @@ void xfrm_policy_destroy(struct xfrm_policy *policy)
 {
 	BUG_ON(!policy->walk.dead);
 
-	if (del_timer(&policy->timer))
+	if (del_timer(&policy->timer) || del_timer(&policy->polq.hold_timer))
 		BUG();
 
 	security_xfrm_policy_free(policy->security);
-- 
1.7.9.5
