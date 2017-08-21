From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] esp: Fix error handling on layer 2 xmit.
Date: Mon, 21 Aug 2017 08:08:03 +0200
Message-ID: <1503295683-19153-5-git-send-email-steffen.klassert@secunet.com>
References: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35460 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751050AbdHUGIK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 02:08:10 -0400
In-Reply-To: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

esp_output_tail() and esp6_output_tail() can return negative
and positive error values. We currently treat only negative
values as errors, fix this to treat both cases as error.

Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Fixes: 383d0350f2cc ("esp6: Reorganize esp_output")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4_offload.c | 2 +-
 net/ipv6/esp6_offload.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index e066601..5011232 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -257,7 +257,7 @@ static int esp_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features_
 	esp.seqno = cpu_to_be64(xo->seq.low + ((u64)xo->seq.hi << 32));
 
 	err = esp_output_tail(x, skb, &esp);
-	if (err < 0)
+	if (err)
 		return err;
 
 	secpath_reset(skb);
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index f02f131..1cf437f 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -286,7 +286,7 @@ static int esp6_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features
 	esp.seqno = cpu_to_be64(xo->seq.low + ((u64)xo->seq.hi << 32));
 
 	err = esp6_output_tail(x, skb, &esp);
-	if (err < 0)
+	if (err)
 		return err;
 
 	secpath_reset(skb);
-- 
2.7.4
