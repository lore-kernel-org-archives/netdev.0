From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] virtio_net: large tx MTU support
Date: Wed, 26 Nov 2008 13:58:11 +0000
Message-ID: <1227707891.9579.44.camel@blaa>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40504 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752308AbYKZN77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 08:59:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't really have a max tx packet size limit, so allow configuring
the device with up to 64k tx MTU.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e6b5d6e..71ca29c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -613,6 +613,17 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tso = ethtool_op_set_tso,
 };
 
+#define MIN_MTU 68
+#define MAX_MTU 65535
+
+static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
@@ -628,6 +639,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	dev->open = virtnet_open;
 	dev->stop = virtnet_close;
 	dev->hard_start_xmit = start_xmit;
+	dev->change_mtu = virtnet_change_mtu;
 	dev->features = NETIF_F_HIGHDMA;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = virtnet_netpoll;
-- 
1.6.0.3

