From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.10-rc1-bk22] pcnet32: added pci_disable_device
Date: Fri, 12 Nov 2004 11:38:24 -0800
Message-ID: <20041112193824.GA17937@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch adds pci_disable_device in the appropriate places to
eliminate the following message when removing the module.  

pcnet32 0000:00:05.0: Device was removed without properly calling pci_disable_device(). This may need fixing.
pcnet32 0000:02:05.0: Device was removed without properly calling pci_disable_device(). This may need fixing.

Tested ia32.

signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.10-rc1-bk22/drivers/net/pcnet32.c.orig	Fri Nov 12 10:22:41 2004
+++ linux-2.6.10-rc1-bk22/drivers/net/pcnet32.c	Fri Nov 12 11:17:39 2004
@@ -1010,7 +1010,11 @@ pcnet32_probe_pci(struct pci_dev *pdev, 
 	return -EBUSY;
     }
 
-    return pcnet32_probe1(ioaddr, 1, pdev);
+    err =  pcnet32_probe1(ioaddr, 1, pdev);
+    if (err < 0) {
+	pci_disable_device(pdev);
+    }
+    return err;
 }
 
 
@@ -2249,6 +2253,7 @@ static void __devexit pcnet32_remove_one
 	release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
 	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
 	free_netdev(dev);
+	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
     }
 }

-- 
Don Fry
brazilnut@us.ibm.com
