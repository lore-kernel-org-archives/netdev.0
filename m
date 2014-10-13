From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 18/25] virtio_scsi: enable VQs early on restore
Date: Mon, 13 Oct 2014 10:51:14 +0300
Message-ID: <1413114332-626-19-git-send-email-mst-v4@redhat.com>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

virtio spec requires drivers to set DRIVER_OK before using VQs.
This is set automatically after restore returns, virtio scsi violated
this rule on restore by kicking event vq within restore.

To fix, call virtio_device_ready before using event queue.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/scsi/virtio_scsi.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index 0642ce3..2b565b3 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -1054,6 +1054,8 @@ static int virtscsi_restore(struct virtio_device *vdev)
 		return err;
 	}
 
+	virtio_device_ready(vdev);
+
 	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
 		virtscsi_kick_event_all(vscsi);
 
-- 
MST
