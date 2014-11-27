From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v5 33/45] virtio_net: disable mac write for virtio 1.0
Date: Thu, 27 Nov 2014 14:32:49 +0200
Message-ID: <1417091078-24611-34-git-send-email-mst@redhat.com>
References: <1417091078-24611-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417091078-24611-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spec states that mac in config space is only driver-writable in the
legacy case.  Fence writing it in virtnet_set_mac_address() in the
virtio 1.0 case.

Suggested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c6a72d3..9ab3c50 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1030,7 +1030,8 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 				 "Failed to set mac address by vq command.\n");
 			return -EINVAL;
 		}
-	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
+	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC) &&
+		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
 		unsigned int i;
 
 		/* Naturally, this has an atomicity problem. */
-- 
MST
