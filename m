From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] xircom_tulip_cb: convert to using module_param
Date: Mon, 18 Oct 2004 15:32:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018153204.4d3cf14d@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert to use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/tulip/xircom_tulip_cb.c b/drivers/net/tulip/xircom_tulip_cb.c
--- a/drivers/net/tulip/xircom_tulip_cb.c	2004-10-18 15:27:10 -07:00
+++ b/drivers/net/tulip/xircom_tulip_cb.c	2004-10-18 15:27:10 -07:00
@@ -93,6 +93,7 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -117,12 +118,14 @@
 MODULE_DESCRIPTION("Xircom CBE-100 ethernet driver");
 MODULE_LICENSE("GPL v2");
 
-MODULE_PARM(debug, "i");
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(csr0, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
+module_param(debug, int, 0);
+module_param(max_interrupt_work, int, 0);
+module_param(rx_copybreak, int, 0);
+module_param(csr0, int, 0);
+
+static int num_units;
+module_param_array(options, num_units, int, 0);
+module_param_array(full_duplex, num_units, int, 0);
 
 #define RUN_AT(x) (jiffies + (x))
 
