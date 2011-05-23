From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] rionet: Remove pointless printk of skb pointer.
Date: Sun, 22 May 2011 20:57:18 -0400 (EDT)
Message-ID: <20110522.205718.1592689841585750053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab1EWA5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:57:20 -0400
Received: from localhost (cpe-66-108-115-211.nyc.res.rr.com [66.108.115.211])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4N0vJxn005510
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 17:57:19 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Casting to u32 warns anyways.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/rionet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index 26afbaa..77c5092 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -162,8 +162,8 @@ static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 	rnet->tx_slot &= (RIONET_TX_RING_SIZE - 1);
 
 	if (netif_msg_tx_queued(rnet))
-		printk(KERN_INFO "%s: queued skb %8.8x len %8.8x\n", DRV_NAME,
-		       (u32) skb, skb->len);
+		printk(KERN_INFO "%s: queued skb len %8.8x\n", DRV_NAME,
+		       skb->len);
 
 	return 0;
 }
-- 
1.7.4.4

