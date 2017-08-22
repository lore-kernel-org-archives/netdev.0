From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v12 8/8] PCI: Remove PCI pool macro functions
Date: Tue, 22 Aug 2017 13:47:01 +0200
Message-ID: <20170822114701.14907-9-romain.perier@collabora.com>
References: <20170822114701.14907-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Romain Perier <romain.perier@collabora.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:42292 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932789AbdHVLri (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 07:47:38 -0400
In-Reply-To: <20170822114701.14907-1-romain.perier@collabora.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that all the drivers use dma pool API, we can remove the macro
functions for PCI pool.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 include/linux/pci.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/include/linux/pci.h b/include/linux/pci.h
index 93af1070c134..e01f329cd3dc 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1300,15 +1300,6 @@ int pci_set_vga_state(struct pci_dev *pdev, bool decode,
 #include <linux/pci-dma.h>
 #include <linux/dmapool.h>
 
-#define	pci_pool dma_pool
-#define pci_pool_create(name, pdev, size, align, allocation) \
-		dma_pool_create(name, &pdev->dev, size, align, allocation)
-#define	pci_pool_destroy(pool) dma_pool_destroy(pool)
-#define	pci_pool_alloc(pool, flags, handle) dma_pool_alloc(pool, flags, handle)
-#define	pci_pool_zalloc(pool, flags, handle) \
-		dma_pool_zalloc(pool, flags, handle)
-#define	pci_pool_free(pool, vaddr, addr) dma_pool_free(pool, vaddr, addr)
-
 struct msix_entry {
 	u32	vector;	/* kernel uses to write allocated vector */
 	u16	entry;	/* driver uses to specify entry, OS writes */
-- 
2.11.0
