From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] virtio_net: Support netdev_ops->ndo_xmit_flush()
Date: Sat, 23 Aug 2014 13:28:37 -0700 (PDT)
Message-ID: <20140823.132837.1543009042943813804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jhs@mojatatu.com, hannes@stressinduktion.org,
	edumazet@google.com, jeffrey.t.kirsher@intel.com,
	rusty@rustcorp.com.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbaHWU2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 16:28:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/virtio_net.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 59caa06..6242108 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -934,7 +934,6 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(sq->vq);
 
 	/* Don't wait up for transmitted skbs to be freed. */
 	skb_orphan(skb);
@@ -957,6 +956,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
+static void xmit_flush(struct net_device *dev, u16 qnum)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct send_queue *sq = &vi->sq[qnum];
+
+	virtqueue_kick(sq->vq);
+}
+
 /*
  * Send command via the control virtqueue and check status.  Commands
  * supported by the hypervisor, as indicated by feature bits, should
@@ -1386,6 +1393,7 @@ static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
 	.ndo_start_xmit      = start_xmit,
+	.ndo_xmit_flush      = xmit_flush,
 	.ndo_validate_addr   = eth_validate_addr,
 	.ndo_set_mac_address = virtnet_set_mac_address,
 	.ndo_set_rx_mode     = virtnet_set_rx_mode,
-- 
1.7.11.7
