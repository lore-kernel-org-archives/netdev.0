From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] eepro100 - module_param and cleanup
Date: Fri, 6 Aug 2004 15:25:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040806152532.25cdebeb@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert old eepro100 driver from MODULE_PARAM to module_param and get
rid of old 2.2 compatibility ifdef

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6/drivers/net/eepro100.c	2004-08-06 15:05:16.445630112 -0700
+++ tcp-2.6/drivers/net/eepro100.c	2004-08-06 15:08:09.761282128 -0700
@@ -88,8 +88,8 @@
 #define PKT_BUF_SZ		1536
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -131,17 +131,21 @@
 MODULE_AUTHOR("Maintainer: Andrey V. Savochkin <saw@saw.sw.com.sg>");
 MODULE_DESCRIPTION("Intel i82557/i82558/i82559 PCI EtherExpressPro driver");
 MODULE_LICENSE("GPL");
-MODULE_PARM(debug, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(congenb, "i");
-MODULE_PARM(txfifo, "i");
-MODULE_PARM(rxfifo, "i");
-MODULE_PARM(txdmacount, "i");
-MODULE_PARM(rxdmacount, "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(multicast_filter_limit, "i");
+
+static int num_params;
+
+module_param(debug, int, 0);
+module_param(congenb, int, 0);
+module_param(txfifo, int, 0);
+module_param(rxfifo, int, 0);
+module_param(txdmacount, int, 0);
+module_param(rxdmacount, int, 0);
+module_param(rx_copybreak, int, 0);
+module_param(max_interrupt_work, int, 0);
+module_param(multicast_filter_limit, int, 0);
+module_param_array(options, int, num_params, 0);
+module_param_array(full_duplex, int, num_params, 0);
+
 MODULE_PARM_DESC(debug, "debug level (0-6)");
 MODULE_PARM_DESC(options, "Bits 0-3: transceiver type, bit 4: full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC(full_duplex, "full duplex setting(s) (1)");
@@ -2447,22 +2451,6 @@
 #endif /* CONFIG_PM */
 };
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,48)
-static int pci_module_init(struct pci_driver *pdev)
-{
-	int rc;
-
-	rc = pci_register_driver(pdev);
-	if (rc <= 0) {
-		printk(KERN_INFO "%s: No cards found, driver not installed.\n",
-			   pdev->name);
-		pci_unregister_driver(pdev);
-		return -ENODEV;
-	}
-	return 0;
-}
-#endif
-
 static int __init eepro100_init_module(void)
 {
 #ifdef MODULE
