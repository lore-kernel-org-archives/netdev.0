From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/2) module_param for acenic
Date: Mon, 26 Jul 2004 16:22:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040726162216.74a89f81@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, Jes Sorensen <jes@wildopensource.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert acenic driver to use module_param instead of the older
MODULE_PARM macro. Someday, Rusty wants to get rid of MODULE_PARM.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-07-26 16:19:55 -07:00
+++ b/drivers/net/acenic.c	2004-07-26 16:19:55 -07:00
@@ -52,6 +52,7 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/version.h>
 #include <linux/types.h>
 #include <linux/errno.h>
@@ -425,13 +426,15 @@
 MODULE_AUTHOR("Jes Sorensen <jes@trained-monkey.org>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("AceNIC/3C985/GA620 Gigabit Ethernet driver");
-MODULE_PARM(link, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(trace, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(tx_coal_tick, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(max_tx_desc, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(rx_coal_tick, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(max_rx_desc, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(tx_ratio, "1-" __MODULE_STRING(8) "i");
+
+static int num_params;
+module_param_array(link, int, num_params, 0);
+module_param_array(trace, int, num_params, 0);
+module_param_array(tx_coal_tick, int, num_params, 0);
+module_param_array(max_tx_desc, int, num_params, 0);
+module_param_array(rx_coal_tick, int, num_params, 0);
+module_param_array(max_rx_desc, int, num_params, 0);
+module_param_array(tx_ratio, int, num_params, 0);
 MODULE_PARM_DESC(link, "AceNIC/3C985/NetGear link state");
 MODULE_PARM_DESC(trace, "AceNIC/3C985/NetGear firmware trace level");
 MODULE_PARM_DESC(tx_coal_tick, "AceNIC/3C985/GA620 max clock ticks to wait from first tx descriptor arrives");
