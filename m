From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/2] r8169: use module_param
Date: Fri, 15 Oct 2004 15:36:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015153637.15739e5a@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use module_param instead of deprecated MDOULE_PARM

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c	2004-10-15 14:56:05 -07:00
+++ b/drivers/net/r8169.c	2004-10-15 14:56:05 -07:00
@@ -44,6 +44,7 @@
 */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -93,6 +94,7 @@
 /* media options */
 #define MAX_UNITS 8
 static int media[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1 };
+static int num_media = 0;
 
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work = 20;
@@ -405,9 +407,9 @@
 
 MODULE_AUTHOR("Realtek");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
-MODULE_PARM(media, "1-" __MODULE_STRING(MAX_UNITS) "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(use_dac, "i");
+module_param_array(media, int, num_media, 0);
+module_param(rx_copybreak, int, 0);
+module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 MODULE_LICENSE("GPL");
 
