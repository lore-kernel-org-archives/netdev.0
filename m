From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] virtio: change comment in transmit
Date: Tue, 24 Mar 2015 16:22:07 -0700
Message-ID: <20150324162207.6d4ecf48@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33058 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbbCXXWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 19:22:05 -0400
Received: by pabxg6 with SMTP id xg6so8474722pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 16:22:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original comment was not really informative or funny
as well as sexist. Replace it with a better explanation of
why the driver does stop and what the impacts are.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/virtio_net.c	2015-03-24 15:20:25.174671000 -0700
+++ b/drivers/net/virtio_net.c	2015-03-24 16:17:28.478525333 -0700
@@ -939,8 +939,12 @@ static netdev_tx_t start_xmit(struct sk_
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	/* Apparently nice girls don't return TX_BUSY; stop the queue
-	 * before it gets out of hand.  Naturally, this wastes entries. */
+	/* It is better to stop queue if running out of space
+	 * instead of forcing queuing layer to requeue the skb
+	 * by returning TX_BUSY (and cause a BUG message).
+	 * Since most packets only take 1 or 2 ring slots
+	 * this means 16 slots are typically wasted.
+	 */
 	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
 		netif_stop_subqueue(dev, qnum);
 		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
