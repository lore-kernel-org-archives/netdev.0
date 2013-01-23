From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/8] xfrm_algo: probe asynchronous block ciphers instead of synchronous
Date: Wed, 23 Jan 2013 09:18:58 +0100
Message-ID: <1358929144-17806-3-git-send-email-steffen.klassert@secunet.com>
References: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50720 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754098Ab3AWIT2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 03:19:28 -0500
In-Reply-To: <1358929144-17806-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

IPSEC uses block ciphers asynchronous, but probes only for synchronous block
ciphers and makes ealg entries only available if synchronous block cipher is
found. So with setup, where hardware crypto driver registers asynchronous
block ciphers and software crypto module is not build, ealg is not marked
as being available.

Use crypto_has_ablkcipher instead and remove ASYNC mask.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_algo.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 4ce2d93..f9a5495 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -700,8 +700,7 @@ void xfrm_probe_algs(void)
 	}
 
 	for (i = 0; i < ealg_entries(); i++) {
-		status = crypto_has_blkcipher(ealg_list[i].name, 0,
-					      CRYPTO_ALG_ASYNC);
+		status = crypto_has_ablkcipher(ealg_list[i].name, 0, 0);
 		if (ealg_list[i].available != status)
 			ealg_list[i].available = status;
 	}
-- 
1.7.9.5
