From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 15/51] DMA-API: net: b43legacy: replace
 dma_set_mask()+dma_set_coherent_mask() with new helper
Date: Thu, 19 Sep 2013 22:40:00 +0100
Message-ID: <E1VMlxA-0007gs-Ll@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
 Stefano Brivio <stefano.brivio@polimi.it>,
 Larry Finger <Larry.Finger@lwfinger.net>
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
 drivers/net/wireless/b43legacy/dma.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 42eb26c..b2ed179 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -806,12 +806,9 @@ static int b43legacy_dma_set_mask(struct b43legacy_wldev *dev, u64 mask)
 	/* Try to set the DMA mask. If it fails, try falling back to a
 	 * lower mask, as we can always also support a lower one. */
 	while (1) {
-		err = dma_set_mask(dev->dev->dma_dev, mask);
-		if (!err) {
-			err = dma_set_coherent_mask(dev->dev->dma_dev, mask);
-			if (!err)
-				break;
-		}
+		err = dma_set_mask_and_coherent(dev->dev->dma_dev, mask);
+		if (!err)
+			break;
 		if (mask == DMA_BIT_MASK(64)) {
 			mask = DMA_BIT_MASK(32);
 			fallback = true;
-- 
1.7.4.4
