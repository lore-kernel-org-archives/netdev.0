From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH] net: macb: Increase DMA buffer size
Date: Wed, 24 Aug 2016 13:25:59 -0500
Message-ID: <1472063159-13797-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, Nathan Sullivan <nathan.sullivan@ni.com>,
        linux-kernel@vger.kernel.org, xander.huff@ni.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nathan Sullivan <nathan.sullivan@ni.com>

In recent testing with the RT patchset, we have seen cases where the
transmit ring can fill even with up to 200 txbds in the ring.  Increase
the size of the DMA rings to avoid overruns.

Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
Acked-by: Ben Shelton <ben.shelton@ni.com>
Acked-by: Jaeden Amero <jaeden.amero@ni.com>
Natinst-ReviewBoard-ID: 83662
---
 drivers/net/ethernet/cadence/macb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 3256839..86a8e20 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -35,12 +35,12 @@
 
 #include "macb.h"
 
-#define MACB_RX_BUFFER_SIZE	128
+#define MACB_RX_BUFFER_SIZE	1536
 #define RX_BUFFER_MULTIPLE	64  /* bytes */
 #define RX_RING_SIZE		512 /* must be power of 2 */
 #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
 
-#define TX_RING_SIZE		128 /* must be power of 2 */
+#define TX_RING_SIZE		512 /* must be power of 2 */
 #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
 
 /* level of occupied TX descriptors under which we wake up TX process */
-- 
1.9.1
