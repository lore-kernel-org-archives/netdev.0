From: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Subject: [PATCH v6 03/25] io-mapping: Specify mapping size for io_mapping_map_wc()
Date: Tue, 26 Apr 2016 21:05:58 +0100
Message-ID: <1461701180-895-4-git-send-email-chris@chris-wilson.co.uk>
References: <1461701180-895-1-git-send-email-chris@chris-wilson.co.uk>
Cc: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>,
	Tvrtko Ursulin <tvrtko.ursulin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Daniel Vetter <daniel.vetter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jani Nikula <jani.nikula-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	David Airlie <airlied-cv59FeDIM0c@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"Peter Zijlstra (Intel)" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	David Hildenbrand <dahi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	"Luis R . Rodriguez" <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461701180-895-1-git-send-email-chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The ioremap() hidden behind the io_mapping_map_wc() convenience helper
can be used for remapping multiple pages. Extend the helper so that
future callers can use it for larger ranges.

Signed-off-by: Chris Wilson <chris-Y6uKTt2uX1cEflXRtASbqLVCufUGDwFn@public.gmane.org>
Cc: Tvrtko Ursulin <tvrtko.ursulin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Daniel Vetter <daniel.vetter-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Jani Nikula <jani.nikula-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Cc: David Airlie <airlied-cv59FeDIM0c@public.gmane.org>
Cc: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: "Peter Zijlstra (Intel)" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: David Hildenbrand <dahi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Luis R. Rodriguez <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Cc: dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Reviewed-by: Luis R. Rodriguez <mcgrof-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/gpu/drm/i915/intel_overlay.c    |  3 ++-
 drivers/net/ethernet/mellanox/mlx4/pd.c |  4 +++-
 include/linux/io-mapping.h              | 10 +++++++---
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/gpu/drm/i915/intel_overlay.c b/drivers/gpu/drm/i915/intel_overlay.c
index 06bcd6aee64f..8d5293644d05 100644
--- a/drivers/gpu/drm/i915/intel_overlay.c
+++ b/drivers/gpu/drm/i915/intel_overlay.c
@@ -198,7 +198,8 @@ intel_overlay_map_regs(struct intel_overlay *overlay)
 		regs = (struct overlay_registers __iomem *)overlay->reg_bo->phys_handle->vaddr;
 	else
 		regs = io_mapping_map_wc(ggtt->mappable,
-					 overlay->flip_addr);
+					 overlay->flip_addr,
+					 PAGE_SIZE);
 
 	return regs;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index b3cc3ab63799..6fc156a3918d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -205,7 +205,9 @@ int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf, int node)
 			goto free_uar;
 		}
 
-		uar->bf_map = io_mapping_map_wc(priv->bf_mapping, uar->index << PAGE_SHIFT);
+		uar->bf_map = io_mapping_map_wc(priv->bf_mapping,
+						uar->index << PAGE_SHIFT,
+						PAGE_SIZE);
 		if (!uar->bf_map) {
 			err = -ENOMEM;
 			goto unamp_uar;
diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
index e399029b68c5..645ad06b5d52 100644
--- a/include/linux/io-mapping.h
+++ b/include/linux/io-mapping.h
@@ -100,14 +100,16 @@ io_mapping_unmap_atomic(void __iomem *vaddr)
 }
 
 static inline void __iomem *
-io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
+io_mapping_map_wc(struct io_mapping *mapping,
+		  unsigned long offset,
+		  unsigned long size)
 {
 	resource_size_t phys_addr;
 
 	BUG_ON(offset >= mapping->size);
 	phys_addr = mapping->base + offset;
 
-	return ioremap_wc(phys_addr, PAGE_SIZE);
+	return ioremap_wc(phys_addr, size);
 }
 
 static inline void
@@ -155,7 +157,9 @@ io_mapping_unmap_atomic(void __iomem *vaddr)
 
 /* Non-atomic map/unmap */
 static inline void __iomem *
-io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
+io_mapping_map_wc(struct io_mapping *mapping,
+		  unsigned long offset,
+		  unsigned long size)
 {
 	return ((char __force __iomem *) mapping) + offset;
 }
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
