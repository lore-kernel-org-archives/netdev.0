From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH] net, virtio_net: replace the magic value
Date: Mon, 18 Nov 2013 21:19:27 +0800
Message-ID: <1384780767-25507-1-git-send-email-zwu.kernel@gmail.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:38678 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab3KRNTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 08:19:36 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Mon, 18 Nov 2013 06:19:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

It is more appropriate to use # of queue pairs currently used by
the driver instead of a magic value.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
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
