From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9 3/3] hp100: use module_param
Date: Tue, 19 Oct 2004 14:19:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019141925.054addc4@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert hp100 to use module_param

diff -Nru a/drivers/net/hp100.c b/drivers/net/hp100.c
--- a/drivers/net/hp100.c	2004-10-18 16:11:05 -07:00
+++ b/drivers/net/hp100.c	2004-10-18 16:11:05 -07:00
@@ -98,6 +98,7 @@
 
 #include <linux/version.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/errno.h>
@@ -224,9 +225,9 @@
 static int hp100_priority_tx = HP100_DEFAULT_PRIORITY_TX;
 static int hp100_mode = 1;
 
-MODULE_PARM(hp100_rx_ratio, "1i");
-MODULE_PARM(hp100_priority_tx, "1i");
-MODULE_PARM(hp100_mode, "1i");
+module_param(hp100_rx_ratio, int, 0);
+module_param(hp100_priority_tx, int, 0);
+module_param(hp100_mode, int, 0);
 
 /*
  *  prototypes
@@ -3005,7 +3006,8 @@
 #define HP100_DEVICES 5
 /* Parameters set by insmod */
 static int hp100_port[HP100_DEVICES] = { 0, [1 ... (HP100_DEVICES-1)] = -1 };
-MODULE_PARM(hp100_port, "1-" __MODULE_STRING(HP100_DEVICES) "i");
+static int nports;
+module_param_array(hp100_port, int, nports, 0);
 
 /* List of devices */
 static struct net_device *hp100_devlist[HP100_DEVICES];
