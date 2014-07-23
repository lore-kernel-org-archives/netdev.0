From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm: Fix installation of AH IPsec SAs
Date: Wed, 23 Jul 2014 10:18:07 +0200
Message-ID: <1406103487-1656-3-git-send-email-steffen.klassert@secunet.com>
References: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39813 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347AbaGWISW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 04:18:22 -0400
In-Reply-To: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Brunner <tobias@strongswan.org>

The SPI check introduced in ea9884b3acf3311c8a11db67bfab21773f6f82ba
was intended for IPComp SAs but actually prevented AH SAs from getting
installed (depending on the SPI).

Fixes: ea9884b3acf3 ("xfrm: check user specified spi for IPComp")
Cc: Fan Du <fan.du@windriver.com>
Signed-off-by: Tobias Brunner <tobias@strongswan.org>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 412d9dc..d4db6eb 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -177,9 +177,7 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_AEAD]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
 		    attrs[XFRMA_ALG_COMP]	||
-		    attrs[XFRMA_TFCPAD]		||
-		    (ntohl(p->id.spi) >= 0x10000))
-
+		    attrs[XFRMA_TFCPAD])
 			goto out;
 		break;
 
@@ -207,7 +205,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 		    attrs[XFRMA_ALG_AUTH]	||
 		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
 		    attrs[XFRMA_ALG_CRYPT]	||
-		    attrs[XFRMA_TFCPAD])
+		    attrs[XFRMA_TFCPAD]		||
+		    (ntohl(p->id.spi) >= 0x10000))
 			goto out;
 		break;
 
-- 
1.9.1
