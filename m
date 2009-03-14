From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: [PATCH] Make virtio_net report carrier status ON.
Date: Sat, 14 Mar 2009 12:40:49 +0200
Message-ID: <1237027249-10512-1-git-send-email-pktoss@gmail.com>
Cc: Pantelis Koukousoulas <pktoss@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:21633 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbZCNKki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 06:40:38 -0400
Received: by ey-out-2122.google.com with SMTP id 25so730169eya.37
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2009 03:40:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current versions of virtio hardware do not have a way to
turn the link "OFF", so in practice, the status is always ON.

Reporting that via ethtool instead of claiming
"I have no idea", allows NetworkManager to configure the
card automatically as preferred and gives users e.g.,
testing a new livecd in existing qemu/kvm the experience
they expect.

Note that for the next versions of the kernel and virtual
hardware, there is a patch that adds proper link detection
to the driver (since it will now be possible to turn it off).
But even in the light of this, my patch is still valid
because the "default ON" behavior will still be needed for
current qemu / virtio versions that don't support this feature
(VIRTIO_NET_F_STATUS).

Signed-off-by: Pantelis Koukousoulas <pktoss@gmail.com>
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

