From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v6 30/46] vhost/net: force len for TX to host endian
Date: Thu, 27 Nov 2014 22:10:19 +0200
Message-ID: <1417118789-18231-31-git-send-email-mst@redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417118789-18231-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vhost/net keeps a copy of some used ring but (ab)uses length
field for internal house-keeping. This works because
for tx used length is always 0.
Suppress sparse errors: we use native endian-ness internally but never
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
