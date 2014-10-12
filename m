From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v3 18/25] virtio_scsi: enable VQs early on restore
Date: Sun, 12 Oct 2014 14:48:01 +0300
Message-ID: <1413114332-626-19-git-send-email-mst@redhat.com>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, kvm@vger.kernel.org, linux-scsi@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1413114332-626-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

virtio spec requires drivers to set DRIVER_OK before using VQs.
This is set automatically after restore returns, virtio scsi violated
this rule on restore by kicking event vq within restore.

To fix, call virtio_enable_vqs_early before using event queue.

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
 
+	virtio_enable_vqs_early(vdev);
+
 	if (virtio_has_feature(vdev, VIRTIO_SCSI_F_HOTPLUG))
 		virtscsi_kick_event_all(vscsi);
 
-- 
MST
