From: Adrian Bunk <bunk@kernel.org>
Subject: [RFC: 2.6.28 patch] m68knommu: set NO_DMA
Date: Wed, 29 Oct 2008 12:15:47 +0200
Message-ID: <20081029101547.GB28224@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: gerg@uclinux.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753466AbYJ2KR1@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

m68knommu does not set the Kconfig NO_DMA variable, but also does
not provide the required functions, resulting in the following 
build error triggered by commit a40c24a13366e324bc0ff8c3bb107db89312c984
(net: Add SKB DMA mapping helper functions.):

<--  snip  -->

...
  LD      vmlinux
net/built-in.o: In function `skb_dma_unmap':
(.text+0xac5e): undefined reference to `dma_unmap_single'
net/built-in.o: In function `skb_dma_unmap':
(.text+0xac7a): undefined reference to `dma_unmap_page'
net/built-in.o: In function `skb_dma_map':
(.text+0xacdc): undefined reference to `dma_map_single'
net/built-in.o: In function `skb_dma_map':
(.text+0xace8): undefined reference to `dma_mapping_error'
net/built-in.o: In function `skb_dma_map':
(.text+0xad10): undefined reference to `dma_map_page'
net/built-in.o: In function `skb_dma_map':
(.text+0xad82): undefined reference to `dma_unmap_page'
net/built-in.o: In function `skb_dma_map':
(.text+0xadc6): undefined reference to `dma_unmap_single'
make[1]: *** [vmlinux] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

diff --git a/arch/m68knommu/Kconfig b/arch/m68knommu/Kconfig
index 76b66fe..d532687 100644
--- a/arch/m68knommu/Kconfig
+++ b/arch/m68knommu/Kconfig
@@ -14,6 +14,10 @@ config MMU
 	bool
 	default n
 
+config NO_DMA
+	bool
+	default y
+
 config FPU
 	bool
 	default n
