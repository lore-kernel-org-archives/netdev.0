From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] gro: small napi_get_frags() optim
Date: Thu, 05 Dec 2013 21:44:27 -0800
Message-ID: <1386308667.30495.230.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:50599 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3LFFo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 00:44:29 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so408826pde.7
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 21:44:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Remove one useless conditional branch : 
napi->skb is NULL, so nothing bad can happen.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/dev.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ba3b7ea5ebb3..c98052487e98 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3981,8 +3981,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 
 	if (!skb) {
 		skb = netdev_alloc_skb_ip_align(napi->dev, GRO_MAX_HEAD);
-		if (skb)
-			napi->skb = skb;
+		napi->skb = skb;
 	}
 	return skb;
 }
