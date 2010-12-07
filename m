From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] xfrm: Fix xfrm_state_migrate leak
Date: Tue, 7 Dec 2010 10:28:56 +0100
Message-ID: <20101207092856.GL4639@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Egerer <thomas.egerer@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51369 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754985Ab0LGJ26 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Dec 2010 04:28:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Egerer <thomas.egerer@secunet.com>

xfrm_state_migrate calls kfree instead of xfrm_state_put to free
a failed state. According to git commit 553f9118 this can cause
memory leaks.

Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index eb96ce5..220ebc0 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1268,7 +1268,7 @@ struct xfrm_state * xfrm_state_migrate(struct xfrm_state *x,
 
 	return xc;
 error:
-	kfree(xc);
+	xfrm_state_put(xc);
 	return NULL;
 }
 EXPORT_SYMBOL(xfrm_state_migrate);
-- 
1.7.0.4

