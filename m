From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/9] pfn_to_kaddr() for UML
Date: Tue, 08 Aug 2006 21:33:35 +0200
Message-ID: <20060808193335.1396.67083.sendpatchset@lappy>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Cc: Daniel Phillips <phillips@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.46.243.16] ([213.46.243.16]:62078 "EHLO
	amsfep17-int.chello.nl") by vger.kernel.org with ESMTP
	id S1030240AbWHHTeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 15:34:12 -0400
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Update UML with a proper 'pfn_to_kaddr()' definition, the VM deadlock
avoidance framework uses it.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Daniel Phillips <phillips@google.com>

---
 include/asm-um/page.h |    2 ++
 1 file changed, 2 insertions(+)

Index: linux-2.6/include/asm-um/page.h
===================================================================
--- linux-2.6.orig/include/asm-um/page.h
+++ linux-2.6/include/asm-um/page.h
@@ -111,6 +111,8 @@ extern unsigned long uml_physmem;
 #define pfn_valid(pfn) ((pfn) < max_mapnr)
 #define virt_addr_valid(v) pfn_valid(phys_to_pfn(__pa(v)))
 
+#define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
+
 extern struct page *arch_validate(struct page *page, gfp_t mask, int order);
 #define HAVE_ARCH_VALIDATE
 
