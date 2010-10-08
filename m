From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 19692] New: linux-2.6.36-rc5 crash with
 gianfar ethernet at full line rate traffic
Date: Fri, 8 Oct 2010 11:24:27 +0200
Message-ID: <20101008092427.GA2327@del.dom.local>
References: <20101004135310.6a5f8e93.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, eminak71@gmail.com,
	Anton Vorontsov <avorontsov@mvista.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59420 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab0JHJYd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 05:24:33 -0400
Received: by wyb28 with SMTP id 28so904853wyb.19
        for <netdev@vger.kernel.org>; Fri, 08 Oct 2010 02:24:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101004135310.6a5f8e93.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 4 Oct 2010 06:25:14 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=19692
>>
>>            Summary: linux-2.6.36-rc5 crash with gianfar ethernet at full
>>                     line rate traffic
...

Emin, until there is something better I hope you could try this patch.
(not tested nor compiled)

Thanks,
Jarek P.
---
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4f7c3f3..db47b55 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2515,7 +2515,7 @@ static int gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
 				skb_recycle_check(skb, priv->rx_buffer_size +
 					RXBUF_ALIGNMENT)) {
 			gfar_align_skb(skb);
-			__skb_queue_head(&priv->rx_recycle, skb);
+			skb_queue_head(&priv->rx_recycle, skb);
 		} else
 			dev_kfree_skb_any(skb);
 
@@ -2598,7 +2598,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev)
 	struct gfar_private *priv = netdev_priv(dev);
 	struct sk_buff *skb = NULL;
 
-	skb = __skb_dequeue(&priv->rx_recycle);
+	skb = skb_dequeue(&priv->rx_recycle);
 	if (!skb)
 		skb = gfar_alloc_skb(dev);
 
@@ -2754,7 +2754,7 @@ int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int rx_work_limit)
 			if (unlikely(!newskb))
 				newskb = skb;
 			else if (skb)
-				__skb_queue_head(&priv->rx_recycle, skb);
+				skb_queue_head(&priv->rx_recycle, skb);
 		} else {
 			/* Increment the number of packets */
 			rx_queue->stats.rx_packets++;
