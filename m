From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/15] sfc: don't call dma_supported
Date: Sat,  3 Oct 2015 17:19:35 +0200
Message-ID: <1443885579-7094-12-git-send-email-hch@lst.de>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
Cc: linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443885579-7094-1-git-send-email-hch@lst.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dma_set_mask already checks for a supported DMA mask before updating it,
the call to dma_supported is redundant.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/net/ethernet/sfc/efx.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 974637d..4abe886 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1247,11 +1247,9 @@ static int efx_init_io(struct efx_nic *efx)
 	 * masks event though they reject 46 bit masks.
 	 */
 	while (dma_mask > 0x7fffffffUL) {
-		if (dma_supported(&pci_dev->dev, dma_mask)) {
-			rc = dma_set_mask_and_coherent(&pci_dev->dev, dma_mask);
-			if (rc == 0)
-				break;
-		}
+		rc = dma_set_mask_and_coherent(&pci_dev->dev, dma_mask);
+		if (rc == 0)
+			break;
 		dma_mask >>= 1;
 	}
 	if (rc) {
-- 
1.9.1
