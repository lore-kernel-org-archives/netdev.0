From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 9/11] r8169: advertise DMA to high memory
Date: Tue, 24 Aug 2004 00:56:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823225620.GI20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com> <20040823225335.GG20726@electric-eye.fr.zoreil.com> <20040823225505.GH20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823225505.GH20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Advertise the ability to DMA to high memory.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-090 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-090	2004-08-23 23:30:06.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:06.000000000 +0200
@@ -1029,10 +1029,10 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	tp->cp_cmd = PCIMulRW | RxChkSum;
 
-	if ((sizeof(dma_addr_t) > 32) &&
-	    !pci_set_dma_mask(pdev, DMA_64BIT_MASK))
+	if ((sizeof(dma_addr_t) > 32) && !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		tp->cp_cmd |= PCIDAC;
-	else {
+		dev->features |= NETIF_F_HIGHDMA;
+	} else {
 		rc = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (rc < 0) {
 			printk(KERN_ERR PFX "DMA configuration failed.\n");
@@ -1040,7 +1040,6 @@ rtl8169_init_board(struct pci_dev *pdev,
 		}
 	}
 
-
 	pci_set_master(pdev);
 
 	// ioremap MMIO region 

_
