From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 3/5] tlan: use module_param (rev2)
Date: Tue, 19 Oct 2004 11:20:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019112031.03f6c011@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tlan.c b/drivers/net/tlan.c
--- a/drivers/net/tlan.c	2004-10-19 11:07:22 -07:00
+++ b/drivers/net/tlan.c	2004-10-19 11:07:22 -07:00
@@ -167,6 +167,7 @@
  *******************************************************************************/
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/eisa.h>
@@ -193,16 +194,21 @@
 static  int duplex[MAX_TLAN_BOARDS];
 static  int speed[MAX_TLAN_BOARDS];
 static  int boards_found;
+/* Turn on debugging. See Documentation/networking/tlan.txt for details */
+static  int		debug;
+static	int		bbuf;
 
 MODULE_AUTHOR("Maintainer: Samuel Chessman <chessman@tux.org>");
 MODULE_DESCRIPTION("Driver for TI ThunderLAN based ethernet PCI adapters");
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(aui, "1-" __MODULE_STRING(MAX_TLAN_BOARDS) "i");
-MODULE_PARM(duplex, "1-" __MODULE_STRING(MAX_TLAN_BOARDS) "i");
-MODULE_PARM(speed, "1-" __MODULE_STRING(MAX_TLAN_BOARDS) "i");
-MODULE_PARM(debug, "i");
-MODULE_PARM(bbuf, "i");
+static int num_boards;
+module_param_array(aui, int, num_boards,  0);
+module_param_array(duplex, int, num_boards, 0);
+module_param_array(speed, int, num_boards, 0);
+module_param(debug, int, 0);
+module_param(bbuf, int, 0);
+
 MODULE_PARM_DESC(aui, "ThunderLAN use AUI port(s) (0-1)");
 MODULE_PARM_DESC(duplex, "ThunderLAN duplex setting(s) (0-default, 1-half, 2-full)");
 MODULE_PARM_DESC(speed, "ThunderLAN port speen setting(s) (0,10,100)");
@@ -212,10 +218,6 @@
 /* Define this to enable Link beat monitoring */
 #undef MONITOR
 
-/* Turn on debugging. See Documentation/networking/tlan.txt for details */
-static  int		debug;
-
-static	int		bbuf;
 static	u8		*TLanPadBuffer;
 static  dma_addr_t	TLanPadBufferDMA;
 static	char		TLanSignature[] = "TLAN";
