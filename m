From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/12) skge: use PFX string
Date: Thu, 3 Mar 2005 11:45:57 -0800
Message-ID: <20050303114557.6373662b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use the PFX string consistently for all messages

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-test/drivers/net/skge.c	2005-03-02 17:37:08.000000000 -0800
+++ skge-test/drivers/net/skge.c.new	2005-03-02 17:36:57.000000000 -0800
@@ -3120,13 +3120,13 @@ static int __devinit skge_probe(struct p
 	int err, using_dac = 0;
 
 	if ((err = pci_enable_device(pdev))) {
-		printk(KERN_ERR "%s cannot enable PCI device\n",
+		printk(KERN_ERR PFX "%s cannot enable PCI device\n",
 		       pci_name(pdev));
 		goto err_out;
 	}
 
 	if ((err = pci_request_regions(pdev, DRV_NAME))) {
-		printk(KERN_ERR "%s cannot obtain PCI resources\n",
+		printk(KERN_ERR PFX "%s cannot obtain PCI resources\n",
 		       pci_name(pdev));
 		goto err_out_disable_pdev;
 	}
@@ -3136,7 +3136,7 @@ static int __devinit skge_probe(struct p
 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)))
 		using_dac = 1;
 	else if (!(err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
-		printk(KERN_ERR "%s no usable DMA configuration\n",
+		printk(KERN_ERR PFX "%s no usable DMA configuration\n",
 		       pci_name(pdev));
 		goto err_out_free_regions;
 	}
@@ -3155,7 +3155,7 @@ static int __devinit skge_probe(struct p
 	err = -ENOMEM;
 	hw = kmalloc(sizeof(*hw), GFP_KERNEL);
 	if (!hw) {
-		printk(KERN_ERR "skge %s: cannot allocate hardware struct\n",
+		printk(KERN_ERR PFX "%s: cannot allocate hardware struct\n",
 		       pci_name(pdev));
 		goto err_out_free_regions;
 	}
@@ -3167,13 +3167,13 @@ static int __devinit skge_probe(struct p
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
-		printk(KERN_ERR "skge %s: cannot map device registers\n",
+		printk(KERN_ERR PFX "%s: cannot map device registers\n",
 		       pci_name(pdev));
 		goto err_out_free_hw;
 	}
 
 	if ((err = request_irq(pdev->irq, skge_intr, SA_SHIRQ, DRV_NAME, hw))) {
-		printk(KERN_ERR "%s: cannot assign irq %d\n",
+		printk(KERN_ERR PFX "%s: cannot assign irq %d\n",
 		       pci_name(pdev), pdev->irq);
 		goto err_out_iounmap;
 	}
@@ -3194,7 +3194,7 @@ static int __devinit skge_probe(struct p
 		dev->features |= NETIF_F_HIGHDMA;
 
 	if ((err = register_netdev(dev))) {
-		printk(KERN_ERR  "%s: cannot register net device\n",
+		printk(KERN_ERR PFX "%s: cannot register net device\n",
 		       pci_name(pdev));
 		goto err_out_free_netdev;
 	}
