From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/3] virtio_net: hook up the set-tso ethtool op
Date: Mon, 17 Nov 2008 13:46:08 +1030
Message-ID: <200811171346.09039.rusty@rustcorp.com.au>
References: <200811171344.57410.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48438 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755121AbYKQDRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 22:17:52 -0500
In-Reply-To: <200811171344.57410.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>

Seems like an oversight that we have set-tx-csum and set-sg hooked
up, but not set-tso.

Also leads to the strange situation that if you e.g. disable tx-csum,
then tso doesn't get disabled.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index cca6435..79b59cc 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -612,6 +612,7 @@ static int virtnet_set_tx_csum(struct net_device *dev, u32 data)
 static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
+	.set_tso = ethtool_op_set_tso,
 };
 
 static int virtnet_probe(struct virtio_device *vdev)

