From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 15/16] esp6: fix incorrect null pointer check on xo
Date: Thu, 20 Apr 2017 10:55:14 +0200
Message-ID: <1492678515-14347-16-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51660 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970101AbdDTI5r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:57:47 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The check for xo being null is incorrect, currently it is checking
for non-null, it should be checking for null.

Detected with CoverityScan, CID#1429349 ("Dereference after null check")

Fixes: 7862b4058b9f ("esp: Add gso handlers for esp4 and esp6")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index 1cceeee..95f10728 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -120,7 +120,7 @@ static struct sk_buff *esp6_gso_segment(struct sk_buff *skb,
 	netdev_features_t esp_features = features;
 	struct xfrm_offload *xo = xfrm_offload(skb);
 
-	if (xo)
+	if (!xo)
 		goto out;
 
 	seq = xo->seq.low;
-- 
2.7.4
