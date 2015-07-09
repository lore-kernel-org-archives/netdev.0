From: Pierre Morel <pmorel@linux.vnet.ibm.com>
Subject: [PATCH] 9p/trans_virtio: reset virtio device on remove
Date: Thu,  9 Jul 2015 14:58:26 +0200
Message-ID: <1436446706-44314-1-git-send-email-pmorel@linux.vnet.ibm.com>
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: ericvh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On device shutdown/removal, virtio drivers need to trigger a reset on
the device; if this is neglected, the virtio core will complain about
non-zero device status.

This patch resets the status when the 9p virtio driver is removed
from the system by calling vdev->config->reset on the virtio_device
to send a reset to the host virtio device.

Signed-off-by: Pierre Morel <pmorel@linux.vnet.ibm.com>
Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>

---
 net/9p/trans_virtio.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 9dd49ca..6e70ddb 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -704,6 +704,7 @@ static void p9_virtio_remove(struct virtio_device *vdev)
 
 	mutex_unlock(&virtio_9p_lock);
 
+	vdev->config->reset(vdev);
 	vdev->config->del_vqs(vdev);
 
 	sysfs_remove_file(&(vdev->dev.kobj), &dev_attr_mount_tag.attr);
-- 
2.3.8
