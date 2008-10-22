From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] virtio_net: hook up the set-tso ethtool op
Date: Wed, 22 Oct 2008 16:32:26 +0100
Message-ID: <1224689546.30669.4.camel@blaa>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51552 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751059AbYJVPd6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 11:33:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems like an oversight that we have set-tx-csum and set-sg hooked
up, but not set-tso.

Also leads to the strange situation that if you e.g. disable tx-csum,
then tso doesn't get disabled.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

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
-- 
1.6.0.1

