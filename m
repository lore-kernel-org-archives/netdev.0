From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.26-pre2] pcnet32 use netif_msg_init
Date: Mon, 8 Mar 2004 11:14:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403081914.i28JERJ10601@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply this patch to 2.4.26 after the preceeding patch to
add the netif_msg_init helper to netdevice.h

This patch uses the netif_msg_init routine to initialize the
debug message level for the pcnet32 driver.

--- orig.linux-2.4.26-pre2/drivers/net/pcnet32.c	Mon Mar  8 10:07:05 2004
+++ linux-2.4.26-pre2/drivers/net/pcnet32.c	Mon Mar  8 10:22:32 2004
@@ -224,10 +224,13 @@
  *	   FD auto negotiate error workaround for xSeries250
  *	   clean up and using new mii module
  * v1.28   20 Feb 2004 Don Fry <brazilnut@us.ibm.com>
- *	   Jon Lewis <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
+ *	   Jon Mason <jonmason@us.ibm.com>, Chinmay Albal <albal@in.ibm.com>
  *	   Now uses ethtool_ops, netif_msg_* and generic_mii_ioctl.
  *	   Fixes bogus 'Bus master arbitration failure', pci_[un]map_single
  *	   length errors, and transmit hangs.  Cleans up after errors in open.
+ *	   Jim Lewis <jklewis@us.ibm.com> added ethernet loopback test.
+ *	   Thomas Munck Steenholdt <tmus@tmus.dk> non-mii ioctl corrections.
+ *	   Uses netif_msg_init Don Fry.
  */
 
 
@@ -1949,8 +1952,7 @@
 {
     printk(KERN_INFO "%s", version);
 
-    if (debug >= 0 && debug < (sizeof(int) - 1))
-	pcnet32_debug = 1 << debug;
+    pcnet32_debug = netif_msg_init(debug, 0);
 
     if ((tx_start_pt >= 0) && (tx_start_pt <= 3))
 	tx_start = tx_start_pt;

-- 
Don Fry
brazilnut@us.ibm.com
