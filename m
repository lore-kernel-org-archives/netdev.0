From: Adrian Bunk <bunk@kernel.org>
Subject: m68knommu, net and DMA compile error
Date: Sun, 12 Oct 2008 14:15:47 +0300
Message-ID: <20081012111547.GE31153@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: gerg@uclinux.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:45047 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbYJLLQn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 07:16:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the CONFIG_PCI=n case (the PCI code will be removed during this merge 
window) m68knommu does not set the Kconfig NO_DMA variable, but also 
does not provide the required functions, resulting in the following 
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


cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed


