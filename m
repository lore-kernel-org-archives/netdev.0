From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] hp100 -- fixes for new probing.
Date: Mon, 24 Nov 2003 15:44:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124154459.6fe02a94.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes to net-drivers-2.5-exp patches for hp100
	* EISA device id table needs a terminating string.
	* if one driver built for all variations (ISA, EISA, PCI)
	  then try to have sane error handling on probe.

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	Mon Nov 24 15:34:53 2003
+++ b/drivers/net/hp100.c	Mon Nov 24 15:34:53 2003
@@ -201,6 +201,7 @@
 	{ "HWP1990" }, /* HP J2577 */
 	{ "CPX0301" }, /* ReadyLink ENET100-VG4 */
 	{ "CPX0401" }, /* FreedomLine 100/VG */
+	{ "" }
 };
 MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
 #endif
@@ -3045,10 +3046,16 @@
 	err = hp100_isa_init();
 
 #ifdef CONFIG_EISA
-	err |= eisa_driver_register(&hp100_eisa_driver);
+	if (err && err != -ENODEV) 
+		return err;
+
+	err = eisa_driver_register(&hp100_eisa_driver);
 #endif
 #ifdef CONFIG_PCI
-	err |= pci_module_init(&hp100_pci_driver);
+	if (err && err != -ENODEV)
+		return err;
+
+	err = pci_module_init(&hp100_pci_driver);
 #endif
 	return err;
 }
