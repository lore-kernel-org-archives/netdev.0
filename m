From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [Orinoco-devel] Re: [6/14] Orinoco driver updates - cleanup PCI initialization
Date: Fri, 25 Feb 2005 15:58:54 +1100
Message-ID: <20050225045854.GE10725@localhost.localdomain>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <421D5979.5080600@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>,
	Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <421D5979.5080600@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 23, 2005 at 11:35:05PM -0500, Jeff Garzik wrote:
> FYI, pci_set_drvdata() needs to be one of the last functions called 
> during PCI ->probe().

Ok, here's a patch to correct that (applies on top of the other stack,
obviously):

As Jeff Garzik has pointed out, pci_set_drvdata() belongs right at the
end of PCI initialization.  Correct this in the various PCI based
orinoco drivers.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco_plx.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_plx.c	2005-02-25 15:47:53.011419192 +1100
+++ working-2.6/drivers/net/wireless/orinoco_plx.c	2005-02-25 15:45:13.000000000 +1100
@@ -257,7 +257,6 @@
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, mem, HERMES_16BIT_REGSPACING);
-	pci_set_drvdata(pdev, dev);
 
 	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 PLX device "
 	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
@@ -315,6 +314,8 @@
 		goto fail;
 	}
 
+	pci_set_drvdata(pdev, dev);
+
 	return 0;
 
  fail:
Index: working-2.6/drivers/net/wireless/orinoco_pci.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_pci.c	2005-02-25 15:47:53.282378000 +1100
+++ working-2.6/drivers/net/wireless/orinoco_pci.c	2005-02-25 15:44:50.000000000 +1100
@@ -230,7 +230,6 @@
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, pci_ioaddr, HERMES_32BIT_REGSPACING);
-	pci_set_drvdata(pdev, dev);
 
 	printk(KERN_DEBUG PFX "Detected device %s, mem:0x%lx-0x%lx, irq %d\n",
 	       pci_name(pdev), dev->mem_start, dev->mem_end, pdev->irq);
@@ -257,6 +256,8 @@
 		goto fail;
 	}
 
+	pci_set_drvdata(pdev, dev);
+
 	return 0;
 
  fail:
Index: working-2.6/drivers/net/wireless/orinoco_tmd.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_tmd.c	2005-02-25 15:47:53.011419192 +1100
+++ working-2.6/drivers/net/wireless/orinoco_tmd.c	2005-02-25 15:45:33.000000000 +1100
@@ -166,7 +166,6 @@
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	hermes_struct_init(&priv->hw, mem, HERMES_16BIT_REGSPACING);
-	pci_set_drvdata(pdev, dev);
 
 	printk(KERN_DEBUG PFX "Detected Orinoco/Prism2 TMD device "
 	       "at %s irq:%d, io addr:0x%lx\n", pci_name(pdev), pdev->irq,
@@ -193,6 +192,8 @@
 		goto fail;
 	}
 
+	pci_set_drvdata(pdev, dev);
+
 	return 0;
 
  fail:


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
