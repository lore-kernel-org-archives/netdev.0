From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (4/9) freenetdev - tokenring changes
Date: Tue, 19 Aug 2003 12:18:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819121819.202ddcdb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

s/kfree/free_netdev/ as appropriate for tokenring drivers.

diff -Nru a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
--- a/drivers/net/tokenring/3c359.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/tokenring/3c359.c	Tue Aug 19 09:04:32 2003
@@ -1787,7 +1787,7 @@
 	iounmap(xl_priv->xl_mmio) ; 
 	pci_release_regions(pdev) ; 
 	pci_set_drvdata(pdev,NULL) ; 
-	kfree(dev);
+	free_netdev(dev);
 	return ; 
 }
 
diff -Nru a/drivers/net/tokenring/abyss.c b/drivers/net/tokenring/abyss.c
--- a/drivers/net/tokenring/abyss.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/tokenring/abyss.c	Tue Aug 19 09:04:31 2003
@@ -443,7 +443,7 @@
 	release_region(dev->base_addr-0x10, ABYSS_IO_EXTENT);
 	free_irq(dev->irq, dev);
 	tmsdev_term(dev);
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/tokenring/ibmtr.c	Tue Aug 19 09:04:31 2003
@@ -1975,7 +1975,7 @@
 			iounmap((u32 *)ti->sram_virt);
 		}
 #endif		
-		kfree(dev_ibmtr[i]);
+		free_netdev(dev_ibmtr[i]);
 		dev_ibmtr[i] = NULL;
 	}
 }
diff -Nru a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
--- a/drivers/net/tokenring/lanstreamer.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/tokenring/lanstreamer.c	Tue Aug 19 09:04:32 2003
@@ -433,7 +433,7 @@
 	/* shouldn't we do iounmap here? */
 	release_region(pci_resource_start(pdev, 0), pci_resource_len(pdev,0));
 	release_mem_region(pci_resource_start(pdev, 1), pci_resource_len(pdev,1));
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
--- a/drivers/net/tokenring/madgemc.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/tokenring/madgemc.c	Tue Aug 19 09:04:32 2003
@@ -774,7 +774,7 @@
 		release_region(dev->base_addr-MADGEMC_SIF_OFFSET, MADGEMC_IO_EXTENT);
 		free_irq(dev->irq, dev);
 		tmsdev_term(dev);
-		kfree(dev);
+		free_netdev(dev);
 		this_card = madgemc_card_list;
 		madgemc_card_list = this_card->next;
 		kfree(this_card);
diff -Nru a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
--- a/drivers/net/tokenring/olympic.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/tokenring/olympic.c	Tue Aug 19 09:04:32 2003
@@ -1779,7 +1779,7 @@
 	iounmap(olympic_priv->olympic_lap) ; 
 	pci_release_regions(pdev) ;
 	pci_set_drvdata(pdev,NULL) ;  	
-	kfree(dev) ; 
+	free_netdev(dev) ; 
 }
 
 static struct pci_driver olympic_driver = { 
diff -Nru a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
--- a/drivers/net/tokenring/proteon.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/tokenring/proteon.c	Tue Aug 19 09:04:32 2003
@@ -436,7 +436,7 @@
 		free_irq(dev->irq, dev);
 		free_dma(dev->dma);
 		tmsdev_term(dev);
-		kfree(dev);
+		free_netdev(dev);
 		this_card = proteon_card_list;
 		proteon_card_list = this_card->next;
 		kfree(this_card);
diff -Nru a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
--- a/drivers/net/tokenring/skisa.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/tokenring/skisa.c	Tue Aug 19 09:04:31 2003
@@ -449,7 +449,7 @@
 		free_irq(dev->irq, dev);
 		free_dma(dev->dma);
 		tmsdev_term(dev);
-		kfree(dev);
+		free_netdev(dev);
 		this_card = sk_isa_card_list;
 		sk_isa_card_list = this_card->next;
 		kfree(this_card);
diff -Nru a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
--- a/drivers/net/tokenring/smctr.c	Tue Aug 19 09:04:31 2003
+++ b/drivers/net/tokenring/smctr.c	Tue Aug 19 09:04:31 2003
@@ -5730,7 +5730,7 @@
 		if (dev) {
 			unregister_netdev(dev);
 			cleanup_card(dev);
-			kfree(dev);
+			free_netdev(dev);
 		}
         }
 }
diff -Nru a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
--- a/drivers/net/tokenring/tmspci.c	Tue Aug 19 09:04:32 2003
+++ b/drivers/net/tokenring/tmspci.c	Tue Aug 19 09:04:32 2003
@@ -229,7 +229,7 @@
 	release_region(dev->base_addr, TMS_PCI_IO_EXTENT);
 	free_irq(dev->irq, dev);
 	tmsdev_term(dev);
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
