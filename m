From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: [PATCH] packet: uses kfree_skb() for drop.
Date: Wed,  6 Apr 2016 09:54:46 -0700
Message-ID: <1459961686-14281-1-git-send-email-weongyo.linux@gmail.com>
Cc: Weongyo Jeong <weongyo.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33309 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbcDFQzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 12:55:09 -0400
Received: by mail-pf0-f194.google.com with SMTP id e190so4865797pfe.0
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 09:55:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

consume_skb() isn't for drop or error cases.  kfree_skb() is more proper
one.

Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
---
 net/packet/af_packet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 1ecfa71..a75d5bf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2141,7 +2141,7 @@ drop_n_restore:
 		skb->len = skb_len;
 	}
 drop:
-	consume_skb(skb);
+	kfree_skb(skb);
 	return 0;
 }
 
-- 
2.1.3
