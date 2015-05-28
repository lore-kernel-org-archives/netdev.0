From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/7] xfrm: fix a race in xfrm_state_lookup_byspi
Date: Thu, 28 May 2015 09:28:04 +0200
Message-ID: <1432798090-20657-2-git-send-email-steffen.klassert@secunet.com>
References: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51215 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbbE1H23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 03:28:29 -0400
In-Reply-To: <1432798090-20657-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

The returned xfrm_state should be hold before unlock xfrm_state_lock,
otherwise the returned xfrm_state maybe be released.

Fixes: c454997e6[{pktgen, xfrm} Introduce xfrm_state_lookup_byspi..]
Cc: Fan Du <fan.du@intel.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Acked-by: Fan Du <fan.du@intel.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index f5e39e3..96688cd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -927,8 +927,8 @@ struct xfrm_state *xfrm_state_lookup_byspi(struct net *net, __be32 spi,
 			x->id.spi != spi)
 			continue;
 
-		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 		xfrm_state_hold(x);
+		spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 		return x;
 	}
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
-- 
1.9.1
