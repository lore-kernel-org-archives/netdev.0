From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/9) freenetdev - drivers/net/* changes
Date: Tue, 19 Aug 2003 12:37:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819123756.25aec239.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Simple one line substitution of kfree with free_netdev
for the bulk of the network drivers.

diff -Nru a/drivers/net/3c509.c b/drivers/net/3c509.c
--- a/drivers/net/3c509.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/3c509.c	Tue Aug 19 12:33:10 2003
@@ -355,7 +355,7 @@
 
 		unregister_netdev (dev);
 		release_region(dev->base_addr, EL3_IO_EXTENT);
-		kfree (dev);
+		free_netdev (dev);
 }
 
 static int __init el3_probe(int card_idx)
diff -Nru a/drivers/net/3c515.c b/drivers/net/3c515.c
--- a/drivers/net/3c515.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/3c515.c	Tue Aug 19 12:33:10 2003
@@ -1676,7 +1676,7 @@
 		outw(TotalReset, root_corkscrew_dev->base_addr + EL3_CMD);
 		release_region(root_corkscrew_dev->base_addr,
 			       CORKSCREW_TOTAL_SIZE);
-		kfree(root_corkscrew_dev);
+		free_netdev(root_corkscrew_dev);
 		root_corkscrew_dev = next_dev;
 	}
 }
diff -Nru a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/3c59x.c	Tue Aug 19 12:33:10 2003
@@ -1012,7 +1012,7 @@
 	outw (TotalReset|0x14, ioaddr + EL3_CMD);
 	release_region (ioaddr, VORTEX_TOTAL_SIZE);
 
-	kfree (dev);
+	free_netdev (dev);
 	return 0;
 }
 #endif
@@ -3057,7 +3057,7 @@
 						vp->rx_ring_dma);
 	if (vp->must_free_region)
 		release_region(dev->base_addr, vp->io_size);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 
@@ -3111,7 +3111,7 @@
 		outw (TotalReset, ioaddr + EL3_CMD);
 		release_region (ioaddr, VORTEX_TOTAL_SIZE);
 
-		kfree (compaq_net_device);
+		free_netdev (compaq_net_device);
 	}
 }
 
diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/8139cp.c	Tue Aug 19 12:33:10 2003
@@ -1969,7 +1969,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 #ifdef CONFIG_PM
diff -Nru a/drivers/net/8139too.c b/drivers/net/8139too.c
--- a/drivers/net/8139too.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/8139too.c	Tue Aug 19 12:33:10 2003
@@ -723,7 +723,7 @@
 		sizeof (struct rtl8139_private));
 #endif /* RTL8139_NDEBUG */
 
-	kfree (dev);
+	free_netdev(dev);
 
 	pci_set_drvdata (pdev, NULL);
 }
diff -Nru a/drivers/net/a2065.c b/drivers/net/a2065.c
--- a/drivers/net/a2065.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/a2065.c	Tue Aug 19 12:33:10 2003
@@ -820,7 +820,7 @@
 		release_mem_region(ZTWO_PADDR(dev->base_addr),
 				   sizeof(struct lance_regs));
 		release_mem_region(ZTWO_PADDR(dev->mem_start), A2065_RAM_SIZE);
-		kfree(dev);
+		free_netdev(dev);
 		root_a2065_dev = next;
 	}
 #endif
diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/acenic.c	Tue Aug 19 12:33:10 2003
@@ -955,7 +955,7 @@
 		}
 
 		ace_init_cleanup(root_dev);
-		kfree(root_dev);
+		free_netdev(root_dev);
 		root_dev = next;
 	}
 }
diff -Nru a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
--- a/drivers/net/amd8111e.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/amd8111e.c	Tue Aug 19 12:33:10 2003
@@ -1711,7 +1711,7 @@
 	if (dev) {
 		unregister_netdev(dev);
 		iounmap((void *) ((struct amd8111e_priv *)(dev->priv))->mmio);
-		kfree(dev);
+		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
--- a/drivers/net/arcnet/arc-rimi.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arcnet/arc-rimi.c	Tue Aug 19 12:33:10 2003
@@ -345,7 +345,7 @@
 	iounmap(lp->mem_start);
 	release_mem_region(dev->mem_start, dev->mem_end - dev->mem_start + 1);
 	kfree(dev->priv);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 #else
diff -Nru a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
--- a/drivers/net/arcnet/com20020.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arcnet/com20020.c	Tue Aug 19 12:33:10 2003
@@ -344,7 +344,7 @@
 	free_irq(dev->irq, dev);
 	release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
 	kfree(dev->priv);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 #ifdef MODULE
diff -Nru a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
--- a/drivers/net/arcnet/com90io.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arcnet/com90io.c	Tue Aug 19 12:33:10 2003
@@ -411,7 +411,7 @@
 	free_irq(dev->irq, dev);
 	release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
 	kfree(dev->priv);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 #else
diff -Nru a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
--- a/drivers/net/arcnet/com90xx.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arcnet/com90xx.c	Tue Aug 19 12:33:10 2003
@@ -639,7 +639,7 @@
 		release_region(dev->base_addr, ARCNET_TOTAL_SIZE);
 		release_mem_region(dev->mem_start, dev->mem_end - dev->mem_start + 1);
 		kfree(dev->priv);
-		kfree(dev);
+		free_netdev(dev);
 	}
 }
 
diff -Nru a/drivers/net/ariadne.c b/drivers/net/ariadne.c
--- a/drivers/net/ariadne.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/ariadne.c	Tue Aug 19 12:33:10 2003
@@ -852,7 +852,7 @@
 	unregister_netdev(dev);
 	release_mem_region(ZTWO_PADDR(dev->base_addr), sizeof(struct Am79C960));
 	release_mem_region(ZTWO_PADDR(dev->mem_start), ARIADNE_RAM_SIZE);
-	kfree(dev);
+	free_netdev(dev);
 	root_ariadne_dev = next;
     }
 #endif
diff -Nru a/drivers/net/arm/ether00.c b/drivers/net/arm/ether00.c
--- a/drivers/net/arm/ether00.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arm/ether00.c	Tue Aug 19 12:33:10 2003
@@ -983,7 +983,7 @@
 			unregister_netdev(dev_list[i]);
 			iounmap((void*)dev_list[i]->base_addr);
 			release_mem_region(dev_list[i]->base_addr, MAC_REG_SIZE);
-			kfree(dev_list[i]);
+			free_netdev(dev_list[i]);
 			dev_list[i]=0;
 		}
 	}
diff -Nru a/drivers/net/arm/ether1.c b/drivers/net/arm/ether1.c
--- a/drivers/net/arm/ether1.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arm/ether1.c	Tue Aug 19 12:33:10 2003
@@ -1082,7 +1082,7 @@
 
 	release_region(dev->base_addr, 16);
 	release_region(dev->base_addr + 0x800, 4096);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static const struct ecard_id ether1_ids[] = {
diff -Nru a/drivers/net/arm/ether3.c b/drivers/net/arm/ether3.c
--- a/drivers/net/arm/ether3.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arm/ether3.c	Tue Aug 19 12:33:10 2003
@@ -921,7 +921,7 @@
 
 	unregister_netdev(dev);
 	release_region(dev->base_addr, 128);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static const struct ecard_id ether3_ids[] = {
diff -Nru a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
--- a/drivers/net/arm/etherh.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/arm/etherh.c	Tue Aug 19 12:33:10 2003
@@ -721,7 +721,7 @@
 	if (ec->cid.product == PROD_ANT_ETHERM)
 		size <<= 3;
 	release_region(dev->base_addr, size);
-	kfree(dev);
+	free_netdev(dev);
 
 	ec->ops = NULL;
 	kfree(ec->irq_data);
diff -Nru a/drivers/net/atp.c b/drivers/net/atp.c
--- a/drivers/net/atp.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/atp.c	Tue Aug 19 12:33:10 2003
@@ -943,7 +943,7 @@
 		next_dev = ((struct net_local *)root_atp_dev->priv)->next_module;
 		unregister_netdev(root_atp_dev);
 		/* No need to release_region(), since we never snarf it. */
-		kfree(root_atp_dev);
+		free_netdev(root_atp_dev);
 		root_atp_dev = next_dev;
 	}
 }
diff -Nru a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
--- a/drivers/net/au1000_eth.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/au1000_eth.c	Tue Aug 19 12:33:10 2003
@@ -811,7 +811,7 @@
 				MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS));
 	printk(KERN_ERR "%s: au1000_probe1 failed.  Returns %d\n",
 	       dev->name, retval);
-	kfree(dev);
+	free_netdev(dev);
 	return retval;
 }
 
diff -Nru a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/b44.c	Tue Aug 19 12:33:10 2003
@@ -1852,7 +1852,7 @@
 	if (dev) {
 		unregister_netdev(dev);
 		iounmap((void *) ((struct b44 *)(dev->priv))->regs);
-		kfree(dev);
+		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/bmac.c b/drivers/net/bmac.c
--- a/drivers/net/bmac.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/bmac.c	Tue Aug 19 12:33:10 2003
@@ -1720,7 +1720,7 @@
 		free_irq(bp->tx_dma_intr, dev);
 		free_irq(bp->rx_dma_intr, dev);
 
-		kfree(dev);
+		free_netdev(dev);
 	} while (bmac_devs != NULL);
 }
 
diff -Nru a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/bonding/bond_main.c	Tue Aug 19 12:33:10 2003
@@ -3892,7 +3892,7 @@
 		remove_proc_entry(dev->name, proc_net);
 #endif
 		unregister_netdev(dev);
-		kfree(dev);
+		free_netdev(dev);
 	}
 }
 
diff -Nru a/drivers/net/declance.c b/drivers/net/declance.c
--- a/drivers/net/declance.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/declance.c	Tue Aug 19 12:33:10 2003
@@ -1244,7 +1244,7 @@
 
 err_out:
 	unregister_netdev(dev);
-	kfree(dev);
+	free_netdev(dev);
 	return ret;
 }
 
@@ -1295,7 +1295,7 @@
 #endif
 		root_lance_dev = lp->next;
 		unregister_netdev(dev);
-		kfree(dev);
+		free_netdev(dev);
 	}
 }
 
diff -Nru a/drivers/net/defxx.c b/drivers/net/defxx.c
--- a/drivers/net/defxx.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/defxx.c	Tue Aug 19 12:33:10 2003
@@ -3376,7 +3376,7 @@
 	if (bp->kmalloced)
 		pci_free_consistent(pdev, alloc_size, bp->kmalloced,
 				    bp->kmalloced_dma);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static void __devexit dfx_remove_one (struct pci_dev *pdev)
diff -Nru a/drivers/net/dgrs.c b/drivers/net/dgrs.c
--- a/drivers/net/dgrs.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/dgrs.c	Tue Aug 19 12:33:10 2003
@@ -1337,7 +1337,7 @@
 		
 		dgrs_root_dev = ((DGRS_PRIV *)d->priv)->next_dev;
 		unregister_netdev(d);
-		kfree(d);
+		free_netdev(d);
 	}
 	return ret;
 }
@@ -1529,7 +1529,7 @@
 		if (dgrs_root_dev->irq)
 			free_irq(dgrs_root_dev->irq, dgrs_root_dev);
 
-                kfree(dgrs_root_dev);
+                free_netdev(dgrs_root_dev);
                 dgrs_root_dev = next_dev;
         }
 }
diff -Nru a/drivers/net/dl2k.c b/drivers/net/dl2k.c
--- a/drivers/net/dl2k.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/dl2k.c	Tue Aug 19 12:33:10 2003
@@ -1844,7 +1844,7 @@
 #ifdef MEM_MAPPING
 		iounmap ((char *) (dev->base_addr));
 #endif
-		kfree (dev);
+		free_netdev (dev);
 		pci_release_regions (pdev);
 		pci_disable_device (pdev);
 	}
diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/dummy.c	Tue Aug 19 12:33:10 2003
@@ -107,7 +107,7 @@
 static void __exit dummy_cleanup_module(void)
 {
 	unregister_netdev(dev_dummy);
-	kfree(dev_dummy);
+	free_netdev(dev_dummy);
 	dev_dummy = NULL;
 }
 
diff -Nru a/drivers/net/e100/e100_main.c b/drivers/net/e100/e100_main.c
--- a/drivers/net/e100/e100_main.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/e100/e100_main.c	Tue Aug 19 12:33:10 2003
@@ -730,7 +730,7 @@
 
 	e100_dealloc_space(bdp);
 	pci_set_drvdata(bdp->pdev, NULL);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static void __devexit
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/e1000/e1000_main.c	Tue Aug 19 12:33:10 2003
@@ -531,7 +531,7 @@
 	iounmap(adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 
-	kfree(netdev);
+	free_netdev(netdev);
 }
 
 /**
diff -Nru a/drivers/net/eepro100.c b/drivers/net/eepro100.c
--- a/drivers/net/eepro100.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/eepro100.c	Tue Aug 19 12:33:10 2003
@@ -2378,7 +2378,7 @@
 								+ sizeof(struct speedo_stats),
 						sp->tx_ring, sp->tx_ring_dma);
 	pci_disable_device(pdev);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static struct pci_device_id eepro100_pci_tbl[] = {
diff -Nru a/drivers/net/epic100.c b/drivers/net/epic100.c
--- a/drivers/net/epic100.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/epic100.c	Tue Aug 19 12:33:10 2003
@@ -1482,7 +1482,7 @@
 	iounmap((void*) dev->base_addr);
 #endif
 	pci_release_regions(pdev);
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 	/* pci_power_off(pdev, -1); */
 }
diff -Nru a/drivers/net/eql.c b/drivers/net/eql.c
--- a/drivers/net/eql.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/eql.c	Tue Aug 19 12:33:10 2003
@@ -607,7 +607,7 @@
 static void __exit eql_cleanup_module(void)
 {
 	unregister_netdev(dev_eql);
-	kfree(dev_eql);
+	free_netdev(dev_eql);
 }
 
 module_init(eql_init_module);
diff -Nru a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
--- a/drivers/net/ewrk3.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/ewrk3.c	Tue Aug 19 12:33:10 2003
@@ -2097,7 +2097,7 @@
 		ewrk3_devs[i]->irq = 0;
 
 		release_region(ewrk3_devs[i]->base_addr, EWRK3_TOTAL_SIZE);
-		kfree(ewrk3_devs[i]);
+		free_netdev(ewrk3_devs[i]);
 		ewrk3_devs[i] = NULL;
 	}
 }
diff -Nru a/drivers/net/fc/iph5526.c b/drivers/net/fc/iph5526.c
--- a/drivers/net/fc/iph5526.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/fc/iph5526.c	Tue Aug 19 12:33:10 2003
@@ -4527,7 +4527,7 @@
 		clean_up_memory(fc[i]);
 		if (dev->priv)
 			kfree(priv);
-		kfree(dev);
+		free_netdev(dev);
 		dev = NULL;
 		i++;
 	}
diff -Nru a/drivers/net/fealnx.c b/drivers/net/fealnx.c
--- a/drivers/net/fealnx.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/fealnx.c	Tue Aug 19 12:33:10 2003
@@ -712,7 +712,7 @@
 #ifndef USE_IO_OPS
 		iounmap((void *)dev->base_addr);
 #endif
-		kfree(dev);
+		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
 	} else
diff -Nru a/drivers/net/gt96100eth.c b/drivers/net/gt96100eth.c
--- a/drivers/net/gt96100eth.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/gt96100eth.c	Tue Aug 19 12:33:10 2003
@@ -826,7 +826,7 @@
  free_region:
 	release_region(gtif->iobase, GT96100_ETH_IO_SIZE);
 	unregister_netdev(dev);
-	kfree (dev);
+	free_netdev (dev);
 	err("%s failed.  Returns %d\n", __FUNCTION__, retval);
 	return retval;
 }
@@ -1575,7 +1575,7 @@
 				(struct gt96100_private *)gtif->dev->priv;
 			release_region(gtif->iobase, gp->io_size);
 			unregister_netdev(gtif->dev);
-			kfree (gtif->dev);
+			free_netdev (gtif->dev);
 		}
 	}
 }
diff -Nru a/drivers/net/hamachi.c b/drivers/net/hamachi.c
--- a/drivers/net/hamachi.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/hamachi.c	Tue Aug 19 12:33:10 2003
@@ -1976,7 +1976,7 @@
 			hmp->tx_ring_dma);
 		unregister_netdev(dev);
 		iounmap((char *)dev->base_addr);
-		kfree(dev);
+		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_set_drvdata(pdev, NULL);
 	}
diff -Nru a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
--- a/drivers/net/hamradio/scc.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/hamradio/scc.c	Tue Aug 19 12:33:10 2003
@@ -2121,7 +2121,7 @@
 	if (Nchips == 0)
 	{
 		unregister_netdev(SCC_Info[0].dev);
-		kfree(SCC_Info[0].dev);
+		free_netdev(SCC_Info[0].dev);
 	}
 
 	/* Guard against chip prattle */
@@ -2153,7 +2153,7 @@
 		if (scc->dev)
 		{
 			unregister_netdev(scc->dev);
-			kfree(scc->dev);
+			free_netdev(scc->dev);
 		}
 	}
 	
diff -Nru a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
--- a/drivers/net/hamradio/yam.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/hamradio/yam.c	Tue Aug 19 12:33:10 2003
@@ -1176,7 +1176,7 @@
  error:
 	while (--i >= 0) {
 		unregister_netdev(yam_devs[i]);
-		kfree(yam_devs[i]);
+		free_netdev(yam_devs[i]);
 	}
 	return err;
 }
diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/hp100.c	Tue Aug 19 12:33:10 2003
@@ -2965,7 +2965,7 @@
 		iounmap(p->mem_ptr_virt);
 	kfree(d->priv);
 	d->priv = NULL;
-	kfree(d);
+	free_netdev(d);
 	hp100_devlist[i] = NULL;
 }
 
diff -Nru a/drivers/net/hplance.c b/drivers/net/hplance.c
--- a/drivers/net/hplance.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/hplance.c	Tue Aug 19 12:33:10 2003
@@ -239,7 +239,7 @@
                 lp = root_hplance_dev->next_module;
                 dio_unconfig_board(lp->scode);
                 unregister_netdev(root_lance_dev->dev);
-                kfree(root_lance_dev->dev);
+                free_netdev(root_lance_dev->dev);
                 root_lance_dev = lp;
         }
 }
diff -Nru a/drivers/net/hydra.c b/drivers/net/hydra.c
--- a/drivers/net/hydra.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/hydra.c	Tue Aug 19 12:33:10 2003
@@ -226,7 +226,7 @@
 	unregister_netdev(dev);
 	free_irq(IRQ_AMIGA_PORTS, dev);
 	release_mem_region(ZTWO_PADDR(dev->base_addr)-HYDRA_NIC_BASE, 0x10000);
-	kfree(dev);
+	free_netdev(dev);
 	root_hydra_dev = next;
     }
 }
diff -Nru a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
--- a/drivers/net/ioc3-eth.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/ioc3-eth.c	Tue Aug 19 12:33:10 2003
@@ -1525,7 +1525,7 @@
 	unregister_netdev(dev);
 	iounmap(ioc3);
 	pci_release_regions(pdev);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static struct pci_device_id ioc3_pci_tbl[] = {
diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/ixgb/ixgb_main.c	Tue Aug 19 12:33:10 2003
@@ -478,7 +478,7 @@
 	iounmap((void *) adapter->hw.hw_addr);
 	pci_release_regions(pdev);
 
-	kfree(netdev);
+	free_netdev(netdev);
 }
 
 /**
diff -Nru a/drivers/net/lp486e.c b/drivers/net/lp486e.c
--- a/drivers/net/lp486e.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/lp486e.c	Tue Aug 19 12:33:10 2003
@@ -1336,7 +1336,7 @@
 static void __exit lp486e_cleanup_module(void) {
 	unregister_netdev(dev_lp486e);
 	release_region(dev_lp486e->base_addr, LP486E_TOTAL_SIZE);
-	kfree(dev_lp486e);
+	free_netdev(dev_lp486e);
 }
 
 module_init(lp486e_init_module);
diff -Nru a/drivers/net/mace.c b/drivers/net/mace.c
--- a/drivers/net/mace.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/mace.c	Tue Aug 19 12:33:10 2003
@@ -254,7 +254,7 @@
 		release_OF_resource(mp->of_node, 1);
 		release_OF_resource(mp->of_node, 2);
 	}
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static void dbdma_reset(volatile struct dbdma_regs *dma)
diff -Nru a/drivers/net/mvme147.c b/drivers/net/mvme147.c
--- a/drivers/net/mvme147.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/mvme147.c	Tue Aug 19 12:33:10 2003
@@ -199,7 +199,7 @@
 		lp = root_m147lance_dev->next_module;
 		unregister_netdev(root_lance_dev->dev);
 		free_pages(lp->ram, 3);
-		kfree(root_lance_dev->dev);
+		free_netdev(root_lance_dev->dev);
 		root_lance_dev = lp;
 	}
 }
diff -Nru a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
--- a/drivers/net/myri_sbus.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/myri_sbus.c	Tue Aug 19 12:33:10 2003
@@ -1151,7 +1151,7 @@
 
 		unregister_netdev(root_myri_dev->dev);
 		/* this will also free the co-allocated 'root_myri_dev' */
-		kfree(root_myri_dev->dev);
+		free_netdev(root_myri_dev->dev);
 		root_myri_dev = next;
 	}
 #endif /* MODULE */
diff -Nru a/drivers/net/natsemi.c b/drivers/net/natsemi.c
--- a/drivers/net/natsemi.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/natsemi.c	Tue Aug 19 12:33:10 2003
@@ -2552,7 +2552,7 @@
 	unregister_netdev (dev);
 	pci_release_regions (pdev);
 	iounmap ((char *) dev->base_addr);
-	kfree (dev);
+	free_netdev (dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
--- a/drivers/net/ne2k-pci.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/ne2k-pci.c	Tue Aug 19 12:33:10 2003
@@ -636,7 +636,7 @@
 	unregister_netdev(dev);
 	release_region(dev->base_addr, NE_IO_EXTENT);
 	kfree(dev->priv);
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/ns83820.c	Tue Aug 19 12:33:10 2003
@@ -438,7 +438,7 @@
 
 
 struct ns83820 {
-	struct net_device	net_dev;
+	struct net_device	net_dev;	/* must be first */
 	struct net_device_stats	stats;
 	u8			*base;
 
@@ -2057,7 +2057,7 @@
 	pci_free_consistent(dev->pci_dev, 4 * DESC_SIZE * NR_RX_DESC,
 			dev->rx_info.descs, dev->rx_info.phy_descs);
 	pci_disable_device(dev->pci_dev);
-	kfree(dev);
+	free_netdev(&dev->net_dev);
 	pci_set_drvdata(pci_dev, NULL);
 }
 
diff -Nru a/drivers/net/oaknet.c b/drivers/net/oaknet.c
--- a/drivers/net/oaknet.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/oaknet.c	Tue Aug 19 12:33:10 2003
@@ -687,7 +687,7 @@
 		release_region(ioaddr, OAKNET_IO_SIZE);
 		iounmap(ioaddr);
 		unregister_netdev(oaknet_dev);
-		kfree(priv);
+		free_netdev(priv);
 	}
 
 	/* Convert to loop once driver supports multiple devices. */
diff -Nru a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
--- a/drivers/net/pci-skeleton.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/pci-skeleton.c	Tue Aug 19 12:33:10 2003
@@ -871,7 +871,7 @@
 		sizeof (struct netdrv_private));
 #endif /* NETDRV_NDEBUG */
 
-	kfree (dev);
+	free_netdev (dev);
 
 	pci_set_drvdata (pdev, NULL);
 
diff -Nru a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/pcnet32.c	Tue Aug 19 12:33:10 2003
@@ -1762,7 +1762,7 @@
 	if (lp->pci_dev)
 	    pci_unregister_driver(&pcnet32_driver);
 	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
-	kfree(pcnet32_dev);
+	free_netdev(pcnet32_dev);
 	pcnet32_dev = next_dev;
     }
 }
diff -Nru a/drivers/net/plip.c b/drivers/net/plip.c
--- a/drivers/net/plip.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/plip.c	Tue Aug 19 12:33:10 2003
@@ -1346,7 +1346,7 @@
 			if (nl->port_owner)
 				parport_release(nl->pardev);
 			parport_unregister_device(nl->pardev);
-			kfree(dev);
+			free_netdev(dev);
 			dev_plip[i] = NULL;
 		}
 	}
diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/r8169.c	Tue Aug 19 12:33:10 2003
@@ -646,7 +646,7 @@
 	       sizeof (struct net_device) + sizeof (struct rtl8169_private));
 
 	pci_disable_device(pdev);
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/rcpci45.c b/drivers/net/rcpci45.c
--- a/drivers/net/rcpci45.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/rcpci45.c	Tue Aug 19 12:33:10 2003
@@ -146,7 +146,7 @@
 			     pDpa->msgbuf_dma);
 	if (pDpa->pPab)
 		kfree (pDpa->pPab);
-	kfree (dev);
+	free_netdev (dev);
 	pci_set_drvdata (pdev, NULL);
 }
 
diff -Nru a/drivers/net/rrunner.c b/drivers/net/rrunner.c
--- a/drivers/net/rrunner.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/rrunner.c	Tue Aug 19 12:33:10 2003
@@ -253,7 +253,7 @@
 				    rr->tx_ring_dma);
 		unregister_netdev(dev);
 		iounmap(rr->regs);
-		kfree(dev);
+		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/sb1000.c b/drivers/net/sb1000.c
--- a/drivers/net/sb1000.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sb1000.c	Tue Aug 19 12:33:10 2003
@@ -235,7 +235,7 @@
 	unregister_netdev(dev);
 	release_region(dev->base_addr, 16);
 	release_region(dev->mem_start, 16);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static struct pnp_driver sb1000_driver = {
diff -Nru a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
--- a/drivers/net/sb1250-mac.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sb1250-mac.c	Tue Aug 19 12:33:10 2003
@@ -2929,7 +2929,7 @@
 
 	        port = A_MAC_CHANNEL_BASE(idx);
 		SBMAC_WRITECSR(KSEG1ADDR(port+R_MAC_ETHERNET_ADDR), sbmac_orig_hwaddr[idx] );
-		kfree(dev);
+		free_netdev(dev);
 		dev_sbmac[idx] = NULL;
 	}
 }
diff -Nru a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
--- a/drivers/net/sgiseeq.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sgiseeq.c	Tue Aug 19 12:33:10 2003
@@ -704,7 +704,7 @@
 		free_irq(dev->irq, dev);
 		free_page((unsigned long) sp);
 		unregister_netdev(dev);
-		kfree(dev);
+		free_netdev(dev);
 		dev = next;
 	}
 }
diff -Nru a/drivers/net/sis190.c b/drivers/net/sis190.c
--- a/drivers/net/sis190.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sis190.c	Tue Aug 19 12:33:10 2003
@@ -706,7 +706,7 @@
 	memset(dev, 0xBC,
 	       sizeof (struct net_device) + sizeof (struct sis190_private));
 
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/sis900.c b/drivers/net/sis900.c
--- a/drivers/net/sis900.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sis900.c	Tue Aug 19 12:33:10 2003
@@ -2190,7 +2190,7 @@
 	pci_free_consistent(pci_dev, TX_TOTAL_SIZE, sis_priv->tx_ring,
 		sis_priv->tx_ring_dma);
 	unregister_netdev(net_dev);
-	kfree(net_dev);
+	free_netdev(net_dev);
 	pci_release_regions(pci_dev);
 	pci_set_drvdata(pci_dev, NULL);
 }
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sk98lin/skge.c	Tue Aug 19 12:33:10 2003
@@ -1082,7 +1082,7 @@
 		 * invalid IO ...  :-(
 		 */
 		unregister_netdev(SkGeRootDev);
-		kfree(SkGeRootDev);
+		free_netdev(SkGeRootDev);
 		kfree(pAC);
 		SkGeRootDev = next;
 	}
diff -Nru a/drivers/net/sk_g16.c b/drivers/net/sk_g16.c
--- a/drivers/net/sk_g16.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sk_g16.c	Tue Aug 19 12:33:10 2003
@@ -652,7 +652,7 @@
 			SK_dev->priv = NULL;
 		}
 		unregister_netdev(SK_dev);
-		kfree(SK_dev);
+		free_netdev(SK_dev);
 		SK_dev = NULL;
 	}
 	if (SK_ioaddr) {
diff -Nru a/drivers/net/skfp/skfddi.c b/drivers/net/skfp/skfddi.c
--- a/drivers/net/skfp/skfddi.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/skfp/skfddi.c	Tue Aug 19 12:33:10 2003
@@ -2582,7 +2582,7 @@
 	}
 	unregister_netdev(p);
 	printk("%s: unloaded\n", p->name);
-	kfree(p);		/* Free the device structure */
+	free_netdev(p);		/* Free the device structure */
 
 	return next;
 }				// unlink_modules
diff -Nru a/drivers/net/starfire.c b/drivers/net/starfire.c
--- a/drivers/net/starfire.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/starfire.c	Tue Aug 19 12:33:10 2003
@@ -2196,7 +2196,7 @@
 	pci_release_regions(pdev);
 
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);			/* Will also free np!! */
+	free_netdev(dev);			/* Will also free np!! */
 }
 
 
diff -Nru a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
--- a/drivers/net/sunbmac.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sunbmac.c	Tue Aug 19 12:33:10 2003
@@ -1275,7 +1275,7 @@
 				     bp->bblock_dvma);
 
 		unregister_netdev(bp->dev);
-		kfree(bp->dev);
+		free_netdev(bp->dev);
 		root_bigmac_dev = bp_nxt;
 	}
 }
diff -Nru a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sundance.c	Tue Aug 19 12:33:10 2003
@@ -1790,7 +1790,7 @@
 #ifndef USE_IO_OPS
 		iounmap((char *)(dev->base_addr));
 #endif
-		kfree(dev);
+		free_netdev(dev);
 		pci_set_drvdata(pdev, NULL);
 	}
 }
diff -Nru a/drivers/net/sungem.c b/drivers/net/sungem.c
--- a/drivers/net/sungem.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sungem.c	Tue Aug 19 12:33:10 2003
@@ -2879,7 +2879,7 @@
 				    gp->gblock_dvma);
 		iounmap((void *) gp->regs);
 		pci_release_regions(pdev);
-		kfree(dev);
+		free_netdev(dev);
 
 		pci_set_drvdata(pdev, NULL);
 	}
diff -Nru a/drivers/net/sunhme.c b/drivers/net/sunhme.c
--- a/drivers/net/sunhme.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sunhme.c	Tue Aug 19 12:33:10 2003
@@ -3348,7 +3348,7 @@
 			pci_release_regions(hp->happy_dev);
 		}
 #endif
-		kfree(dev);
+		free_netdev(dev);
 
 		root_happy_dev = next;
 	}
diff -Nru a/drivers/net/sunlance.c b/drivers/net/sunlance.c
--- a/drivers/net/sunlance.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sunlance.c	Tue Aug 19 12:33:10 2003
@@ -1582,7 +1582,7 @@
 
 		unregister_netdev(root_lance_dev->dev);
 		lance_free_hwresources(root_lance_dev);
-		kfree(root_lance_dev->dev);
+		free_netdev(root_lance_dev->dev);
 		root_lance_dev = lp;
 	}
 }
diff -Nru a/drivers/net/sunqe.c b/drivers/net/sunqe.c
--- a/drivers/net/sunqe.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/sunqe.c	Tue Aug 19 12:33:10 2003
@@ -998,7 +998,7 @@
 					     sizeof(struct sunqe_buffers),
 					     root_qec_dev->qes[i]->buffers,
 					     root_qec_dev->qes[i]->buffers_dvma);
-			kfree(root_qec_dev->qes[i]->dev);
+			free_netdev(root_qec_dev->qes[i]->dev);
 		}
 		free_irq(root_qec_dev->qec_sdev->irqs[0], (void *)root_qec_dev);
 		sbus_iounmap(root_qec_dev->gregs, GLOB_REG_SIZE);
diff -Nru a/drivers/net/tc35815.c b/drivers/net/tc35815.c
--- a/drivers/net/tc35815.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tc35815.c	Tue Aug 19 12:33:10 2003
@@ -1769,7 +1769,7 @@
 		next_dev = ((struct tc35815_local *)dev->priv)->next_module;
 		iounmap((void *)(dev->base_addr));
 		unregister_netdev(dev);
-		kfree(dev);
+		free_netdev(dev);
 		root_tc35815_dev = next_dev;
 	}
 }
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tg3.c	Tue Aug 19 12:33:10 2003
@@ -6882,7 +6882,7 @@
 	if (dev) {
 		unregister_netdev(dev);
 		iounmap((void *) ((struct tg3 *)(dev->priv))->regs);
-		kfree(dev);
+		free_netdev(dev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
 		pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tlan.c	Tue Aug 19 12:33:10 2003
@@ -447,7 +447,7 @@
 
 	pci_release_regions(pdev);
 	
-	kfree( dev );
+	free_netdev( dev );
 		
 	pci_set_drvdata( pdev, NULL );
 } 
diff -Nru a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
--- a/drivers/net/tulip/de2104x.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/de2104x.c	Tue Aug 19 12:33:10 2003
@@ -2152,7 +2152,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 #ifdef CONFIG_PM
diff -Nru a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
--- a/drivers/net/tulip/de4x5.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/de4x5.c	Tue Aug 19 12:33:10 2003
@@ -5837,7 +5837,7 @@
 	kfree(lp->cache.priv);              /* Free the private area     */
     }
     unregister_netdev(p);
-    kfree(p);                               /* Free the device structure */
+    free_netdev(p);                         /* Free the device structure */
     
     return next;
 }
diff -Nru a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
--- a/drivers/net/tulip/dmfe.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/dmfe.c	Tue Aug 19 12:33:10 2003
@@ -478,7 +478,7 @@
 					db->buf_pool_ptr, db->buf_pool_dma_ptr);
 		unregister_netdev(dev);
 		pci_release_regions(pdev);
-		kfree(dev);	/* free board information */
+		free_netdev(dev);	/* free board information */
 		pci_set_drvdata(pdev, NULL);
 	}
 
diff -Nru a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
--- a/drivers/net/tulip/tulip_core.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/tulip_core.c	Tue Aug 19 12:33:10 2003
@@ -1780,7 +1780,7 @@
 #ifndef USE_IO_OPS
 	iounmap((void *)dev->base_addr);
 #endif
-	kfree (dev);
+	free_netdev (dev);
 	pci_release_regions (pdev);
 	pci_set_drvdata (pdev, NULL);
 
diff -Nru a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
--- a/drivers/net/tulip/winbond-840.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/winbond-840.c	Tue Aug 19 12:33:10 2003
@@ -1623,7 +1623,7 @@
 #ifndef USE_IO_OPS
 		iounmap((char *)(dev->base_addr));
 #endif
-		kfree(dev);
+		free_netdev(dev);
 	}
 
 	pci_set_drvdata(pdev, NULL);
diff -Nru a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/xircom_cb.c	Tue Aug 19 12:33:10 2003
@@ -338,7 +338,7 @@
 	}
 	release_region(dev->base_addr, 128);
 	unregister_netdev(dev);
-	kfree(dev);
+	free_netdev(dev);
 	leave("xircom_remove");
 } 
 
diff -Nru a/drivers/net/tulip/xircom_tulip_cb.c b/drivers/net/tulip/xircom_tulip_cb.c
--- a/drivers/net/tulip/xircom_tulip_cb.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/tulip/xircom_tulip_cb.c	Tue Aug 19 12:33:10 2003
@@ -1702,7 +1702,7 @@
 	printk(KERN_INFO "xircom_remove_one(%s)\n", dev->name);
 	unregister_netdev(dev);
 	pci_release_regions(pdev);
-	kfree(dev);
+	free_netdev(dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/typhoon.c	Tue Aug 19 12:33:10 2003
@@ -2476,7 +2476,7 @@
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	free_netdev(dev);
 }
 
 static struct pci_driver typhoon_driver = {
diff -Nru a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/via-rhine.c	Tue Aug 19 12:33:10 2003
@@ -1893,7 +1893,7 @@
 	iounmap((char *)(dev->base_addr));
 #endif
 
-	kfree(dev);
+	free_netdev(dev);
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
 }
diff -Nru a/drivers/net/wan/comx.c b/drivers/net/wan/comx.c
--- a/drivers/net/wan/comx.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wan/comx.c	Tue Aug 19 12:33:10 2003
@@ -908,7 +908,7 @@
 	if (dev->priv) {
 		kfree(dev->priv);
 	}
-	kfree(dev);
+	free_netdev(dev);
 
 	remove_proc_entry(FILENAME_DEBUG, entry);
 	remove_proc_entry(FILENAME_LINEUPDELAY, entry);
diff -Nru a/drivers/net/wan/dlci.c b/drivers/net/wan/dlci.c
--- a/drivers/net/wan/dlci.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wan/dlci.c	Tue Aug 19 12:33:10 2003
@@ -509,7 +509,7 @@
 		open_dev[i] = NULL;
 
 	kfree(master->priv);
-	kfree(master);
+	free_netdev(master);
 
 	MOD_DEC_USE_COUNT;
 
diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
--- a/drivers/net/wan/lmc/lmc_main.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wan/lmc/lmc_main.c	Tue Aug 19 12:33:10 2003
@@ -1913,7 +1913,7 @@
         kfree (dev->priv);
         dev->priv = NULL;
 
-        kfree ((struct ppp_device *) dev);
+        free_netdev (dev);
         dev = NULL;
     }
 
diff -Nru a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
--- a/drivers/net/wan/sbni.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wan/sbni.c	Tue Aug 19 12:33:10 2003
@@ -1507,7 +1507,7 @@
 			unregister_netdev( dev );
 			release_region( dev->base_addr, SBNI_IO_EXTENT );
 			kfree( dev->priv );
-			kfree( dev );
+			free_netdev( dev );
 		}
 }
 
diff -Nru a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
--- a/drivers/net/wan/x25_asy.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wan/x25_asy.c	Tue Aug 19 12:33:10 2003
@@ -840,7 +840,7 @@
 			 * unregistered while close proc.
 			 */
 			unregister_netdev(dev);
-			kfree(dev);
+			free_netdev(dev);
 		}
 	}
 
diff -Nru a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
--- a/drivers/net/wireless/airo.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/airo.c	Tue Aug 19 12:33:10 2003
@@ -1608,7 +1608,7 @@
 		unregister_netdev( dev );
 		if (ai->wifidev) {
 			unregister_netdev(ai->wifidev);
-			kfree(ai->wifidev);
+			free_netdev(ai->wifidev);
 			ai->wifidev = 0;
 		}
 		ai->registered = 0;
@@ -1625,7 +1625,7 @@
 	        release_region( dev->base_addr, 64 );
         }
 	del_airo_dev( dev );
-	kfree( dev );
+	free_netdev( dev );
 }
 
 EXPORT_SYMBOL(stop_airo_card);
diff -Nru a/drivers/net/wireless/airport.c b/drivers/net/wireless/airport.c
--- a/drivers/net/wireless/airport.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/airport.c	Tue Aug 19 12:33:10 2003
@@ -284,7 +284,7 @@
 	current->state = TASK_UNINTERRUPTIBLE;
 	schedule_timeout(HZ);
 
-	kfree(dev);
+	free_netdev(dev);
 }				/* airport_detach */
 
 static char version[] __initdata = "airport.c 0.13e (Benjamin Herrenschmidt <benh@kernel.crashing.org>)";
diff -Nru a/drivers/net/wireless/arlan.c b/drivers/net/wireless/arlan.c
--- a/drivers/net/wireless/arlan.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/arlan.c	Tue Aug 19 12:33:10 2003
@@ -2061,7 +2061,7 @@
 			unregister_netdev(arlan_device[i]);
 			ap = arlan_device[i]->priv;
 			if (ap->init_etherdev_alloc) {
-				kfree(arlan_device[i]);
+				free_netdev(arlan_device[i]);
 				arlan_device[i] = NULL;
 			} else {
 				kfree(ap);
diff -Nru a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
--- a/drivers/net/wireless/atmel.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/atmel.c	Tue Aug 19 12:33:10 2003
@@ -1468,7 +1468,7 @@
 		/* PCMCIA frees this stuff, so only for PCI */
 	        release_region(dev->base_addr, 64);
         }
-	kfree(dev);
+	free_netdev(dev);
 }
 
 EXPORT_SYMBOL(stop_atmel_card);
diff -Nru a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
--- a/drivers/net/wireless/netwave_cs.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/netwave_cs.c	Tue Aug 19 12:33:10 2003
@@ -574,9 +574,9 @@
 
     /* Unlink device structure, free pieces */
     *linkp = link->next;
-    if (link->dev)
+    if (link->dev) 
 	unregister_netdev(dev);
-    kfree(dev);
+    free_netdev(dev);
     
 } /* netwave_detach */
 
diff -Nru a/drivers/net/wireless/orinoco_cs.c b/drivers/net/wireless/orinoco_cs.c
--- a/drivers/net/wireless/orinoco_cs.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/orinoco_cs.c	Tue Aug 19 12:33:10 2003
@@ -286,7 +286,7 @@
 		      dev);
 		unregister_netdev(dev);
 	}
-	kfree(dev);
+	free_netdev(dev);
 }				/* orinoco_cs_detach */
 
 /*
diff -Nru a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
--- a/drivers/net/wireless/orinoco_pci.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/orinoco_pci.c	Tue Aug 19 12:33:10 2003
@@ -289,7 +289,7 @@
 		iounmap((unsigned char *) priv->hw.iobase);
 
 	pci_set_drvdata(pdev, NULL);
-	kfree(dev);
+	free_netdev(dev);
 
 	pci_disable_device(pdev);
 }
diff -Nru a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/orinoco_plx.c
--- a/drivers/net/wireless/orinoco_plx.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/orinoco_plx.c	Tue Aug 19 12:33:10 2003
@@ -291,7 +291,7 @@
 		
 	pci_set_drvdata(pdev, NULL);
 
-	kfree(dev);
+	free_netdev(dev);
 
 	release_region(pci_resource_start(pdev, 3), pci_resource_len(pdev, 3));
 
diff -Nru a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
--- a/drivers/net/wireless/orinoco_tmd.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/orinoco_tmd.c	Tue Aug 19 12:33:10 2003
@@ -182,7 +182,7 @@
 		
 	pci_set_drvdata(pdev, NULL);
 
-	kfree(dev);
+	free_netdev(dev);
 
 	release_region(pci_resource_start(pdev, 2), pci_resource_len(pdev, 2));
 
diff -Nru a/drivers/net/wireless/wavelan.c b/drivers/net/wireless/wavelan.c
--- a/drivers/net/wireless/wavelan.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/wireless/wavelan.c	Tue Aug 19 12:33:10 2003
@@ -4410,7 +4410,7 @@
 
 		/* Free pieces. */
 		kfree(dev->priv);
-		kfree(dev);
+		free_netdev(dev);
 	}
 
 #ifdef DEBUG_MODULE_TRACE
diff -Nru a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
--- a/drivers/net/yellowfin.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/yellowfin.c	Tue Aug 19 12:33:10 2003
@@ -1486,7 +1486,7 @@
 	iounmap ((void *) dev->base_addr);
 #endif
 
-	kfree (dev);
+	free_netdev (dev);
 	pci_set_drvdata(pdev, NULL);
 }
 
diff -Nru a/drivers/net/znet.c b/drivers/net/znet.c
--- a/drivers/net/znet.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/znet.c	Tue Aug 19 12:33:10 2003
@@ -941,7 +941,7 @@
 		kfree (znet->rx_start);
 		kfree (znet->tx_start);
 		unregister_netdev (znet_dev);
-		kfree (znet_dev);
+		free_netdev (znet_dev);
 	}
 #endif
 }
diff -Nru a/drivers/net/zorro8390.c b/drivers/net/zorro8390.c
--- a/drivers/net/zorro8390.c	Tue Aug 19 12:33:10 2003
+++ b/drivers/net/zorro8390.c	Tue Aug 19 12:33:10 2003
@@ -413,7 +413,7 @@
 	unregister_netdev(dev);
 	free_irq(IRQ_AMIGA_PORTS, dev);
 	release_mem_region(ZTWO_PADDR(dev->base_addr), NE_IO_EXTENT*2);
-	kfree(dev);
+	free_netdev(dev);
 	root_zorro8390_dev = next;
     }
 #endif
