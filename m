From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v4 19/19] PCI: Remove PCI pool macro functions
Date: Wed,  1 Mar 2017 16:55:21 +0100
Message-ID: <20170301155521.30281-20-romain.perier@collabora.com>
References: <20170301155521.30281-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:44441 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751982AbdCAP47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 10:56:59 -0500
In-Reply-To: <20170301155521.30281-1-romain.perier@collabora.com>
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
index 282ed32..d206ba4 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1281,15 +1281,6 @@ int pci_set_vga_state(struct pci_dev *pdev, bool decode,
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
2.9.3
