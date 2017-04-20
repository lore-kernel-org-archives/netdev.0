From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/16] esp6: Remame esp_input_done2
Date: Thu, 20 Apr 2017 10:55:05 +0200
Message-ID: <1492678515-14347-7-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51598 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943309AbdDTI4w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:56:52 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are going to export the ipv4 and the ipv6
version of esp_input_done2. They are not static
anymore and can't have the same name. So rename
the ipv6 version to esp6_input_done2.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 3d3757d..5bd1dcc 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -447,7 +447,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	return err;
 }
 
-static int esp_input_done2(struct sk_buff *skb, int err)
+static int esp6_input_done2(struct sk_buff *skb, int err)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct xfrm_offload *xo = xfrm_offload(skb);
@@ -499,7 +499,7 @@ static void esp_input_done(struct crypto_async_request *base, int err)
 {
 	struct sk_buff *skb = base->data;
 
-	xfrm_input_resume(skb, esp_input_done2(skb, err));
+	xfrm_input_resume(skb, esp6_input_done2(skb, err));
 }
 
 static void esp_input_restore_header(struct sk_buff *skb)
@@ -621,7 +621,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	if ((x->props.flags & XFRM_STATE_ESN))
 		esp_input_restore_header(skb);
 
-	ret = esp_input_done2(skb, ret);
+	ret = esp6_input_done2(skb, ret);
 
 out:
 	return ret;
-- 
2.7.4
