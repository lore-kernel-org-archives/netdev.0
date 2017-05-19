From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 9/9] ipv6: remove unused variables in esp6
Date: Fri, 19 May 2017 09:55:56 -0700
Message-ID: <20170519165556.483-10-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35034 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755362AbdESQ4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:20 -0400
Received: by mail-pg0-f49.google.com with SMTP id q125so40713657pgq.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:20 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resolves warnings:
net/ipv6/esp6.c: In function ‘esp_ssg_unref’:
net/ipv6/esp6.c:121:10: warning: variable ‘seqhi’ set but not used [-Wunused-but-set-variable]
net/ipv6/esp6.c: In function ‘esp6_output_head’:
net/ipv6/esp6.c:227:21: warning: variable ‘esph’ set but not used [-Wunused-but-set-variable]

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv6/esp6.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 1fe99ba8066c..53b6b870b935 100644
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
2.11.0
