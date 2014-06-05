From: Amos Kong <akong@redhat.com>
Subject: [PATCH 1/2] mvme147: fix ram size in comment
Date: Thu,  5 Jun 2014 11:01:21 +0800
Message-ID: <1401937282-18345-2-git-send-email-akong@redhat.com>
References: <1401937282-18345-1-git-send-email-akong@redhat.com>
Cc: geert@linux-m68k.org, netdev@vger.kernel.org, davem@davemloft.net,
	schwab@linux-m68k.org
To: linux-m68k@vger.kernel.org
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1401937282-18345-1-git-send-email-akong@redhat.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The order of ram pages is 3, so the ram size is 2^3 * 4K = 32K.

Signed-off-by: Amos Kong <akong@redhat.com>
---
 drivers/net/ethernet/amd/mvme147.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index 0e8399d..0660ac5 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -26,9 +26,9 @@
 #include <asm/pgtable.h>
 #include <asm/mvme147hw.h>
 
-/* We have 16834 bytes of RAM for the init block and buffers. This places
+/* We have 32K of RAM for the init block and buffers. This places
  * an upper limit on the number of buffers we can use. NetBSD uses 8 Rx
- * buffers and 2 Tx buffers.
+ * buffers and 2 Tx buffers, it takes (8 + 2) * 1544 bytes.
  */
 #define LANCE_LOG_TX_BUFFERS 1
 #define LANCE_LOG_RX_BUFFERS 3
@@ -111,7 +111,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 	       dev->dev_addr);
 
 	lp = netdev_priv(dev);
-	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
+	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 32K */
 	if (!lp->ram) {
 		printk("%s: No memory for LANCE buffers\n", dev->name);
 		free_netdev(dev);
-- 
1.9.3
