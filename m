From: Pavel Machek <pavel@ucw.cz>
Subject: [-mm] ipw2100: assume recent kernel
Date: Wed, 8 Jun 2005 15:31:24 +0200
Message-ID: <20050608133123.GA3008@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev list <netdev@oss.sgi.com>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
        Andrew Morton <akpm@zip.com.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ipw2100 still has support for old kernels. Thats considered bad for
patch in mainline... this fixes few instances.

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- /data/l/clean-mm/drivers/net/wireless/ipw2100.c	2005-06-08 12:11:29.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-08 15:09:26.000000000 +0200
@@ -6719,17 +5873,9 @@
 	/* Remove the PRESENT state of the device */
 	netif_device_detach(dev);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
-	pci_save_state(pci_dev, priv->pm_state);
-#else
 	pci_save_state(pci_dev);
-#endif
 	pci_disable_device (pci_dev);
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11)
-	pci_set_power_state(pci_dev, state);
-#else
 	pci_set_power_state(pci_dev, PCI_D3hot);
-#endif
 
 	up(&priv->action_sem);
 
@@ -6750,17 +5896,9 @@
 	IPW_DEBUG_INFO("%s: Coming out of suspend...\n",
 	       dev->name);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11)
-	pci_set_power_state(pci_dev, 0);
-#else
 	pci_set_power_state(pci_dev, PCI_D0);
-#endif
 	pci_enable_device(pci_dev);
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
-	pci_restore_state(pci_dev, priv->pm_state);
-#else
 	pci_restore_state(pci_dev);
-#endif
 
 	/*
 	 * Suspend/Resume resets the PCI configuration space, so we have to
--- /data/l/clean-mm/drivers/net/wireless/ipw2100.h	2005-06-08 12:11:29.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.h	2005-06-08 15:07:31.000000000 +0200
@@ -44,30 +44,6 @@
 
 #include <linux/workqueue.h>
 
-#ifndef IRQ_NONE
-typedef void irqreturn_t;
-#define IRQ_NONE
-#define IRQ_HANDLED
-#define IRQ_RETVAL(x)
-#endif
-
-#if WIRELESS_EXT < 17
-#define IW_QUAL_QUAL_INVALID  0x10
-#define IW_QUAL_LEVEL_INVALID 0x20
-#define IW_QUAL_NOISE_INVALID 0x40
-#endif
-
-#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,5) )
-#define pci_dma_sync_single_for_cpu	pci_dma_sync_single
-#define pci_dma_sync_single_for_device	pci_dma_sync_single
-#endif
-
-#ifndef HAVE_FREE_NETDEV
-#define free_netdev(x) kfree(x)
-#endif
-
-
-
 struct ipw2100_priv;
 struct ipw2100_tx_packet;
 struct ipw2100_rx_packet;
