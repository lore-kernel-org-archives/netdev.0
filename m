From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 03/54] 3c59x: Call dev_consume_skb_any instead of dev_kfree_skb.
Date: Mon, 24 Mar 2014 23:04:49 -0700
Message-ID: <1395727540-12148-3-git-send-email-ebiederm@xmission.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:57824 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaCYGGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 02:06:05 -0400
In-Reply-To: <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

Replace dev_kfree_skb with dev_consume_skb_any in vortex_start_xmit
as it can be called in hard irq and other contexts.

dev_consume_skb_any is used when vortext_start_xmit directly consumes
the packet instead of dmaing it to the device.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/3com/3c59x.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 238ccea965c8..61477b8e8d24 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2086,7 +2086,7 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		/* ... and the packet rounded to a doubleword. */
 		skb_tx_timestamp(skb);
 		iowrite32_rep(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
-		dev_kfree_skb (skb);
+		dev_consume_skb_any (skb);
 		if (ioread16(ioaddr + TxFree) > 1536) {
 			netif_start_queue (dev);	/* AKPM: redundant? */
 		} else {
-- 
1.7.10.4
