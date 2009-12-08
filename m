From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/3] mm: export use_mm/unuse_mm to modules
Date: Tue, 8 Dec 2009 13:49:54 +1030
Message-ID: <200912081349.54715.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:55047 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935021AbZLHDTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 22:19:50 -0500
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>

vhost net module wants to do copy to/from user from a kernel thread,
which needs use_mm. Export it to modules.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 mm/mmu_context.c |    3 +++
 1 file changed, 3 insertions(+)

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

