From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/7] xfrm: remove the unnecessary checking before call xfrm_pol_hold
Date: Thu, 28 May 2015 08:25:52 +0200
Message-ID: <1432794354-19391-6-git-send-email-steffen.klassert@secunet.com>
References: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50011 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbbE1G00 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 02:26:26 -0400
In-Reply-To: <1432794354-19391-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

xfrm_pol_hold will check its input with NULL

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_policy.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index c4c47f3..435bc0d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1127,8 +1127,8 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 			break;
 		}
 	}
-	if (ret)
-		xfrm_pol_hold(ret);
+
+	xfrm_pol_hold(ret);
 fail:
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
@@ -3211,8 +3211,7 @@ static struct xfrm_policy *xfrm_migrate_policy_find(const struct xfrm_selector *
 		}
 	}
 
-	if (ret)
-		xfrm_pol_hold(ret);
+	xfrm_pol_hold(ret);
 
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
 
-- 
1.9.1
