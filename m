From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] virtio-net: use netif_tx_napi_add for tx napi
Date: Thu, 27 Apr 2017 20:37:58 -0400
Message-ID: <20170428003758.48143-1-willemdebruijn.kernel@gmail.com>
Cc: mst@redhat.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34932 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754097AbdD1AiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 20:38:02 -0400
Received: by mail-qt0-f195.google.com with SMTP id o36so6639739qtb.2
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 17:38:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Avoid hashing the tx napi struct into napi_hash[], which is used for
busy polling receive queues.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 drivers/net/virtio_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 82f1c3a73345..7877551fe4e0 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2228,8 +2228,8 @@ static int virtnet_alloc_queues(struct virtnet_info *vi)
 		vi->rq[i].pages = NULL;
 		netif_napi_add(vi->dev, &vi->rq[i].napi, virtnet_poll,
 			       napi_weight);
-		netif_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
-			       napi_tx ? napi_weight : 0);
+		netif_tx_napi_add(vi->dev, &vi->sq[i].napi, virtnet_poll_tx,
+				  napi_tx ? napi_weight : 0);
 
 		sg_init_table(vi->rq[i].sg, ARRAY_SIZE(vi->rq[i].sg));
 		ewma_pkt_len_init(&vi->rq[i].mrg_avg_pkt_len);
-- 
2.13.0.rc0.306.g87b477812d-goog
