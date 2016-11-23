From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] tuntap: remove unnecessary sk_receive_queue length check during xmit
Date: Wed, 23 Nov 2016 10:26:49 +0800
Message-ID: <1479868009-14157-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 1576d9860599 ("tun: switch to use skb array for tx"),
sk_receive_queue was not used any more. So remove the uncessary
sk_receive_queue length check during xmit.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 64e694c..e2af2dd 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -878,13 +878,6 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	    sk_filter(tfile->socket.sk, skb))
 		goto drop;
 
-	/* Limit the number of packets queued by dividing txq length with the
-	 * number of queues.
-	 */
-	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
-			  >= dev->tx_queue_len)
-		goto drop;
-
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		goto drop;
 
-- 
2.7.4
