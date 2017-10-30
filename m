From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/8] esp6: remove redundant initialization of esph
Date: Mon, 30 Oct 2017 09:39:33 +0100
Message-ID: <1509352775-9563-7-git-send-email-steffen.klassert@secunet.com>
References: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41270 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752530AbdJ3Ijo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 04:39:44 -0400
In-Reply-To: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The pointer esph is being initialized with a value that is never
read and then being updated.  Remove the redundant initialization
and move the declaration and initializtion of esph to the local
code block.

Cleans up clang warning:
net/ipv6/esp6.c:562:21: warning: Value stored to 'esph' during its
initialization is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 89910e2..1696401 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -559,14 +559,14 @@ static void esp_input_restore_header(struct sk_buff *skb)
 static void esp_input_set_header(struct sk_buff *skb, __be32 *seqhi)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
-	struct ip_esp_hdr *esph = (struct ip_esp_hdr *)skb->data;
 
 	/* For ESN we move the header forward by 4 bytes to
 	 * accomodate the high bits.  We will move it back after
 	 * decryption.
 	 */
 	if ((x->props.flags & XFRM_STATE_ESN)) {
-		esph = skb_push(skb, 4);
+		struct ip_esp_hdr *esph = skb_push(skb, 4);
+
 		*seqhi = esph->spi;
 		esph->spi = esph->seq_no;
 		esph->seq_no = XFRM_SKB_CB(skb)->seq.input.hi;
-- 
2.7.4
