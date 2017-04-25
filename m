From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: [PATCH 5/5] virtio_net: check return value of skb_to_sgvec always
Date: Tue, 25 Apr 2017 16:08:09 +0200
Message-ID: <20170425140809.23881-5-Jason@zx2c4.com>
References: <20170425140809.23881-1-Jason@zx2c4.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, David.Laight@aculab.com,
        kernel-hardening@lists.openwall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:53685 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1431436AbdDYOId (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 10:08:33 -0400
In-Reply-To: <20170425140809.23881-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jason A. Donenfeld <Jason@zx2c4.com>
---
 drivers/net/virtio_net.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index f36584616e7d..1709fd0b4bf7 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1081,7 +1081,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	struct virtio_net_hdr_mrg_rxbuf *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 	struct virtnet_info *vi = sq->vq->vdev->priv;
-	unsigned num_sg;
+	int num_sg;
 	unsigned hdr_len = vi->hdr_len;
 	bool can_push;
 
@@ -1114,6 +1114,8 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 		sg_set_buf(sq->sg, hdr, hdr_len);
 		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
 	}
+	if (unlikely(num_sg < 0))
+		return num_sg;
 	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
 }
 
-- 
2.12.2
