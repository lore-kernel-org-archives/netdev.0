From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/4] vhost: move features to core
Date: Thu, 10 Sep 2015 10:23:44 +0300
Message-ID: <1441869802-15847-3-git-send-email-mst@redhat.com>
References: <1441869802-15847-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Xie, Huawei" <huawei.xie@intel.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1441869802-15847-1-git-send-email-mst@redhat.com>
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

virtio 1 and any layout are core features, move them
there. This fixes vhost test.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.h | 4 +++-
 drivers/vhost/net.c   | 3 +--
 drivers/vhost/scsi.c  | 4 +---
 drivers/vhost/test.c  | 3 +++
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index ce6f6da..4772862 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -173,7 +173,9 @@ enum {
 	VHOST_FEATURES = (1ULL << VIRTIO_F_NOTIFY_ON_EMPTY) |
 			 (1ULL << VIRTIO_RING_F_INDIRECT_DESC) |
 			 (1ULL << VIRTIO_RING_F_EVENT_IDX) |
-			 (1ULL << VHOST_F_LOG_ALL),
+			 (1ULL << VHOST_F_LOG_ALL) |
+			 (1ULL << VIRTIO_F_ANY_LAYOUT) |
+			 (1ULL << VIRTIO_F_VERSION_1)
 };
 
 static inline bool vhost_has_feature(struct vhost_virtqueue *vq, int bit)
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7d137a4..fa68bc9 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -61,8 +61,7 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 enum {
 	VHOST_NET_FEATURES = VHOST_FEATURES |
 			 (1ULL << VHOST_NET_F_VIRTIO_NET_HDR) |
-			 (1ULL << VIRTIO_NET_F_MRG_RXBUF) |
-			 (1ULL << VIRTIO_F_VERSION_1),
+			 (1ULL << VIRTIO_NET_F_MRG_RXBUF);
 };
 
 enum {
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index dfcc02c..0321fc4 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -166,9 +166,7 @@ enum {
 /* Note: can't set VIRTIO_F_VERSION_1 yet, since that implies ANY_LAYOUT. */
 enum {
 	VHOST_SCSI_FEATURES = VHOST_FEATURES | (1ULL << VIRTIO_SCSI_F_HOTPLUG) |
-					       (1ULL << VIRTIO_SCSI_F_T10_PI) |
-					       (1ULL << VIRTIO_F_ANY_LAYOUT) |
-					       (1ULL << VIRTIO_F_VERSION_1)
+					       (1ULL << VIRTIO_SCSI_F_T10_PI);
 };
 
 #define VHOST_SCSI_MAX_TARGET	256
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index d9c501e..f2882ac 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -277,10 +277,13 @@ static long vhost_test_ioctl(struct file *f, unsigned int ioctl,
 			return -EFAULT;
 		return 0;
 	case VHOST_SET_FEATURES:
+		printk(KERN_ERR "1\n");
 		if (copy_from_user(&features, featurep, sizeof features))
 			return -EFAULT;
+		printk(KERN_ERR "2\n");
 		if (features & ~VHOST_FEATURES)
 			return -EOPNOTSUPP;
+		printk(KERN_ERR "3\n");
 		return vhost_test_set_features(n, features);
 	case VHOST_RESET_OWNER:
 		return vhost_test_reset_owner(n);
-- 
MST
