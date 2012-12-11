From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: gro: avoid double copy in skb_gro_receive()
Date: Tue, 11 Dec 2012 10:38:29 -0800
Message-ID: <1355251109.27891.114.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65245 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab2LKSic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 13:38:32 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so3081439pad.19
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2012 10:38:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

__copy_skb_header(nskb, p) already copied p->cb[], no need to copy
it again.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index ccbabf5..ac9e44a 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3028,7 +3028,6 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	memcpy(skb_mac_header(nskb), skb_mac_header(p),
 	       p->data - skb_mac_header(p));
 
-	*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
 	skb_shinfo(nskb)->frag_list = p;
 	skb_shinfo(nskb)->gso_size = pinfo->gso_size;
 	pinfo->gso_size = 0;
