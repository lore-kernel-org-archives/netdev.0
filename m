From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 04/10] [TULIP] Flush MMIO writes in reset sequence
Date: Fri, 25 Aug 2006 17:02:31 -0700
Message-ID: <20060826000303.287410000@linux.intel.com>
References: <20060826000227.818796000@linux.intel.com>
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>,
	Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932293AbWHZADj@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline; filename=tulip-flush-mmio-writes-in-reset-sequence
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

The obvious safe registers to read is one from PCI config space.

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Signed-off-by: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/tulip_core.c |    2 ++
 1 files changed, 2 insertions(+)

--- linux-2.6.18-rc4-mm1.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.18-rc4-mm1/drivers/net/tulip/tulip_core.c
@@ -295,12 +295,14 @@ static void tulip_up(struct net_device *
 
 	/* Reset the chip, holding bit 0 set at least 50 PCI cycles. */
 	iowrite32(0x00000001, ioaddr + CSR0);
+	pci_read_config_dword(tp->pdev, PCI_COMMAND, &i);  /* flush write */
 	udelay(100);
 
 	/* Deassert reset.
 	   Wait the specified 50 PCI cycles after a reset by initializing
 	   Tx and Rx queues and the address filter list. */
 	iowrite32(tp->csr0, ioaddr + CSR0);
+	pci_read_config_dword(tp->pdev, PCI_COMMAND, &i);  /* flush write */
 	udelay(100);
 
 	if (tulip_debug > 1)

--
