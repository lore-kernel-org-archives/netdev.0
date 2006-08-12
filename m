From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 1/4] pfn_to_kaddr() for UML
Date: Sat, 12 Aug 2006 16:14:25 +0200
Message-ID: <20060812141425.30842.35004.sendpatchset@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
Cc: Indan Zupancic <indan@nul.nu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:54066 "EHLO
	amsfep14-int.chello.nl") by vger.kernel.org with ESMTP
	id S932525AbWHLOPN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 10:15:13 -0400
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
In-Reply-To: <20060812141415.30842.78695.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Update UML with a proper 'pfn_to_kaddr()' definition, the SROG allocator
uses it.

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
 
