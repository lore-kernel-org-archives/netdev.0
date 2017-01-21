From: Ryder Lee <ryder.lee@mediatek.com>
Subject: [RESEND PATCH net] macsec: fix validation failed in asynchronous operation.
Date: Sat, 21 Jan 2017 16:42:07 +0800
Message-ID: <1484988127-25860-1-git-send-email-ryder.lee@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sabrina Dubroca <sd@queasysnail.net>,
        <linux-mediatek@lists.infradead.org>,
        Ryder Lee <ryder.lee@mediatek.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:13311 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750800AbdAUImQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 03:42:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing "macsec_skb_cb(skb)->valid = true" in callback
function macsec_decrypt_done(), this fixes packet validation
failed while decrypting asynchronously.

Signed-off-by: Ryder Lee <ryder.lee@mediatek.com>
---
 drivers/net/macsec.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index f83cf66..73d8d39 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -880,6 +880,9 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 	aead_request_free(macsec_skb_cb(skb)->req);
 
 	rcu_read_lock_bh();
+	if (err == 0)
+		macsec_skb_cb(skb)->valid = true;
+
 	pn = ntohl(macsec_ethhdr(skb)->packet_number);
 	if (!macsec_post_decrypt(skb, &macsec->secy, pn)) {
 		rcu_read_unlock_bh();
-- 
1.9.1
