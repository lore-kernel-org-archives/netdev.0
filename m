From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v4 26/42] vhost/net: force len for TX to host endian
Date: Tue, 25 Nov 2014 18:43:14 +0200
Message-ID: <1416933600-21398-27-git-send-email-mst@redhat.com>
References: <1416933600-21398-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416933600-21398-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We use native endian-ness internally but never
expose it to guest.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 8dae2f7..dce5c58 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -48,15 +48,15 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
  * status internally; used for zerocopy tx only.
  */
 /* Lower device DMA failed */
-#define VHOST_DMA_FAILED_LEN	3
+#define VHOST_DMA_FAILED_LEN	((__force __virtio32)3)
 /* Lower device DMA done */
-#define VHOST_DMA_DONE_LEN	2
+#define VHOST_DMA_DONE_LEN	((__force __virtio32)2)
 /* Lower device DMA in progress */
-#define VHOST_DMA_IN_PROGRESS	1
+#define VHOST_DMA_IN_PROGRESS	((__force __virtio32)1)
 /* Buffer unused */
-#define VHOST_DMA_CLEAR_LEN	0
+#define VHOST_DMA_CLEAR_LEN	((__force __virtio32)0)
 
-#define VHOST_DMA_IS_DONE(len) ((len) >= VHOST_DMA_DONE_LEN)
+#define VHOST_DMA_IS_DONE(len) ((__force u32)(len) >= (__force u32)VHOST_DMA_DONE_LEN)
 
 enum {
 	VHOST_NET_FEATURES = VHOST_FEATURES |
-- 
MST
