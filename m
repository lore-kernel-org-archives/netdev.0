From: Tobias Klauser <tklauser@nuerscht.ch>
Subject: [KJ] [PATCH] Use pci_set_dma_mask() instead of direct assignment of
	DMA mask
Date: Mon, 16 May 2005 19:15:11 +0200
Message-ID: <20050516171511.GA19983@nuerscht.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============31131402186817736=="
Cc: akpm@osdl.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: kernel-janitors@lists.osdl.org
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============31131402186817736==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The amd8111e driver directly assigns the DMA mask to the dma_mask
member of the struct pci_dev instead of using pci_set_dma_mask(). This
makes the call to pci_dma_supported() redundant as pci_set_dma_mask()
does this check.

I do not own this device so I only compile-tested this patch.

Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>

diff -urpN -X dontdiff linux-2.6.12-rc4/drivers/net/amd8111e.c linux-2.6.12-rc4~dma_mask/drivers/net/amd8111e.c
--- linux-2.6.12-rc4/drivers/net/amd8111e.c	2005-05-07 21:53:51.000000000 +0200
+++ linux-2.6.12-rc4~dma_mask/drivers/net/amd8111e.c	2005-05-16 19:11:30.349802984 +0200
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

--===============31131402186817736==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============31131402186817736==--
