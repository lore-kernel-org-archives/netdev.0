From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/3] vringh: 64 bit features
Date: Mon, 15 Dec 2014 23:14:02 +0200
Message-ID: <1418678019-31629-2-git-send-email-mst@redhat.com>
References: <1418678019-31629-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1418678019-31629-1-git-send-email-mst@redhat.com>
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

Pass u64 everywhere.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 include/linux/vringh.h | 4 ++--
 drivers/vhost/vringh.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/vringh.h b/include/linux/vringh.h
index 749cde2..f696dd0 100644
--- a/include/linux/vringh.h
+++ b/include/linux/vringh.h
@@ -105,7 +105,7 @@ struct vringh_kiov {
 #define VRINGH_IOV_ALLOCATED 0x8000000
 
 /* Helpers for userspace vrings. */
-int vringh_init_user(struct vringh *vrh, u32 features,
+int vringh_init_user(struct vringh *vrh, u64 features,
 		     unsigned int num, bool weak_barriers,
 		     struct vring_desc __user *desc,
 		     struct vring_avail __user *avail,
@@ -167,7 +167,7 @@ bool vringh_notify_enable_user(struct vringh *vrh);
 void vringh_notify_disable_user(struct vringh *vrh);
 
 /* Helpers for kernelspace vrings. */
-int vringh_init_kern(struct vringh *vrh, u32 features,
+int vringh_init_kern(struct vringh *vrh, u64 features,
 		     unsigned int num, bool weak_barriers,
 		     struct vring_desc *desc,
 		     struct vring_avail *avail,
diff --git a/drivers/vhost/vringh.c b/drivers/vhost/vringh.c
index 5174eba..ac3fe27 100644
--- a/drivers/vhost/vringh.c
+++ b/drivers/vhost/vringh.c
@@ -577,7 +577,7 @@ static inline int xfer_to_user(void *dst, void *src, size_t len)
  * Returns an error if num is invalid: you should check pointers
  * yourself!
  */
-int vringh_init_user(struct vringh *vrh, u32 features,
+int vringh_init_user(struct vringh *vrh, u64 features,
 		     unsigned int num, bool weak_barriers,
 		     struct vring_desc __user *desc,
 		     struct vring_avail __user *avail,
@@ -836,7 +836,7 @@ static inline int xfer_kern(void *src, void *dst, size_t len)
  *
  * Returns an error if num is invalid.
  */
-int vringh_init_kern(struct vringh *vrh, u32 features,
+int vringh_init_kern(struct vringh *vrh, u64 features,
 		     unsigned int num, bool weak_barriers,
 		     struct vring_desc *desc,
 		     struct vring_avail *avail,
-- 
MST
