From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.5.70] Add release_netdev -- hook for sysfs/net device
 cleanup
Date: Fri, 6 Jun 2003 16:07:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030606160739.0581bf39.shemminger@osdl.org>
References: <20030606145835.3a263df8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030606145835.3a263df8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a patch to convert the "easy" drivers to use release_netdev, instead of directly
freeing the net_device.  They all compile but only e100 and e1000 have been tested with
real hardware.

diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/3c59x.c	Thu Jun  5 15:51:50 2003
@@ -1021,7 +1021,7 @@
 	outw (TotalReset|0x14, ioaddr + EL3_CMD);
 	release_region (ioaddr, VORTEX_TOTAL_SIZE);
 
-	kfree (dev);
+	release_netdev (dev);
 	return 0;
 }
 #endif
@@ -3072,7 +3072,7 @@
 						vp->rx_ring_dma);
 	if (vp->must_free_region)
 		release_region(dev->base_addr, vp->io_size);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 
diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/8139cp.c	Thu Jun  5 15:51:50 2003
@@ -1969,7 +1969,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 #ifdef CONFIG_PM
diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/8139too.c	Thu Jun  5 15:51:50 2003
@@ -721,7 +721,7 @@
 		sizeof (struct rtl8139_private));
 #endif /* RTL8139_NDEBUG */
 
-	kfree (dev);
+	release_netdev (dev);
 
 	pci_set_drvdata (pdev, NULL);
 }
diff -Nru a/drivers/net/a2065.c b/drivers/net/a2065.c
--- a/drivers/net/a2065.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/a2065.c	Thu Jun  5 15:51:50 2003
@@ -820,7 +820,7 @@
 		release_mem_region(ZTWO_PADDR(dev->base_addr),
 				   sizeof(struct lance_regs));
 		release_mem_region(ZTWO_PADDR(dev->mem_start), A2065_RAM_SIZE);
-		kfree(dev);
+		release_netdev(dev);
 		root_a2065_dev = next;
 	}
 #endif
diff -Nru a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
--- a/drivers/net/amd8111e.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/amd8111e.c	Thu Jun  5 15:51:50 2003
@@ -1709,7 +1709,7 @@
 	if (dev) {
 		unregister_netdev(dev);
 		iounmap((void *) ((struct amd8111e_priv *)(dev->priv))->mmio);
-		kfree(dev);
+		release_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/ariadne.c b/drivers/net/ariadne.c
--- a/drivers/net/ariadne.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/ariadne.c	Thu Jun  5 15:51:50 2003
@@ -852,7 +852,7 @@
 	unregister_netdev(dev);
 	release_mem_region(ZTWO_PADDR(dev->base_addr), sizeof(struct Am79C960));
 	release_mem_region(ZTWO_PADDR(dev->mem_start), ARIADNE_RAM_SIZE);
-	kfree(dev);
+	release_netdev(dev);
 	root_ariadne_dev = next;
     }
 #endif
diff -Nru a/drivers/net/ariadne2.c b/drivers/net/ariadne2.c
--- a/drivers/net/ariadne2.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/ariadne2.c	Thu Jun  5 15:51:50 2003
@@ -413,7 +413,7 @@
 	unregister_netdev(dev);
 	free_irq(IRQ_AMIGA_PORTS, dev);
 	release_mem_region(ZTWO_PADDR(dev->base_addr), NE_IO_EXTENT*2);
-	kfree(dev);
+	release_netdev(dev);
 	root_ariadne2_dev = next;
     }
 #endif
diff -Nru a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
--- a/drivers/net/arm/am79c961a.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/arm/am79c961a.c	Thu Jun  5 15:51:50 2003
@@ -677,7 +677,7 @@
 	release_region(dev->base_addr, 0x18);
 nodev:
 	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 out:
 	return ret;
 }
diff -Nru a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
--- a/drivers/net/arm/ether1.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/arm/ether1.c	Thu Jun  5 15:51:50 2003
@@ -1058,7 +1058,7 @@
 	release_region(dev->base_addr, 16);
 	release_region(dev->base_addr + 0x800, 4096);
 	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 out:
 	return ret;
 }
@@ -1073,7 +1073,7 @@
 
 	release_region(dev->base_addr, 16);
 	release_region(dev->base_addr + 0x800, 4096);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static const struct ecard_id ether1_ids[] = {
diff -Nru a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
--- a/drivers/net/arm/ether3.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/arm/ether3.c	Thu Jun  5 15:51:50 2003
@@ -899,7 +899,7 @@
 	release_region(dev->base_addr, 128);
 free:
 	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 out:
 	return ret;
 }
@@ -912,7 +912,7 @@
 
 	unregister_netdev(dev);
 	release_region(dev->base_addr, 128);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static const struct ecard_id ether3_ids[] = {
diff -Nru a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
--- a/drivers/net/au1000_eth.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/au1000_eth.c	Thu Jun  5 15:51:50 2003
@@ -823,7 +823,7 @@
 				MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS));
 	printk(KERN_ERR "%s: au1000_probe1 failed.  Returns %d\n",
 	       dev->name, retval);
-	kfree(dev);
+	release_netdev(dev);
 	return retval;
 }
 
diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/b44.c	Thu Jun  5 15:51:50 2003
@@ -1830,7 +1830,7 @@
 	if (dev) {
 		unregister_netdev(dev);
 		iounmap((void *) ((struct b44 *)(dev->priv))->regs);
-		kfree(dev);
+		release_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/bmac.c b/drivers/net/bmac.c
--- a/drivers/net/bmac.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/bmac.c	Thu Jun  5 15:51:50 2003
@@ -1452,7 +1452,7 @@
 		pmac_call_feature(PMAC_FTR_BMAC_ENABLE, bp->node, 0, 0);
 	}
 	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static int bmac_open(struct net_device *dev)
@@ -1710,7 +1710,7 @@
 		free_irq(bp->tx_dma_intr, dev);
 		free_irq(bp->rx_dma_intr, dev);
 
-		kfree(dev);
+		release_netdev(dev);
 	} while (bmac_devs != NULL);
 }
 
diff -Nru a/drivers/net/declance.c b/drivers/net/declance.c
--- a/drivers/net/declance.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/declance.c	Thu Jun  5 15:51:50 2003
@@ -1203,7 +1203,7 @@
 
 err_out:
 	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 	return ret;
 }
 
diff -Nru a/drivers/net/dl2k.c b/drivers/net/dl2k.c
--- a/drivers/net/dl2k.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/dl2k.c	Thu Jun  5 15:51:50 2003
@@ -1844,7 +1844,7 @@
 #ifdef MEM_MAPPING
 		iounmap ((char *) (dev->base_addr));
 #endif
-		kfree (dev);
+		release_netdev (dev);
 		pci_release_regions (pdev);
 		pci_disable_device (pdev);
 	}
diff -Nru a/drivers/net/e100/e100_main.c b/drivers/net/e100/e100_main.c
--- a/drivers/net/e100/e100_main.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/e100/e100_main.c	Thu Jun  5 15:51:50 2003
@@ -716,7 +716,7 @@
 	e100_dealloc_space(bdp);
 err_dev:
 	pci_set_drvdata(pcid, NULL);
-	kfree(dev);
+	release_netdev(dev);
 out:
 	return rc;
 }
@@ -738,7 +738,7 @@
 
 	e100_dealloc_space(bdp);
 	pci_set_drvdata(bdp->pdev, NULL);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static void __devexit
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/e1000/e1000_main.c	Thu Jun  5 15:51:50 2003
@@ -542,7 +542,7 @@
 	iounmap(adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 
-	kfree(netdev);
+	release_netdev(netdev);
 }
 
 /**
diff -Nru a/drivers/net/eepro100.c b/drivers/net/eepro100.c
--- a/drivers/net/eepro100.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/eepro100.c	Thu Jun  5 15:51:50 2003
@@ -2364,7 +2364,7 @@
 								+ sizeof(struct speedo_stats),
 						sp->tx_ring, sp->tx_ring_dma);
 	pci_disable_device(pdev);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static struct pci_device_id eepro100_pci_tbl[] __devinitdata = {
diff -Nru a/drivers/net/epic100.c b/drivers/net/epic100.c
--- a/drivers/net/epic100.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/epic100.c	Thu Jun  5 15:51:50 2003
@@ -1482,7 +1482,7 @@
 	iounmap((void*) dev->base_addr);
 #endif
 	pci_release_regions(pdev);
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 	/* pci_power_off(pdev, -1); */
 }
diff -Nru a/drivers/net/fealnx.c b/drivers/net/fealnx.c
--- a/drivers/net/fealnx.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/fealnx.c	Thu Jun  5 15:51:50 2003
@@ -712,7 +712,7 @@
 #ifndef USE_IO_OPS
 		iounmap((void *)dev->base_addr);
 #endif
-		kfree(dev);
+		release_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
 	} else
diff -Nru a/drivers/net/hamachi.c b/drivers/net/hamachi.c
--- a/drivers/net/hamachi.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/hamachi.c	Thu Jun  5 15:51:50 2003
@@ -1976,7 +1976,7 @@
 			hmp->tx_ring_dma);
 		unregister_netdev(dev);
 		iounmap((char *)dev->base_addr);
-		kfree(dev);
+		release_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
 	}
diff -Nru a/drivers/net/hydra.c b/drivers/net/hydra.c
--- a/drivers/net/hydra.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/hydra.c	Thu Jun  5 15:51:50 2003
@@ -243,7 +243,7 @@
 	unregister_netdev(dev);
 	free_irq(IRQ_AMIGA_PORTS, dev);
 	release_mem_region(ZTWO_PADDR(dev->base_addr)-HYDRA_NIC_BASE, 0x10000);
-	kfree(dev);
+	release_netdev(dev);
 	root_hydra_dev = next;
     }
 #endif
diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/ixgb/ixgb_main.c	Thu Jun  5 15:51:50 2003
@@ -478,7 +478,7 @@
 	iounmap((void *) adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 
-	kfree(netdev);
+	release_netdev(netdev);
 }
 
 /**
diff -Nru a/drivers/net/mace.c b/drivers/net/mace.c
--- a/drivers/net/mace.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/mace.c	Thu Jun  5 15:51:50 2003
@@ -254,7 +254,7 @@
 		release_OF_resource(mp->of_node, 1);
 		release_OF_resource(mp->of_node, 2);
 	}
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static void dbdma_reset(volatile struct dbdma_regs *dma)
@@ -976,7 +976,7 @@
 		release_OF_resource(mp->of_node, 1);
 		release_OF_resource(mp->of_node, 2);
 
-		kfree(dev);
+		release_netdev(dev);
     }
     if (dummy_buf != NULL) {
 		kfree(dummy_buf);
diff -Nru a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
--- a/drivers/net/myri_sbus.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/myri_sbus.c	Thu Jun  5 15:51:50 2003
@@ -1090,7 +1090,7 @@
 	return 0;
 err:	unregister_netdev(dev);
 	/* This will also free the co-allocated 'dev->priv' */
-	kfree(dev);
+	release_netdev(dev);
 	return -ENODEV;
 }
 
diff -Nru a/drivers/net/natsemi.c b/drivers/net/natsemi.c
--- a/drivers/net/natsemi.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/natsemi.c	Thu Jun  5 15:51:50 2003
@@ -838,7 +838,7 @@
 	if (i) {
 		pci_release_regions(pdev);
 		unregister_netdev(dev);
-		kfree(dev);
+		release_netdev(dev);
 		pci_set_drvdata(pdev, NULL);
 		return i;
 	}
diff -Nru a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
--- a/drivers/net/ne2k-pci.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/ne2k-pci.c	Thu Jun  5 15:51:50 2003
@@ -635,7 +635,7 @@
 
 	unregister_netdev(dev);
 	release_region(dev->base_addr, NE_IO_EXTENT);
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
--- a/drivers/net/pci-skeleton.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/pci-skeleton.c	Thu Jun  5 15:51:50 2003
@@ -871,7 +871,7 @@
 		sizeof (struct netdrv_private));
 #endif /* NETDRV_NDEBUG */
 
-	kfree (dev);
+	release_netdev (dev);
 
 	pci_set_drvdata (pdev, NULL);
 
diff -Nru a/drivers/net/pcmcia/ibmtr_cs.c b/drivers/net/pcmcia/ibmtr_cs.c
--- a/drivers/net/pcmcia/ibmtr_cs.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/pcmcia/ibmtr_cs.c	Thu Jun  5 15:51:50 2003
@@ -310,7 +310,7 @@
     /* Unlink device structure, free bits */
     *linkp = link->next;
     unregister_netdev(dev);
-    kfree(dev);
+    release_netdev(dev);
 } /* ibmtr_detach */
 
 /*======================================================================
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/pcnet32.c	Thu Jun  5 15:51:50 2003
@@ -1762,7 +1762,7 @@
 	if (lp->pci_dev)
 	    pci_unregister_driver(&pcnet32_driver);
 	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-	kfree(pcnet32_dev);
+	release_netdev(pcnet32_dev);
 	pcnet32_dev = next_dev;
     }
 }
diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/r8169.c	Thu Jun  5 15:51:50 2003
@@ -646,7 +646,7 @@
 	       sizeof (struct net_device) + sizeof (struct rtl8169_private));
 
 	pci_disable_device(pdev);
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/rrunner.c b/drivers/net/rrunner.c
--- a/drivers/net/rrunner.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/rrunner.c	Thu Jun  5 15:51:50 2003
@@ -253,7 +253,7 @@
 				    rr->tx_ring_dma);
 		unregister_netdev(dev);
 		iounmap(rr->regs);
-		kfree(dev);
+		release_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/sis900.c	Thu Jun  5 15:51:50 2003
@@ -493,7 +493,7 @@
  	pci_set_drvdata(pci_dev, NULL);
 	pci_release_regions(pci_dev);
  err_out:
-	kfree(net_dev);
+	release_netdev(net_dev);
 	return ret;
 }
 
@@ -2189,7 +2189,7 @@
 	pci_free_consistent(pci_dev, TX_TOTAL_SIZE, sis_priv->tx_ring,
 		sis_priv->tx_ring_dma);
 	unregister_netdev(net_dev);
-	kfree(net_dev);
+	release_netdev(net_dev);
 	pci_release_regions(pci_dev);
 	pci_set_drvdata(pci_dev, NULL);
 }
diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/skfp/skfddi.c	Thu Jun  5 15:51:50 2003
@@ -2633,7 +2633,7 @@
 	}
 	unregister_netdev(p);
 	printk("%s: unloaded\n", p->name);
-	kfree(p);		/* Free the device structure */
+	release_netdev(p);		/* Free the device structure */
 
 	return next;
 }				// unlink_modules
diff -Nru a/drivers/net/starfire.c b/drivers/net/starfire.c
--- a/drivers/net/starfire.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/starfire.c	Thu Jun  5 15:51:50 2003
@@ -2196,7 +2196,7 @@
 	pci_release_regions(pdev);
 
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);			/* Will also free np!! */
+	release_netdev(dev);			/* Will also free np!! */
 }
 
 
diff -Nru a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
--- a/drivers/net/sunbmac.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/sunbmac.c	Thu Jun  5 15:51:50 2003
@@ -1209,7 +1209,7 @@
 
 	unregister_netdev(dev);
 	/* This also frees the co-located 'dev->priv' */
-	kfree(dev);
+	release_netdev(dev);
 	return -ENODEV;
 }
 
diff -Nru a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/sundance.c	Thu Jun  5 15:51:50 2003
@@ -730,7 +730,7 @@
 #endif
 	pci_release_regions(pdev);
 err_out_netdev:
-	kfree (dev);
+	release_netdev(dev);
 	return -ENODEV;
 }
 
@@ -1784,7 +1784,7 @@
 #ifndef USE_IO_OPS
 		iounmap((char *)(dev->base_addr));
 #endif
-		kfree(dev);
+		release_netdev(dev);
 		pci_set_drvdata(pdev, NULL);
 	}
 }
diff -Nru a/drivers/net/sungem.c b/drivers/net/sungem.c
--- a/drivers/net/sungem.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/sungem.c	Thu Jun  5 15:51:50 2003
@@ -2885,7 +2885,7 @@
 				    gp->gblock_dvma);
 		iounmap((void *) gp->regs);
 		pci_release_regions(pdev);
-		kfree(dev);
+		release_netdev(dev);
 
 		pci_set_drvdata(pdev, NULL);
 	}
diff -Nru a/drivers/net/sunhme.c b/drivers/net/sunhme.c
--- a/drivers/net/sunhme.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/sunhme.c	Thu Jun  5 15:51:50 2003
@@ -3351,7 +3351,7 @@
 			pci_release_regions(hp->happy_dev);
 		}
 #endif
-		kfree(dev);
+		release_netdev(dev);
 
 		root_happy_dev = next;
 	}
diff -Nru a/drivers/net/tc35815.c b/drivers/net/tc35815.c
--- a/drivers/net/tc35815.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tc35815.c	Thu Jun  5 15:51:50 2003
@@ -1762,7 +1762,7 @@
 		next_dev = ((struct tc35815_local *)dev->priv)->next_module;
 		iounmap((void *)(dev->base_addr));
 		unregister_netdev(dev);
-		kfree(dev);
+		release_netdev(dev);
 		root_tc35815_dev = next_dev;
 	}
 }
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tg3.c	Thu Jun  5 15:51:50 2003
@@ -6942,7 +6942,7 @@
 	if (dev) {
 		unregister_netdev(dev);
 		iounmap((void *) ((struct tg3 *)(dev->priv))->regs);
-		kfree(dev);
+		release_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tlan.c	Thu Jun  5 15:51:50 2003
@@ -447,7 +447,7 @@
 
 	pci_release_regions(pdev);
 	
-	kfree( dev );
+	release_netdev( dev );
 		
 	pci_set_drvdata( pdev, NULL );
 } 
@@ -695,7 +695,7 @@
 		release_region( dev->base_addr, 0x10);
 		unregister_netdev( dev );
 		TLan_Eisa_Devices = priv->nextDevice;
-		kfree( dev );
+		release_netdev( dev );
 		tlan_have_eisa--;
 	}
 }
diff -Nru a/drivers/net/tokenring/abyss.c b/drivers/net/tokenring/abyss.c
--- a/drivers/net/tokenring/abyss.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tokenring/abyss.c	Thu Jun  5 15:51:50 2003
@@ -443,7 +443,7 @@
 	release_region(dev->base_addr-0x10, ABYSS_IO_EXTENT);
 	free_irq(dev->irq, dev);
 	tmsdev_term(dev);
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
--- a/drivers/net/tokenring/lanstreamer.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tokenring/lanstreamer.c	Thu Jun  5 15:51:50 2003
@@ -433,7 +433,7 @@
 	/* shouldn't we do iounmap here? */
 	release_region(pci_resource_start(pdev, 0), pci_resource_len(pdev,0));
 	release_mem_region(pci_resource_start(pdev, 1), pci_resource_len(pdev,1));
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
--- a/drivers/net/tokenring/olympic.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tokenring/olympic.c	Thu Jun  5 15:51:50 2003
@@ -1778,7 +1778,7 @@
 	iounmap(olympic_priv->olympic_lap) ; 
 	pci_release_regions(pdev) ;
 	pci_set_drvdata(pdev,NULL) ;  	
-	kfree(dev) ; 
+	release_netdev(dev) ; 
 }
 
 static struct pci_driver olympic_driver = { 
diff -Nru a/drivers/net/tokenring/smctr.c b/drivers/net/tokenring/smctr.c
--- a/drivers/net/tokenring/smctr.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tokenring/smctr.c	Thu Jun  5 15:51:50 2003
@@ -5730,7 +5730,7 @@
 		if (dev) {
 			unregister_netdev(dev);
 			cleanup_card(dev);
-			kfree(dev);
+			release_netdev(dev);
 		}
         }
 }
diff -Nru a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
--- a/drivers/net/tokenring/tmspci.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tokenring/tmspci.c	Thu Jun  5 15:51:50 2003
@@ -229,7 +229,7 @@
 	release_region(dev->base_addr, TMS_PCI_IO_EXTENT);
 	free_irq(dev->irq, dev);
 	tmsdev_term(dev);
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tulip/de2104x.c	Thu Jun  5 15:51:50 2003
@@ -2153,7 +2153,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 #ifdef CONFIG_PM
diff -Nru a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
--- a/drivers/net/tulip/dmfe.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tulip/dmfe.c	Thu Jun  5 15:51:50 2003
@@ -478,7 +478,7 @@
 					db->buf_pool_ptr, db->buf_pool_dma_ptr);
 		unregister_netdev(dev);
 		pci_release_regions(pdev);
-		kfree(dev);	/* free board information */
+		release_netdev(dev);	/* free board information */
 		pci_set_drvdata(pdev, NULL);
 	}
 
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tulip/tulip_core.c	Thu Jun  5 15:51:50 2003
@@ -1767,7 +1767,7 @@
 #ifndef USE_IO_OPS
 	iounmap((void *)dev->base_addr);
 #endif
-	kfree (dev);
+	release_netdev (dev);
 	pci_release_regions (pdev);
 	pci_set_drvdata (pdev, NULL);
 
diff -Nru a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
--- a/drivers/net/tulip/winbond-840.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tulip/winbond-840.c	Thu Jun  5 15:51:50 2003
@@ -1623,7 +1623,7 @@
 #ifndef USE_IO_OPS
 		iounmap((char *)(dev->base_addr));
 #endif
-		kfree(dev);
+		release_netdev(dev);
 	}
 
 	pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tulip/xircom_cb.c	Thu Jun  5 15:51:50 2003
@@ -338,7 +338,7 @@
 	}
 	release_region(dev->base_addr, 128);
 	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 	leave("xircom_remove");
 } 
 
diff -Nru a/drivers/net/tulip/xircom_tulip_cb.c b/drivers/net/tulip/xircom_tulip_cb.c
--- a/drivers/net/tulip/xircom_tulip_cb.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/tulip/xircom_tulip_cb.c	Thu Jun  5 15:51:50 2003
@@ -645,11 +645,11 @@
 	return 0;
 
 err_out_cleardev:
+	unregister_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 	pci_release_regions(pdev);
 err_out_free_netdev:
-	unregister_netdev(dev);
-	kfree(dev);
+	release_netdev(dev);
 	return -ENODEV;
 }
 
@@ -1702,7 +1702,7 @@
 	printk(KERN_INFO "xircom_remove_one(%s)\n", dev->name);
 	unregister_netdev(dev);
 	pci_release_regions(pdev);
-	kfree(dev);
+	release_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/typhoon.c	Thu Jun  5 15:51:50 2003
@@ -2476,7 +2476,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	release_netdev(dev);
 }
 
 static struct pci_driver typhoon_driver = {
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/via-rhine.c	Thu Jun  5 15:51:50 2003
@@ -1872,7 +1872,7 @@
 	iounmap((char *)(dev->base_addr));
 #endif
 
-	kfree(dev);
+	release_netdev(dev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
diff -Nru a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/wireless/airo.c	Thu Jun  5 15:51:50 2003
@@ -1573,7 +1573,7 @@
 	        release_region( dev->base_addr, 64 );
         }
 	del_airo_dev( dev );
-	kfree( dev );
+	release_netdev( dev );
 }
 
 EXPORT_SYMBOL(stop_airo_card);
diff -Nru a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/wireless/orinoco_cs.c	Thu Jun  5 15:51:50 2003
@@ -290,8 +290,9 @@
 		DEBUG(0, "orinoco_cs: About to unregister net device %p\n",
 		      dev);
 		unregister_netdev(dev);
-	}
-	kfree(dev);
+		release_netdev(dev);
+	} else
+		kfree(dev);
 }				/* orinoco_cs_detach */
 
 /*
diff -Nru a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
--- a/drivers/net/wireless/orinoco_pci.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/wireless/orinoco_pci.c	Thu Jun  5 15:51:50 2003
@@ -289,7 +289,7 @@
 		iounmap((unsigned char *) priv->hw.iobase);
 
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	release_netdev(dev);
 
 	pci_disable_device(pdev);
 }
diff -Nru a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
--- a/drivers/net/wireless/orinoco_tmd.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/wireless/orinoco_tmd.c	Thu Jun  5 15:51:50 2003
@@ -182,7 +182,7 @@
 		
 	pci_set_drvdata(pdev, NULL);
 
-	kfree(dev);
+	release_netdev(dev);
 
 	release_region(pci_resource_start(pdev, 2), pci_resource_len(pdev, 2));
 
diff -Nru a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
--- a/drivers/net/yellowfin.c	Thu Jun  5 15:51:50 2003
+++ b/drivers/net/yellowfin.c	Thu Jun  5 15:51:50 2003
@@ -1486,7 +1486,7 @@
 	iounmap ((void *) dev->base_addr);
 #endif
 
-	kfree (dev);
+	release_netdev (dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
