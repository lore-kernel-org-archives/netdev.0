From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] xen-netback:Make the function
	xenvif_schedulable have a return type of bool
Date: Tue, 16 Jun 2015 23:03:30 -0400
Message-ID: <1434510210-1341-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, wei.liu2@citrix.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: ian.campbell@citrix.com
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

This makes the function xenvif_sechedulable have a return type of
bool now due to this particular function's return statement only
ever evaluating to have a value of one or zero.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 drivers/net/xen-netback/common.h    | 2 +-
 drivers/net/xen-netback/interface.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 8a495b3..c02cafb 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -280,7 +280,7 @@ void xenvif_free(struct xenvif *vif);
 int xenvif_xenbus_init(void);
 void xenvif_xenbus_fini(void);
 
-int xenvif_schedulable(struct xenvif *vif);
+bool xenvif_schedulable(struct xenvif *vif);
 
 int xenvif_queue_stopped(struct xenvif_queue *queue);
 void xenvif_wake_queue(struct xenvif_queue *queue);
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1a83e19..b5fcb52 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -63,7 +63,7 @@ void xenvif_skb_zerocopy_complete(struct xenvif_queue *queue)
 	atomic_dec(&queue->inflight_packets);
 }
 
-int xenvif_schedulable(struct xenvif *vif)
+bool xenvif_schedulable(struct xenvif *vif)
 {
 	return netif_running(vif->dev) &&
 		test_bit(VIF_STATUS_CONNECTED, &vif->status) &&
-- 
2.1.4
