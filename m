From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH 2.6.10-rc1 6/15] wireless/orinoco: New device data release
	function
Date: Tue, 26 Oct 2004 14:51:35 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098816695.3663.57.camel@dcbw.boston.redhat.com>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@redhat.com, hermes@gibson.dropbear.id.au
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <1098814320.3663.24.camel@dcbw.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update in-kernel orinoco wireless drivers to upstream CVS.
None of this is original code by Dan Williams, simply a
broken down patch set split-out from upstream orinoco CVS.

o New device data release function, in preparation for 
    device-specific data like scan results

Signed-off-by: Dan Williams <dcbw@redhat.com>

--- a/drivers/net/wireless/orinoco_cs.c.6-free-orinocodev	2004-10-26 10:44:27.100868008 -0400
+++ b/drivers/net/wireless/orinoco_cs.c	2004-10-26 10:44:41.440688024 -0400
@@ -239,7 +239,7 @@
 		      dev);
 		unregister_netdev(dev);
 	}
-	free_netdev(dev);
+	free_orinocodev(dev);
 }				/* orinoco_cs_detach */
 
 /*
--- a/drivers/net/wireless/orinoco.c.6-free-orinocodev	2004-10-26 10:41:11.070669128 -0400
+++ b/drivers/net/wireless/orinoco.c	2004-10-26 10:44:41.444687416 -0400
@@ -2463,6 +2463,13 @@
 
 }
 
+void free_orinocodev(struct net_device *dev)
+{
+	struct orinoco_private *priv = netdev_priv(dev);
+
+	free_netdev(dev);
+}
+
 /********************************************************************/
 /* Wireless extensions                                              */
 /********************************************************************/
@@ -4240,6 +4247,7 @@
 /********************************************************************/
 
 EXPORT_SYMBOL(alloc_orinocodev);
+EXPORT_SYMBOL(free_orinocodev);
 
 EXPORT_SYMBOL(__orinoco_up);
 EXPORT_SYMBOL(__orinoco_down);
--- a/drivers/net/wireless/orinoco.h.6-free-orinocodev	2004-10-26 10:43:31.138375600 -0400
+++ b/drivers/net/wireless/orinoco.h	2004-10-26 10:44:41.445687264 -0400
@@ -111,6 +111,7 @@
 
 extern struct net_device *alloc_orinocodev(int sizeof_card,
 					   int (*hard_reset)(struct orinoco_private *));
+extern void free_orinocodev(struct net_device *dev);
 extern int __orinoco_up(struct net_device *dev);
 extern int __orinoco_down(struct net_device *dev);
 extern int orinoco_stop(struct net_device *dev);
--- a/drivers/net/wireless/orinoco_pci.c.6-free-orinocodev	2004-10-26 10:40:47.501252224 -0400
+++ b/drivers/net/wireless/orinoco_pci.c	2004-10-26 10:44:41.447686960 -0400
@@ -267,7 +267,7 @@
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 
-		free_netdev(dev);
+		free_orinocodev(dev);
 	}
 
 	if (pci_ioaddr)
@@ -292,8 +292,8 @@
 		iounmap((unsigned char *) priv->hw.iobase);
 
 	pci_set_drvdata(pdev, NULL);
-	free_netdev(dev);
 
+	free_orinocodev(dev);
 	pci_disable_device(pdev);
 }
 
--- a/drivers/net/wireless/orinoco_plx.c.6-free-orinocodev	2004-10-26 10:40:36.392940944 -0400
+++ b/drivers/net/wireless/orinoco_plx.c	2004-10-26 10:44:41.448686808 -0400
@@ -273,7 +273,7 @@
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 		
-		free_netdev(dev);
+		free_orinocodev(dev);
 	}
 
 	if (pccard_ioaddr)
@@ -300,10 +300,9 @@
 		
 	pci_set_drvdata(pdev, NULL);
 
-	free_netdev(dev);
-
 	release_region(pci_resource_start(pdev, 3), pci_resource_len(pdev, 3));
 
+	free_orinocodev(dev);
 	pci_disable_device(pdev);
 }
 
--- a/drivers/net/wireless/orinoco_tmd.c.6-free-orinocodev	2004-10-26 10:40:36.393940792 -0400
+++ b/drivers/net/wireless/orinoco_tmd.c	2004-10-26 10:44:41.449686656 -0400
@@ -157,7 +157,7 @@
 		if (dev->irq)
 			free_irq(dev->irq, dev);
 		
-		free_netdev(dev);
+		free_orinocodev(dev);
 	}
 
 	if (pccard_ioaddr)
@@ -181,10 +181,9 @@
 		
 	pci_set_drvdata(pdev, NULL);
 
-	free_netdev(dev);
-
 	release_region(pci_resource_start(pdev, 2), pci_resource_len(pdev, 2));
 
+	free_orinocodev(dev);
 	pci_disable_device(pdev);
 }
 
