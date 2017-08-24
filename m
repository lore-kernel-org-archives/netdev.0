From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] virtio_net: be drop monitor friend
Date: Thu, 24 Aug 2017 09:02:49 -0700
Message-ID: <1503590569.2499.81.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33680 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753433AbdHXQCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 12:02:51 -0400
Received: by mail-pg0-f67.google.com with SMTP id 189so4536222pgj.0
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 09:02:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This change is needed to not fool drop monitor.
(perf record ... -e skb:kfree_skb )

Packets were properly sent and are consumed after TX completion.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/virtio_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 98f17b05c68b..b06169ea60dc 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1058,7 +1058,7 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 		bytes += skb->len;
 		packets++;
 
-		dev_kfree_skb_any(skb);
+		dev_consume_skb_any(skb);
 	}
 
 	/* Avoid overhead when no packets have been processed
