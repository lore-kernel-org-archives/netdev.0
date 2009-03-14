From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] Make virtio_net support carrier detection
Date: Sat, 14 Mar 2009 10:53:51 +1030
Message-ID: <200903141053.51819.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37509 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757540AbZCNAX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:23:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Make NetworkManager work with virtio_net

For now the semantics are simple: There is always carrier.

This allows a seamless experience with e.g., qemu/kvm
where NetworkManager just configures and sets up
everything automagically.

If/when a generally agreed-upon way to control
carrier on/off in the emulator/hypervisor level
emerges, it will be trivial to extend the driver
to support that too, but for now even this 2-liner
makes user experience that much better.

Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
Acked-by: David Miller <davem@davemloft.net>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c688083..e67d16c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -612,6 +612,7 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
+	.get_link = ethtool_op_get_link,
 };
 
 #define MIN_MTU 68
@@ -739,6 +740,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
+	netif_carrier_on(dev);
+
 	pr_debug("virtnet: registered device %s\n", dev->name);
 	return 0;
 
-- 
1.5.6.3
