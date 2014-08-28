From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2] virtio_net: flush when in xmit_more mode and under
 descriptor pressure
Date: Thu, 28 Aug 2014 01:41:00 -0700 (PDT)
Message-ID: <20140828.014100.627859966122813076.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965045AbaH1IlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 04:41:00 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 91E3B5898BA
	for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 01:41:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mirror the changes made to ixgbe in commit 2367a17390138f68b3aa28f2f220b8d7ff8d91f4
("ixgbe: flush when in xmit_more mode and under descriptor pressure")

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/virtio_net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f0c2824..9359a13 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -953,7 +953,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	if (!skb->xmit_more)
+	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
 		virtqueue_kick(sq->vq);
 
 	return NETDEV_TX_OK;
-- 
1.7.11.7
