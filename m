From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next-2.6 2/3] mm: export use_mm/unuse_mm to modules
Date: Thu, 14 Jan 2010 18:17:18 +0200
Message-ID: <20100114161718.GC28159@redhat.com>
References: <cover.1263467513.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	"virtualization@lists.linux-foundation.org Michael S. Tsirkin"
	<mst@redhat.com>, Herbert Xu <herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756788Ab0ANQUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 11:20:45 -0500
Content-Disposition: inline
In-Reply-To: <cover.1263467513.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vhost net module wants to do copy to/from user from a kernel thread,
which needs use_mm. Export it to modules.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 mm/mmu_context.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/mmu_context.c b/mm/mmu_context.c
index ded9081..0777654 100644
--- a/mm/mmu_context.c
+++ b/mm/mmu_context.c
@@ -5,6 +5,7 @@
 
 #include <linux/mm.h>
 #include <linux/mmu_context.h>
+#include <linux/module.h>
 #include <linux/sched.h>
 
 #include <asm/mmu_context.h>
@@ -37,6 +38,7 @@ void use_mm(struct mm_struct *mm)
 	if (active_mm != mm)
 		mmdrop(active_mm);
 }
+EXPORT_SYMBOL_GPL(use_mm);
 
 /*
  * unuse_mm
@@ -56,3 +58,4 @@ void unuse_mm(struct mm_struct *mm)
 	enter_lazy_tlb(mm, tsk);
 	task_unlock(tsk);
 }
+EXPORT_SYMBOL_GPL(unuse_mm);
-- 
1.6.6.144.g5c3af

