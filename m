From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/6] virtio: fix tx_ stats in virtio_net
Date: Wed, 23 Apr 2008 23:56:07 -0500
Message-ID: <200804241456.07551.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:58754 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbYDXE4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 00:56:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


get_buf() gives the length written by the other side, which will be
zero.  We want to add the skb length.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -r 51bdbdc4f199 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Thu Apr 10 15:55:52 2008 +1000
+++ b/drivers/net/virtio_net.c	Mon Apr 14 11:13:45 2008 +1000
@@ -221,7 +221,7 @@ static void free_old_xmit_skbs(struct vi
 	while ((skb = vi->svq->vq_ops->get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 		__skb_unlink(skb, &vi->send);
-		vi->dev->stats.tx_bytes += len;
+		vi->dev->stats.tx_bytes += skb->len;
 		vi->dev->stats.tx_packets++;
 		kfree_skb(skb);
 	}

