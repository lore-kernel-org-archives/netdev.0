From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/2] slip: use module_param
Date: Fri, 15 Oct 2004 13:04:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015130428.76eef1c3@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace MODULE_PARM with module_param (also make slip_maxdev static).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/slip.c b/drivers/net/slip.c
--- a/drivers/net/slip.c	2004-10-15 12:34:30 -07:00
+++ b/drivers/net/slip.c	2004-10-15 12:34:30 -07:00
@@ -57,6 +57,7 @@
 #define SL_CHECK_TRANSMIT
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 
 #include <asm/system.h>
 #include <asm/uaccess.h>
@@ -85,8 +86,8 @@
 
 static struct net_device **slip_devs;
 
-int slip_maxdev = SL_NRUNIT;		/* Can be overridden with insmod! */
-MODULE_PARM(slip_maxdev, "i");
+static int slip_maxdev = SL_NRUNIT;
+module_param(slip_maxdev, int, 0);
 MODULE_PARM_DESC(slip_maxdev, "Maximum number of slip devices");
 
 static int slip_esc(unsigned char *p, unsigned char *d, int len);
