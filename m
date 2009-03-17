From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] kfree(napi->skb) => kfree_skb
Date: Tue, 17 Mar 2009 11:38:25 +0100
Message-ID: <49BF7DA1.6010805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:23842 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbZCQKi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 06:38:28 -0400
Received: by nf-out-0910.google.com with SMTP id d21so1040930nfb.21
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 03:38:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

struct sk_buff pointers should be freed with kfree_skb.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
@@ -2669,11 +2669,11 @@ EXPORT_SYMBOL(netif_napi_add);
 void netif_napi_del(struct napi_struct *napi)
 {
 	struct sk_buff *skb, *next;
 
 	list_del_init(&napi->dev_list);
-	kfree(napi->skb);
+	kfree_skb(napi->skb);
 
 	for (skb = napi->gro_list; skb; skb = next) {
 		next = skb->next;
 		skb->next = NULL;
 		kfree_skb(skb);

