From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc1-mm1 1/1] r8169: DAC support fix
Date: Tue, 31 Aug 2004 00:00:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830220045.GB22994@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wrong unit for sizeof().

diff -puN drivers/net/r8169.c~r8169-120 drivers/net/r8169.c
--- linux-2.6.9-rc1/drivers/net/r8169.c~r8169-120	2004-08-30 23:39:04.000000000 +0200
+++ linux-2.6.9-rc1-fr/drivers/net/r8169.c	2004-08-30 23:39:20.000000000 +0200
@@ -1152,7 +1152,7 @@ rtl8169_init_board(struct pci_dev *pdev,
 
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
-	if ((sizeof(dma_addr_t) > 32) && !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
+	if ((sizeof(dma_addr_t) > 4) && !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
 		tp->cp_cmd |= PCIDAC;
 		dev->features |= NETIF_F_HIGHDMA;
 	} else {

_
