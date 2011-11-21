From: raj@tardy.cup.hp.com (Rick Jones)
Subject: [PATCH net-next] virtio_net: return already tracked tx_fifo_errors via virtnet_getstats()
Date: Mon, 21 Nov 2011 11:28:17 -0800 (PST)
Message-ID: <20111121192817.F2CAE290041F@tardy>
To: <netdev@vger.kernel.org>, <rusty@rustcorp.com.au>, <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:28578 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab1KUT2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 14:28:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>

Tx_fifo_errors are tracked in start_xmit_ for virtio_net, but not
reported in the tallies returned by virtnet_stats().  Return them
as the rx "sub-stats" rx_length_errors and rx_frame_errors are.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---

Compiled and booted in a guest, but no tx_fifo_errors generated.


diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4dc9d84..5a96172 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -700,6 +700,7 @@ static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
 	}
 
 	tot->tx_dropped = dev->stats.tx_dropped;
+	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
 	tot->rx_dropped = dev->stats.rx_dropped;
 	tot->rx_length_errors = dev->stats.rx_length_errors;
 	tot->rx_frame_errors = dev->stats.rx_frame_errors;
