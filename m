From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 18/51] DMA-API: staging: et131x: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Thu, 19 Sep 2013 22:43:01 +0100
Message-ID: <E1VMm05-0007hG-5T@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Einon <mark.einon@gmail.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
 devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Replace the following sequence:

	dma_set_mask(dev, mask);
	dma_set_coherent_mask(dev, mask);

with a call to the new helper dma_set_mask_and_coherent().

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/staging/et131x/et131x.c |   17 ++---------------
 1 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index f73e58f..98edfa8 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -4797,21 +4797,8 @@ static int et131x_pci_setup(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	/* Check the DMA addressing support of this device */
-	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
-		rc = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
-		if (rc < 0) {
-			dev_err(&pdev->dev,
-			  "Unable to obtain 64 bit DMA for consistent allocations\n");
-			goto err_release_res;
-		}
-	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
-		rc = dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
-		if (rc < 0) {
-			dev_err(&pdev->dev,
-			  "Unable to obtain 32 bit DMA for consistent allocations\n");
-			goto err_release_res;
-		}
-	} else {
+	if (dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64)) ||
+	    dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32))) {
 		dev_err(&pdev->dev, "No usable DMA addressing method\n");
 		rc = -EIO;
 		goto err_release_res;
-- 
1.7.4.4
