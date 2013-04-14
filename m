From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] esp4: fix error return code in esp_output()
Date: Sun, 14 Apr 2013 09:49:03 +0800
Message-ID: <CAPgLHd9zivXBfC5DvuKwr+C3vX+-kJjqSrLRRyAvk=nmBvGaaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:45973 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161Ab3DNBtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Apr 2013 21:49:05 -0400
Received: by mail-bk0-f50.google.com with SMTP id jg1so1847921bkc.9
        for <netdev@vger.kernel.org>; Sat, 13 Apr 2013 18:49:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return a negative error code from the error handling
case instead of 0, as returned elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/ipv4/esp4.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 3b4f0cd..4cfe34d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -139,8 +139,6 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* skb is pure payload to encrypt */
 
-	err = -ENOMEM;
-
 	esp = x->data;
 	aead = esp->aead;
 	alen = crypto_aead_authsize(aead);
@@ -176,8 +174,10 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	}
 
 	tmp = esp_alloc_tmp(aead, nfrags + sglists, seqhilen);
-	if (!tmp)
+	if (!tmp) {
+		err = -ENOMEM;
 		goto error;
+	}
 
 	seqhi = esp_tmp_seqhi(tmp);
 	iv = esp_tmp_iv(aead, tmp, seqhilen);
