From: weiyj_lk@163.com
Subject: [PATCH] mac802154: llsec: fix return value check in llsec_key_alloc()
Date: Thu, 16 Apr 2015 20:16:34 +0800
Message-ID: <1429186594-20372-1-git-send-email-weiyj_lk@163.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:53937 "EHLO m12-14.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757357AbbDPMRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 08:17:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

In case of error, the functions crypto_alloc_aead() and crypto_alloc_blkcipher()
returns ERR_PTR() and never returns NULL. The NULL test in the return value check
should be replaced with IS_ERR().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/mac802154/llsec.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac802154/llsec.c b/net/mac802154/llsec.c
index dcf7395..5b2be12 100644
--- a/net/mac802154/llsec.c
+++ b/net/mac802154/llsec.c
@@ -134,7 +134,7 @@ llsec_key_alloc(const struct ieee802154_llsec_key *template)
 	for (i = 0; i < ARRAY_SIZE(key->tfm); i++) {
 		key->tfm[i] = crypto_alloc_aead("ccm(aes)", 0,
 						CRYPTO_ALG_ASYNC);
-		if (!key->tfm[i])
+		if (IS_ERR(key->tfm[i]))
 			goto err_tfm;
 		if (crypto_aead_setkey(key->tfm[i], template->key,
 				       IEEE802154_LLSEC_KEY_SIZE))
@@ -144,7 +144,7 @@ llsec_key_alloc(const struct ieee802154_llsec_key *template)
 	}
 
 	key->tfm0 = crypto_alloc_blkcipher("ctr(aes)", 0, CRYPTO_ALG_ASYNC);
-	if (!key->tfm0)
+	if (IS_ERR(key->tfm0))
 		goto err_tfm;
 
 	if (crypto_blkcipher_setkey(key->tfm0, template->key,
