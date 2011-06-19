From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sgi-xp: fix a use after free
Date: Mon, 20 Jun 2011 00:52:36 +0200
Message-ID: <1308523956.3539.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, Robin Holt <holt@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50426 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754936Ab1FSWwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 18:52:44 -0400
Received: by wwe5 with SMTP id 5so1993581wwe.1
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 15:52:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its illegal to dereference skb after dev_kfree_skb(skb)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Robin Holt <holt@sgi.com>
---
David, I am not sure Robin is active these days, maybe you can take this
patch, since its clearly network related ?

 drivers/misc/sgi-xp/xpnet.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
index ee5109a..42f0673 100644
--- a/drivers/misc/sgi-xp/xpnet.c
+++ b/drivers/misc/sgi-xp/xpnet.c
@@ -495,14 +495,14 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
+
 	if (atomic_dec_return(&queued_msg->use_count) == 0) {
 		dev_kfree_skb(skb);
 		kfree(queued_msg);
 	}
 
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-
 	return NETDEV_TX_OK;
 }
 


