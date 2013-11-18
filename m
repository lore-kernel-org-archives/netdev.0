From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH 4/4] net, virtio_net: replace the magic value
Date: Mon, 18 Nov 2013 16:46:20 +0800
Message-ID: <1384764380-16832-1-git-send-email-zwu.kernel@gmail.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, qemu-devel@nongnu.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

It is more appropriate to use # of queue pairs currently used by
the driver instead of a magic value.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index cdc7c90..e0cb2d1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1619,8 +1619,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (err)
 		goto free_stats;
 
-	netif_set_real_num_tx_queues(dev, 1);
-	netif_set_real_num_rx_queues(dev, 1);
+	netif_set_real_num_tx_queues(dev, vi->curr_queue_pairs);
+	netif_set_real_num_rx_queues(dev, vi->curr_queue_pairs);
 
 	err = register_netdev(dev);
 	if (err) {
-- 
1.7.6.5
