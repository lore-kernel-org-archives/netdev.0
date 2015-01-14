From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 05/16] virtio/net: verify device has config space
Date: Wed, 14 Jan 2015 19:27:39 +0200
Message-ID: <1421256142-11512-6-git-send-email-mst@redhat.com>
References: <1421256142-11512-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, cornelia.huck@de.ibm.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1421256142-11512-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some devices might not implement config space access
(e.g. remoteproc used not to - before 3.9).
virtio/net needs config space access so make it
fail gracefully if not there.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/virtio_net.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5ca9771..9bc1072 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1713,6 +1713,12 @@ static int virtnet_probe(struct virtio_device *vdev)
 	struct virtnet_info *vi;
 	u16 max_queue_pairs;
 
+	if (!vdev->config->get) {
+		dev_err(&vdev->dev, "%s failure: config access disabled\n",
+			__func__);
+		return -EINVAL;
+	}
+
 	if (!virtnet_validate_features(vdev))
 		return -EINVAL;
 
-- 
MST
