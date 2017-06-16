From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 01/44] firmware/ivc: use dma_mapping_error
Date: Fri, 16 Jun 2017 20:10:16 +0200
Message-ID: <20170616181059.19206-2-hch@lst.de>
References: <20170616181059.19206-1-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
 linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
 linux-mips@linux-mips.org, openrisc@lists.librecores.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
 linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
 linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org,
 netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170616181059.19206-1-hch@lst.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

DMA_ERROR_CODE is not supposed to be used by drivers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Thierry Reding <treding@nvidia.com>
---
 drivers/firmware/tegra/ivc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/firmware/tegra/ivc.c b/drivers/firmware/tegra/ivc.c
index 29ecfd815320..a01461d63f68 100644
--- a/drivers/firmware/tegra/ivc.c
+++ b/drivers/firmware/tegra/ivc.c
@@ -646,12 +646,12 @@ int tegra_ivc_init(struct tegra_ivc *ivc, struct device *peer, void *rx,
 	if (peer) {
 		ivc->rx.phys = dma_map_single(peer, rx, queue_size,
 					      DMA_BIDIRECTIONAL);
-		if (ivc->rx.phys == DMA_ERROR_CODE)
+		if (dma_mapping_error(peer, ivc->rx.phys))
 			return -ENOMEM;
 
 		ivc->tx.phys = dma_map_single(peer, tx, queue_size,
 					      DMA_BIDIRECTIONAL);
-		if (ivc->tx.phys == DMA_ERROR_CODE) {
+		if (dma_mapping_error(peer, ivc->tx.phys)) {
 			dma_unmap_single(peer, ivc->rx.phys, queue_size,
 					 DMA_BIDIRECTIONAL);
 			return -ENOMEM;
-- 
2.11.0
