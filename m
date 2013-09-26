From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: announce deleation of temporary SA
Date: Thu, 26 Sep 2013 10:58:42 +0200
Message-ID: <1380185923-8976-2-git-send-email-steffen.klassert@secunet.com>
References: <1380185923-8976-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34317 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013Ab3IZI7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 04:59:12 -0400
In-Reply-To: <1380185923-8976-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Creation of temporary SA are announced by netlink, but there is no notification
for the deletion.
This patch fix this asymmetric situation.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 4f8ace8..3fd65b7 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -471,7 +471,7 @@ expired:
 	}
 
 	err = __xfrm_state_delete(x);
-	if (!err && x->id.spi)
+	if (!err)
 		km_state_expired(x, 1, 0);
 
 	xfrm_audit_state_delete(x, err ? 0 : 1,
-- 
1.7.9.5
