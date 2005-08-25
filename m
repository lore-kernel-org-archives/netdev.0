From: Pavel Machek <pavel@suse.cz>
Subject: [patch] ipw2200: remove support for obsolete kernels
Date: Thu, 25 Aug 2005 13:04:38 +0200
Message-ID: <20050825110438.GA16944__42945.4043544412$1124968318$gmane$org@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev list <netdev@oss.sgi.com>,
        kernel list <linux-kernel@vger.kernel.org>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>, jbenc@suse.cz,
        jbo@suse.cz
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This removes support for old (and non-mainline) kernels from
ipw2200. Please apply,

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- clean-mm/drivers/net/wireless/ipw2200.c	2005-08-24 20:25:09.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2200.c	2005-08-25 12:50:19.000000000 +0200
@@ -6617,11 +6617,7 @@
 {
 	int ret = 0;
 
-#ifdef CONFIG_SOFTWARE_SUSPEND2
-	priv->workqueue = create_workqueue(DRV_NAME, 0);
-#else
 	priv->workqueue = create_workqueue(DRV_NAME);
-#endif
 	init_waitqueue_head(&priv->wait_command_queue);
 
 	INIT_WORK(&priv->adhoc_check, ipw_adhoc_check, priv);
@@ -7242,11 +7238,7 @@
 	/* Remove the PRESENT state of the device */
 	netif_device_detach(dev);
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
-	pci_save_state(pdev, priv->pm_state);
-#else
 	pci_save_state(pdev);
-#endif
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
--- clean-mm/drivers/net/wireless/ipw2200.h	2005-08-24 20:25:09.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2200.h	2005-08-25 12:42:30.000000000 +0200
@@ -55,26 +55,6 @@
 
 #include <linux/workqueue.h>
 
-#ifndef IRQ_NONE
-typedef void irqreturn_t;
-#define IRQ_NONE
-#define IRQ_HANDLED
-#define IRQ_RETVAL(x)
-#endif
-
-#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,9) )
-#define __iomem
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
 /* Authentication  and Association States */
 enum connection_manager_assoc_states
 {


-- 
if you have sharp zaurus hardware you don't need... you know my address
