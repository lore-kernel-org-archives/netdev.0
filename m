From: chas williams (contractor) <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [horizon] avoid warning about limited range of data type
Date: Tue, 20 Jan 2004 20:24:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401210124.i0L1OZRr014516@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@oss.sgi.com, "Randy.Dunlap" <rddunlap@osdl.org>,
        Daniele Venzano <venza@libero.it>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

this patch fixes the horizon driver so that it will compile
without a warning.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1389  -> 1.1390 
#	drivers/atm/horizon.c	1.4     -> 1.5    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 04/01/20	chas@relax.cmf.nrl.navy.mil	1.1390
# [ATM]: [horizon] avoid warning about limited range of data type
# --------------------------------------------
#
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	Tue Jan 20 19:57:59 2004
+++ b/drivers/atm/horizon.c	Tue Jan 20 19:57:59 2004
@@ -359,8 +359,8 @@
 
 static unsigned short debug = 0;
 static unsigned short vpi_bits = 0;
-static unsigned short max_tx_size = 9000;
-static unsigned short max_rx_size = 9000;
+static int max_tx_size = 9000;
+static int max_rx_size = 9000;
 static unsigned char pci_lat = 0;
 
 /********** access functions **********/
@@ -2919,11 +2919,11 @@
     PRINTK (KERN_ERR, "vpi_bits has been limited to %hu",
 	    vpi_bits = HRZ_MAX_VPI);
   
-  if (max_tx_size > TX_AAL5_LIMIT)
+  if (max_tx_size < 0 || max_tx_size > TX_AAL5_LIMIT)
     PRINTK (KERN_NOTICE, "max_tx_size has been limited to %hu",
 	    max_tx_size = TX_AAL5_LIMIT);
   
-  if (max_rx_size > RX_AAL5_LIMIT)
+  if (max_rx_size < 0 || max_rx_size > RX_AAL5_LIMIT)
     PRINTK (KERN_NOTICE, "max_rx_size has been limited to %hu",
 	    max_rx_size = RX_AAL5_LIMIT);
   
@@ -2938,8 +2938,8 @@
 MODULE_LICENSE("GPL");
 MODULE_PARM(debug, "h");
 MODULE_PARM(vpi_bits, "h");
-MODULE_PARM(max_tx_size, "h");
-MODULE_PARM(max_rx_size, "h");
+MODULE_PARM(max_tx_size, "i");
+MODULE_PARM(max_rx_size, "i");
 MODULE_PARM(pci_lat, "b");
 MODULE_PARM_DESC(debug, "debug bitmap, see .h file");
 MODULE_PARM_DESC(vpi_bits, "number of bits (0..4) to allocate to VPIs");
