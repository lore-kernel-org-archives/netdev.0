From: domen@coderock.org
Subject: [patch 1/1] Use pci_set_dma_mask() instead of direct assignment of DMA mask
Date: Sun, 29 May 2005 01:16:55 +0200
Message-ID: <20050528231654.365592000@nd47.coderock.org>
Cc: netdev@oss.sgi.com, Tobias Klauser <tklauser@nuerscht.ch>,
        domen@coderock.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline; filename=dma_mask-drivers_net_amd8111e
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Tobias Klauser <tklauser@nuerscht.ch>


The amd8111e driver directly assigns the DMA mask to the dma_mask
member of the struct pci_dev instead of using pci_set_dma_mask(). This
makes the call to pci_dma_supported() redundant as pci_set_dma_mask()
does this check.

I do not own this device so I only compile-tested this patch.

Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
Signed-off-by: Domen Puncer <domen@coderock.org>

---
 amd8111e.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

Index: quilt/drivers/net/amd8111e.c
===================================================================
--- quilt.orig/drivers/net/amd8111e.c
+++ quilt/drivers/net/amd8111e.c
@@ -87,6 +87,7 @@ Revision History:
 #include <linux/if_vlan.h>
 #include <linux/ctype.h>	
 #include <linux/crc32.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
@@ -2002,12 +2003,11 @@ static int __devinit amd8111e_probe_one(
 	}
 
 	/* Initialize DMA */
-	if(!pci_dma_supported(pdev, 0xffffffff)){
+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) < 0) {
 		printk(KERN_ERR "amd8111e: DMA not supported,"
 			"exiting.\n");
-		goto  err_free_reg;
-	} else
-		pdev->dma_mask = 0xffffffff;
+		goto err_free_reg;
+	}
 	
 	reg_addr = pci_resource_start(pdev, 0);
 	reg_len = pci_resource_len(pdev, 0);

--
