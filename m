From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 36/39] mv643xx_eth: be more agressive about RX refill
Date: Tue,  3 Jun 2008 13:02:51 +0200
Message-ID: <1212490974-23719-37-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48752 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753903AbYFCMA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:28 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During OOM, instead of stopping RX refill when the rx desc ring is
not empty, keep trying to refill the ring as long as it is not full
instead.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a7c5421..0f8e79f 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -475,7 +475,7 @@ static void rxq_refill(struct rx_queue *rxq)
 		skb_reserve(skb, 2);
 	}
 
-	if (rxq->rx_desc_count == 0) {
+	if (rxq->rx_desc_count != rxq->rx_ring_size) {
 		rxq->rx_oom.expires = jiffies + (HZ / 10);
 		add_timer(&rxq->rx_oom);
 	}
-- 
1.5.3.4

