From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c503: convert to module_param
Date: Mon, 18 Oct 2004 13:04:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018130456.4b42baac@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert 3c503 to use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c503.c b/drivers/net/3c503.c
--- a/drivers/net/3c503.c	2004-10-18 12:25:17 -07:00
+++ b/drivers/net/3c503.c	2004-10-18 12:25:17 -07:00
@@ -42,6 +42,7 @@
     DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "  Donald Becker (becker@scyld.com)\n";
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/string.h>
@@ -666,16 +667,18 @@
 	.get_drvinfo		= netdev_get_drvinfo,
 };
 
-#ifdef MODULE
 #define MAX_EL2_CARDS	4	/* Max number of EL2 cards per module */
 
+#ifdef MODULE
 static struct net_device *dev_el2[MAX_EL2_CARDS];
 static int io[MAX_EL2_CARDS];
 static int irq[MAX_EL2_CARDS];
 static int xcvr[MAX_EL2_CARDS];	/* choose int. or ext. xcvr */
-MODULE_PARM(io, "1-" __MODULE_STRING(MAX_EL2_CARDS) "i");
-MODULE_PARM(irq, "1-" __MODULE_STRING(MAX_EL2_CARDS) "i");
-MODULE_PARM(xcvr, "1-" __MODULE_STRING(MAX_EL2_CARDS) "i");
+
+static int num_params;
+module_param_array(io, int, num_params, 0);
+module_param_array(irq, int, num_params, 0);
+module_param_array(xcvr, int, num_params, 0);
 MODULE_PARM_DESC(io, "I/O base address(es)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (assigned)");
 MODULE_PARM_DESC(xcvr, "transceiver(s) (0=internal, 1=external)");
@@ -684,8 +687,7 @@
 
 /* This is set up so that only a single autoprobe takes place per call.
 ISA device autoprobes on a running machine are not recommended. */
-int
-init_module(void)
+static __init int el2_init_module(void)
 {
 	struct net_device *dev;
 	int this_dev, found = 0;
@@ -716,9 +718,9 @@
 		return 0;
 	return -ENXIO;
 }
+module_init(el2_init_module);
 
-void
-cleanup_module(void)
+static __exit void el2_cleanup_module(void)
 {
 	int this_dev;
 
@@ -731,4 +733,5 @@
 		}
 	}
 }
+module_exit(el2_cleanup_module);
 #endif /* MODULE */
