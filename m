From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9] 3c509: use module_param
Date: Mon, 18 Oct 2004 13:41:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018134112.3ba865c3@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another 3com card change to use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/3c509.c b/drivers/net/3c509.c
--- a/drivers/net/3c509.c	2004-10-18 13:32:47 -07:00
+++ b/drivers/net/3c509.c	2004-10-18 13:32:47 -07:00
@@ -70,6 +70,7 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #ifdef CONFIG_MCA
 #include <linux/mca.h>
 #endif
@@ -1535,16 +1536,17 @@
 static int irq[] = {-1, -1, -1, -1, -1, -1, -1, -1};
 static int xcvr[] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1};
 
-MODULE_PARM(debug,"i");
-MODULE_PARM(irq,"1-8i");
-MODULE_PARM(xcvr,"1-12i");
-MODULE_PARM(max_interrupt_work, "i");
+module_param(debug, int, 0);
+static int num_params;
+module_param_array(irq, int, num_params, 0);
+module_param_array(xcvr, int, num_params, 0);
+module_param(max_interrupt_work, int, 0);
 MODULE_PARM_DESC(debug, "debug level (0-6)");
 MODULE_PARM_DESC(irq, "IRQ number(s) (assigned)");
 MODULE_PARM_DESC(xcvr,"transceiver(s) (0=internal, 1=external)");
 MODULE_PARM_DESC(max_interrupt_work, "maximum events handled per interrupt");
 #if defined(__ISAPNP__)
-MODULE_PARM(nopnp, "i");
+module_param(nopnp, int, 0);
 MODULE_PARM_DESC(nopnp, "disable ISA PnP support (0-1)");
 MODULE_DEVICE_TABLE(isapnp, el3_isapnp_adapters);
 #endif	/* __ISAPNP__ */
