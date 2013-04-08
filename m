From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: [PATCH 2/2] xfrm: add rfc4494 AES-CMAC-96 support
Date: Mon, 08 Apr 2013 10:48:49 +0300
Message-ID: <20130408074849.6866.85578.stgit@localhost6.localdomain6>
References: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, Tom St Denis <tstdenis@elliptictech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:56465 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934342Ab3DHHsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 03:48:52 -0400
In-Reply-To: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that CryptoAPI has support for CMAC, we can add support for AES-CMAC-96
(rfc4494).

Cc: Tom St Denis <tstdenis@elliptictech.com>
Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
---
 net/xfrm/xfrm_algo.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index 6fb9d00..ab4ef72 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -311,6 +311,19 @@ static struct xfrm_algo_desc aalg_list[] = {
 		.sadb_alg_maxbits = 128
 	}
 },
+{
+	/* rfc4494 */
+	.name = "cmac(aes)",
+
+	.uinfo = {
+		.auth = {
+			.icv_truncbits = 96,
+			.icv_fullbits = 128,
+		}
+	},
+
+	.pfkey_supported = 0,
+},
 };
 
 static struct xfrm_algo_desc ealg_list[] = {
