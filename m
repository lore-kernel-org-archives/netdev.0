From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macsec: fix memory leaks when skb_to_sgvec fails
Date: Tue, 10 Oct 2017 17:07:12 +0200
Message-ID: <5d21bccd731e3c54f2216fcf3b12cd40ba708f7b.1507639962.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>,
        "Jason A . Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34736 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756116AbdJJPH3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 11:07:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: cda7ea690350 ("macsec: check return value of skb_to_sgvec always")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/macsec.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 98e4deaa3a6a..5ab1b8849c30 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -742,6 +742,7 @@ static struct sk_buff *macsec_encrypt(struct sk_buff *skb,
 	sg_init_table(sg, ret);
 	ret = skb_to_sgvec(skb, sg, 0, skb->len);
 	if (unlikely(ret < 0)) {
+		aead_request_free(req);
 		macsec_txsa_put(tx_sa);
 		kfree_skb(skb);
 		return ERR_PTR(ret);
@@ -954,6 +955,7 @@ static struct sk_buff *macsec_decrypt(struct sk_buff *skb,
 	sg_init_table(sg, ret);
 	ret = skb_to_sgvec(skb, sg, 0, skb->len);
 	if (unlikely(ret < 0)) {
+		aead_request_free(req);
 		kfree_skb(skb);
 		return ERR_PTR(ret);
 	}
-- 
2.14.2
