From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net 3/3] macsec: fix SA initialization
Date: Tue, 14 Jun 2016 15:25:16 +0200
Message-ID: <e90e4c9e1a71e7168ed9e9ff041d0340b920ca91.1465908271.git.sd@queasysnail.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751362AbcFNNZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 09:25:26 -0400
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
In-Reply-To: <cover.1465908271.git.sd@queasysnail.net>
References: <cover.1465908271.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ASYNC flag prevents initialization on some physical machines.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 189ea3e8e8a0..0e7eff7f1cd2 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -1262,7 +1262,7 @@ static struct crypto_aead *macsec_alloc_tfm(char *key, int key_len, int icv_len)
 	struct crypto_aead *tfm;
 	int ret;
 
-	tfm = crypto_alloc_aead("gcm(aes)", 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_aead("gcm(aes)", 0, 0);
 	if (!tfm || IS_ERR(tfm))
 		return NULL;
 
-- 
2.8.3
