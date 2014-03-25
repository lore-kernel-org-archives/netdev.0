From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 18/54] cs89x0: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:05:04 -0700
Message-ID: <1395727540-12148-18-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58560 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbaCYGLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:11:39 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in net_send_packet that
can be called in hard irq and other contexts.

net_send_packet consumes (not drops) the skb of interest.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 19f642a45f40..fe84fbabc0d4 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1174,7 +1174,7 @@ static netdev_tx_t net_send_packet(struct sk_buff *skb, struct net_device *dev)
 	writewords(lp, TX_FRAME_PORT, skb->data, (skb->len + 1) >> 1);
 	spin_unlock_irqrestore(&lp->lock, flags);
 	dev->stats.tx_bytes += skb->len;
-	dev_kfree_skb(skb);
+	dev_consume_skb_any(skb);
 
 	/* We DO NOT call netif_wake_queue() here.
 	 * We also DO NOT call netif_start_queue().
-- 
1.7.10.4
