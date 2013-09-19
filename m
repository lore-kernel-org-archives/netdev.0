From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 48/51] ARM: 7795/1: mm: dma-mapping: Add
 dma_max_pfn(dev) helper function
Date: Fri, 20 Sep 2013 00:41:06 +0100
Message-ID: <E1VMnqM-00026g-PP@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vinod Koul <vinod.koul@intel.com>, Jens Axboe <axboe@kernel.dk>,
 Dan Williams <dan.j.williams@intel.com>
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

From: Santosh Shilimkar <santosh.shilimkar@ti.com>

Most of the kernel assumes that PFN0 is the start of the physical
memory (RAM). This assumptions is not true on most of the ARM SOCs
and hence and if one try to update the ARM port to follow the assumptions,
we end of breaking the dma bounce limit for few block layer drivers.
One such example is trying to unify the meaning of max*_pfn on ARM
as the bootmem layer expects, breaks few block layer driver dma
bounce limit.

To fix this problem, we introduce dma_max_pfn(dev) generic helper with
a possibility of override from the architecture code. The helper converts
a DMA bitmask of bits to a block PFN number. In all the generic cases,
it is just  "dev->dma_mask >> PAGE_SHIFT" and hence default behavior
is maintained as is.

Subsequent patches will make use of the helper. No functional change.

Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 include/linux/dma-mapping.h |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 27d1421..fd4aee2 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -153,6 +153,13 @@ static inline int dma_set_seg_boundary(struct device *dev, unsigned long mask)
 		return -EIO;
 }
 
+#ifndef dma_max_pfn
+static inline unsigned long dma_max_pfn(struct device *dev)
+{
+	return *dev->dma_mask >> PAGE_SHIFT;
+}
+#endif
+
 static inline void *dma_zalloc_coherent(struct device *dev, size_t size,
 					dma_addr_t *dma_handle, gfp_t flag)
 {
-- 
1.7.4.4
