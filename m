From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] virtio_net: don't require ANY_LAYOUT with VERSION_1
Date: Wed, 15 Jul 2015 15:26:19 +0300
Message-ID: <1436963135-16592-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        Jason Wang <jasowang@redhat.com>, virtio-dev@lists.oasis-open.org
To: linux-kernel@vger.kernel.org
Return-path: <virtio-dev-return-849-gcvd-virtio-dev=m.gmane.org@lists.oasis-open.org>
Sender: <virtio-dev@lists.oasis-open.org>
List-Post: <mailto:virtio-dev@lists.oasis-open.org>
List-Help: <mailto:virtio-dev-help@lists.oasis-open.org>
List-Unsubscribe: <mailto:virtio-dev-unsubscribe@lists.oasis-open.org>
List-Subscribe: <mailto:virtio-dev-subscribe@lists.oasis-open.org>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

ANY_LAYOUT is a compatibility feature. It's implied
for VERSION_1 devices, and non-transitional devices
might not offer it. Change code to behave accordingly.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 63c7810..7fbca37 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1828,7 +1828,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 	else
 		vi->hdr_len = sizeof(struct virtio_net_hdr);
 
-	if (virtio_has_feature(vdev, VIRTIO_F_ANY_LAYOUT))
+	if (virtio_has_feature(vdev, VIRTIO_F_ANY_LAYOUT) ||
+	    virtio_has_feature(vdev, VIRTIO_F_VERSION_1))
 		vi->any_header_sg = true;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
-- 
MST
