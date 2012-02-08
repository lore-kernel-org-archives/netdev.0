From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 42/50] virtio_net:  use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:49 +0100
Message-ID: <1328735457-29986-43-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/virtio_net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 4880aa8..69d36e1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1061,7 +1061,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_config_val_len(vdev, VIRTIO_NET_F_MAC,
 				  offsetof(struct virtio_net_config, mac),
 				  dev->dev_addr, dev->addr_len) < 0)
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 
 	/* Set up our device-specific information */
 	vi = netdev_priv(dev);
-- 
1.7.7.3
