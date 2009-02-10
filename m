From: David Miller <davem@davemloft.net>
Subject: [PATCH]: irda: Use __netdev_alloc_skb() instead of
 __dev_alloc_skb().
Date: Tue, 10 Feb 2009 01:58:43 -0800 (PST)
Message-ID: <20090210.015843.175449556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752317AbZBJJ6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 04:58:49 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 5A76DC8D94F
	for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 01:58:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/irda/sir_dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 5b58624..c23d211 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -753,7 +753,8 @@ static int sirdev_alloc_buffers(struct sir_dev *dev)
 	dev->rx_buff.truesize = IRDA_SKB_MAX_MTU; 
 
 	/* Bootstrap ZeroCopy Rx */
-	dev->rx_buff.skb = __dev_alloc_skb(dev->rx_buff.truesize, GFP_KERNEL);
+	dev->rx_buff.skb = __netdev_alloc_skb(dev->netdev, dev->rx_buff.truesize,
+					      GFP_KERNEL);
 	if (dev->rx_buff.skb == NULL)
 		return -ENOMEM;
 	skb_reserve(dev->rx_buff.skb, 1);
-- 
1.6.1.2.253.ga34a

