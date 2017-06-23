From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/6] ipv6: remove unused variables in esp6
Date: Fri, 23 Jun 2017 10:38:28 +0200
Message-ID: <1498207110-22520-5-git-send-email-steffen.klassert@secunet.com>
References: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51126 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753598AbdFWIii (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:38:38 -0400
In-Reply-To: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>

Resolves warnings:
net/ipv6/esp6.c: In function ‘esp_ssg_unref’:
net/ipv6/esp6.c:121:10: warning: variable ‘seqhi’ set but not used [-Wunused-but-set-variable]
net/ipv6/esp6.c: In function ‘esp6_output_head’:
net/ipv6/esp6.c:227:21: warning: variable ‘esph’ set but not used [-Wunused-but-set-variable]

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 1fe99ba..53b6b87 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -118,7 +118,6 @@ static inline struct scatterlist *esp_req_sg(struct crypto_aead *aead,
 
 static void esp_ssg_unref(struct xfrm_state *x, void *tmp)
 {
-	__be32 *seqhi;
 	struct crypto_aead *aead = x->data;
 	int seqhilen = 0;
 	u8 *iv;
@@ -128,7 +127,6 @@ static void esp_ssg_unref(struct xfrm_state *x, void *tmp)
 	if (x->props.flags & XFRM_STATE_ESN)
 		seqhilen += sizeof(__be32);
 
-	seqhi = esp_tmp_seqhi(tmp);
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
 	req = esp_tmp_req(aead, iv);
 
@@ -224,12 +222,9 @@ int esp6_output_head(struct xfrm_state *x, struct sk_buff *skb, struct esp_info
 	u8 *vaddr;
 	int nfrags;
 	struct page *page;
-	struct ip_esp_hdr *esph;
 	struct sk_buff *trailer;
 	int tailen = esp->tailen;
 
-	esph = ip_esp_hdr(skb);
-
 	if (!skb_cloned(skb)) {
 		if (tailen <= skb_availroom(skb)) {
 			nfrags = 1;
-- 
2.7.4
