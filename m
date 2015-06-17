From: Julien Grall <julien.grall@citrix.com>
Subject: [PATCH v5 3/3] net/xen-netback: Don't mix hexa and decimal with 0x in the printf format
Date: Wed, 17 Jun 2015 12:38:23 +0100
Message-ID: <1434541103-31114-4-git-send-email-julien.grall@citrix.com>
References: <1434541103-31114-1-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Julien Grall <julien.grall@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434541103-31114-1-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepend 0x to all %x in order to avoid confusion while reading when there is
other decimal value in the log.

Also replace some of the hexadecimal print to decimal to uniformize the
format with netfront.

Signed-off-by: Julien Grall <julien.grall@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: netdev@vger.kernel.org

---
    Changes in v5:
        - Fix commit message
        - Add Ian's ack.

    Changes in v4:
        - Patch added
---
 drivers/net/xen-netback/netback.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index ba3ae30..11bd9d8 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -748,7 +748,7 @@ static int xenvif_count_requests(struct xenvif_queue *queue,
 		slots++;
 
 		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
-			netdev_err(queue->vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
+			netdev_err(queue->vif->dev, "Cross page boundary, txp->offset: %u, size: %u\n",
 				 txp->offset, txp->size);
 			xenvif_fatal_tx_err(queue->vif);
 			return -EINVAL;
@@ -874,7 +874,7 @@ static inline void xenvif_grant_handle_set(struct xenvif_queue *queue,
 	if (unlikely(queue->grant_tx_handle[pending_idx] !=
 		     NETBACK_INVALID_HANDLE)) {
 		netdev_err(queue->vif->dev,
-			   "Trying to overwrite active handle! pending_idx: %x\n",
+			   "Trying to overwrite active handle! pending_idx: 0x%x\n",
 			   pending_idx);
 		BUG();
 	}
@@ -887,7 +887,7 @@ static inline void xenvif_grant_handle_reset(struct xenvif_queue *queue,
 	if (unlikely(queue->grant_tx_handle[pending_idx] ==
 		     NETBACK_INVALID_HANDLE)) {
 		netdev_err(queue->vif->dev,
-			   "Trying to unmap invalid handle! pending_idx: %x\n",
+			   "Trying to unmap invalid handle! pending_idx: 0x%x\n",
 			   pending_idx);
 		BUG();
 	}
@@ -1243,7 +1243,7 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
 		/* No crossing a page as the payload mustn't fragment. */
 		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
 			netdev_err(queue->vif->dev,
-				   "txreq.offset: %x, size: %u, end: %lu\n",
+				   "txreq.offset: %u, size: %u, end: %lu\n",
 				   txreq.offset, txreq.size,
 				   (unsigned long)(txreq.offset&~PAGE_MASK) + txreq.size);
 			xenvif_fatal_tx_err(queue->vif);
@@ -1593,12 +1593,12 @@ static inline void xenvif_tx_dealloc_action(struct xenvif_queue *queue)
 					queue->pages_to_unmap,
 					gop - queue->tx_unmap_ops);
 		if (ret) {
-			netdev_err(queue->vif->dev, "Unmap fail: nr_ops %tx ret %d\n",
+			netdev_err(queue->vif->dev, "Unmap fail: nr_ops %tu ret %d\n",
 				   gop - queue->tx_unmap_ops, ret);
 			for (i = 0; i < gop - queue->tx_unmap_ops; ++i) {
 				if (gop[i].status != GNTST_okay)
 					netdev_err(queue->vif->dev,
-						   " host_addr: %llx handle: %x status: %d\n",
+						   " host_addr: 0x%llx handle: 0x%x status: %d\n",
 						   gop[i].host_addr,
 						   gop[i].handle,
 						   gop[i].status);
@@ -1731,7 +1731,7 @@ void xenvif_idx_unmap(struct xenvif_queue *queue, u16 pending_idx)
 				&queue->mmap_pages[pending_idx], 1);
 	if (ret) {
 		netdev_err(queue->vif->dev,
-			   "Unmap fail: ret: %d pending_idx: %d host_addr: %llx handle: %x status: %d\n",
+			   "Unmap fail: ret: %d pending_idx: %d host_addr: %llx handle: 0x%x status: %d\n",
 			   ret,
 			   pending_idx,
 			   tx_unmap_op.host_addr,
-- 
2.1.4
