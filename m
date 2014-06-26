From: Tobias Brunner <tobias@strongswan.org>
Subject: [PATCH ipsec] xfrm: Fix installation of AH IPsec SAs
Date: Thu, 26 Jun 2014 15:12:45 +0200
Message-ID: <53AC1C4D.3080305@strongswan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Fan Du <fan.du@windriver.com>,
	Andreas Steffen <andreas.steffen@strongswan.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sifsv-80046.hsr.ch ([152.96.80.46]:40913 "EHLO
	mail.strongswan.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaFZNUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 09:20:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SPI check introduced in ea9884b3acf3311c8a11db67bfab21773f6f82ba
was intended for IPComp SAs but actually prevented AH SAs from getting
installed (depending on the SPI).

Fixes: ea9884b3acf3 ("xfrm: check user specified spi for IPComp")
Cc: Fan Du <fan.du@windriver.com>
Signed-off-by: Tobias Brunner <tobias@strongswan.org>
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
