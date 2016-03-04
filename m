From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 3/4] drm/vmwgfx: remove userland definition of DIV_ROUND_UP
Date: Fri,  4 Mar 2016 11:52:18 +0100
Message-ID: <1457088739-1065-4-git-send-email-nicolas.dichtel@6wind.com>
References: <20160303.170804.2300821465150459193.davem@davemloft.net>
 <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Airlie <airlied@linux.ie>,
	dri-devel@lists.freedesktop.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49072 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbcCDKws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 05:52:48 -0500
In-Reply-To: <1457088739-1065-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Let's use __KERNEL_DIV_ROUND_UP, which is defined in uapi/linux/kernel.h.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 .../drm/vmwgfx/device_include/svga3d_surfacedefs.h   | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h b/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h
index 58704f0a4607..531d22025fec 100644
--- a/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h
+++ b/drivers/gpu/drm/vmwgfx/device_include/svga3d_surfacedefs.h
@@ -25,6 +25,8 @@
  *
  **************************************************************************/
 
+#include <linux/kernel.h>
+
 #ifdef __KERNEL__
 
 #include <drm/vmwgfx_drm.h>
@@ -36,7 +38,6 @@
 #define ARRAY_SIZE(_A) (sizeof(_A) / sizeof((_A)[0]))
 #endif /* ARRAY_SIZE */
 
-#define DIV_ROUND_UP(x, y)  (((x) + (y) - 1) / (y))
 #define max_t(type, x, y)  ((x) > (y) ? (x) : (y))
 #define surf_size_struct SVGA3dSize
 #define u32 uint32
@@ -987,12 +988,12 @@ svga3dsurface_get_size_in_blocks(const struct svga3d_surface_desc *desc,
 				 const surf_size_struct *pixel_size,
 				 surf_size_struct *block_size)
 {
-	block_size->width = DIV_ROUND_UP(pixel_size->width,
-					 desc->block_size.width);
-	block_size->height = DIV_ROUND_UP(pixel_size->height,
-					  desc->block_size.height);
-	block_size->depth = DIV_ROUND_UP(pixel_size->depth,
-					 desc->block_size.depth);
+	block_size->width = __KERNEL_DIV_ROUND_UP(pixel_size->width,
+						  desc->block_size.width);
+	block_size->height = __KERNEL_DIV_ROUND_UP(pixel_size->height,
+						   desc->block_size.height);
+	block_size->depth = __KERNEL_DIV_ROUND_UP(pixel_size->depth,
+						  desc->block_size.depth);
 }
 
 static inline bool
@@ -1100,8 +1101,9 @@ svga3dsurface_get_pixel_offset(SVGA3dSurfaceFormat format,
 	const struct svga3d_surface_desc *desc = svga3dsurface_get_desc(format);
 	const u32 bw = desc->block_size.width, bh = desc->block_size.height;
 	const u32 bd = desc->block_size.depth;
-	const u32 rowstride = DIV_ROUND_UP(width, bw) * desc->bytes_per_block;
-	const u32 imgstride = DIV_ROUND_UP(height, bh) * rowstride;
+	const u32 rowstride = __KERNEL_DIV_ROUND_UP(width, bw) *
+			      desc->bytes_per_block;
+	const u32 imgstride = __KERNEL_DIV_ROUND_UP(height, bh) * rowstride;
 	const u32 offset = (z / bd * imgstride +
 			    y / bh * rowstride +
 			    x / bw * desc->bytes_per_block);
-- 
2.4.2
