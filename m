From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sky2: fix skb truesize underestimation
Date: Thu, 13 Oct 2011 23:11:30 +0200
Message-ID: <1318540290.2533.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55919 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275Ab1JMVLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 17:11:34 -0400
Received: by wwf22 with SMTP id 22so2449156wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 14:11:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sky2 allocates a page per skb fragment. We must account
PAGE_SIZE increments on skb->truesize, not the actual frag length.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
---
 drivers/net/ethernet/marvell/sky2.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 6895e3b..9263490 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2486,7 +2486,7 @@ static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 
 			frag->size = size;
 			skb->data_len += size;
-			skb->truesize += size;
+			skb->truesize += PAGE_SIZE;
 			skb->len += size;
 			length -= size;
 		}
