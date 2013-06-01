From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: use XPS if possible for bnx2x_select_queue
 instead of pure hash
Date: Fri, 31 May 2013 17:32:55 -0700
Message-ID: <1370046775.24311.16.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"govindarajulu.v" <govindarajulu90@gmail.com>,
	Havard Skinnemoen <hskinnemoen@google.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:37517 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932232Ab3FAAc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:32:58 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so4216366obb.32
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 17:32:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

The bnx2x_select_queue() was using __skb_tx_hash() to select the
transmit queue, totally ignoring XPS settings, while XPS can help
performance quite significantly, so change the bnx2x_select_queue()
to use __dev_pick_tx() instead which will use XPS if configured.
 
Based on patches from Ying Cai and Havard Skinnemoen

Reported-by: govindarajulu.v <govindarajulu90@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Havard Skinnemoen <hskinnemoen@google.com>
Cc: Ying Cai <ycai@google.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index c80f1d2..3651f6d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1829,7 +1829,7 @@ u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
 	}
 
 	/* select a non-FCoE queue */
-	return __skb_tx_hash(dev, skb, BNX2X_NUM_ETH_QUEUES(bp));
+	return __netdev_pick_tx(dev, skb) % BNX2X_NUM_ETH_QUEUES(bp);
 }
 
 void bnx2x_set_num_queues(struct bnx2x *bp)
