From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 34/54] s2io: Call dev_kfree_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:20 -0700
Message-ID: <1395727540-12148-34-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59104 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbaCYGLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:39 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_kfree_skb_any in s2io_xmit that can
be called in hard irq and other contexts.

All instances that are changed are packet drops.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/neterion/s2io.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index d44fdb91808e..a2844ff322c4 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -4049,7 +4049,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!is_s2io_card_up(sp)) {
 		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
 			  dev->name);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -4122,7 +4122,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	    ((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
 		DBG_PRINT(TX_DBG, "Error in xmit, No free TXDs.\n");
 		s2io_stop_tx_queue(sp, fifo->fifo_no);
-		dev_kfree_skb(skb);
+		dev_kfree_skb_any(skb);
 		spin_unlock_irqrestore(&fifo->tx_lock, flags);
 		return NETDEV_TX_OK;
 	}
@@ -4244,7 +4244,7 @@ pci_map_failed:
 	swstats->pci_map_fail_cnt++;
 	s2io_stop_tx_queue(sp, fifo->fifo_no);
 	swstats->mem_freed += skb->truesize;
-	dev_kfree_skb(skb);
+	dev_kfree_skb_any(skb);
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
-- 
1.7.10.4
