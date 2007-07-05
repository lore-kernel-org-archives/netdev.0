From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC 2/2] shrink size of scatterlist on common i386/x86-64
Date: Thu, 05 Jul 2007 16:14:14 -0700
Message-ID: <20070705231615.451797310@linux-foundation.org>
References: <20070705231412.021359760@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41609 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758538AbXGEXRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 19:17:40 -0400
Content-Disposition: inline; filename=scatterlist-shrink.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The scatterlist only needs 16 bits for length/offset because
PAGE_SIZE is 4K

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/asm-i386/scatterlist.h	2007-07-05 14:37:11.000000000 -0700
+++ b/include/asm-i386/scatterlist.h	2007-07-05 15:44:51.000000000 -0700
@@ -5,9 +5,9 @@
 
 struct scatterlist {
     struct page		*page;
-    unsigned int	offset;
     dma_addr_t		dma_address;
-    unsigned int	length;
+    u16			offset;
+    u16			length;
 };
 
 /* These macros should be used after a pci_map_sg call has been done
--- a/include/asm-x86_64/scatterlist.h	2007-07-05 14:37:11.000000000 -0700
+++ b/include/asm-x86_64/scatterlist.h	2007-07-05 15:46:49.000000000 -0700
@@ -5,10 +5,10 @@
 
 struct scatterlist {
     struct page		*page;
-    unsigned int	offset;
-    unsigned int	length;
     dma_addr_t		dma_address;
     unsigned int        dma_length;
+    u16			offset;
+    u16			length;
 };
 
 #define ISA_DMA_THRESHOLD (0x00ffffff)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

