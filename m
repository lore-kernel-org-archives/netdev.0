From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/44] drm/exynos: don't use DMA_ERROR_CODE
Date: Thu,  8 Jun 2017 15:25:29 +0200
Message-ID: <20170608132609.32662-5-hch@lst.de>
References: <20170608132609.32662-1-hch@lst.de>
Cc: linux-kernel@vger.kernel.org
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org,
        linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org,
        linux-mips@linux-mips.org, openrisc@lists.librecores.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org,
        linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org,
        linux-samsung-soc@vger.kernel.org,
        iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DMA_ERROR_CODE already isn't a valid API to user for drivers and will
go away soon.  exynos_drm_fb_dma_addr uses it a an error return when
the passed in index is invalid, but the callers never check for it
but instead pass the address straight to the hardware.

Add a WARN_ON instead and just return 0.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/gpu/drm/exynos/exynos_drm_fb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/gpu/drm/exynos/exynos_drm_fb.c b/drivers/gpu/drm/exynos/exynos_drm_fb.c
index c77a5aced81a..d48fd7c918f8 100644
--- a/drivers/gpu/drm/exynos/exynos_drm_fb.c
+++ b/drivers/gpu/drm/exynos/exynos_drm_fb.c
@@ -181,8 +181,8 @@ dma_addr_t exynos_drm_fb_dma_addr(struct drm_framebuffer *fb, int index)
 {
 	struct exynos_drm_fb *exynos_fb = to_exynos_fb(fb);
 
-	if (index >= MAX_FB_BUFFER)
-		return DMA_ERROR_CODE;
+	if (WARN_ON_ONCE(index >= MAX_FB_BUFFER))
+		return 0;
 
 	return exynos_fb->dma_addr[index];
 }
-- 
2.11.0
