From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.26-pre2] pcnet32.c oops
Date: Wed, 10 Mar 2004 13:12:36 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403102112.i2ALCaX04547@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following fix to 2.4.26-pre2.

When adding an additional device, a variable which has been removed
is accessed.  Adding the first device or a 4-port card works.
Adding a second device was not done in PCI hot plug testing. 

--- linux-2.4.26-pre2/drivers/net/orig.pcnet32.c	Mon Mar  8 08:59:18 2004
+++ linux-2.4.26-pre2/drivers/net/pcnet32.c	Wed Mar 10 13:09:19 2004
@@ -72,7 +72,7 @@
 
 MODULE_DEVICE_TABLE (pci, pcnet32_pci_tbl);
 
-int cards_found __initdata;
+static int cards_found __devinitdata;
 
 /* 
  * VLB I/O addresses 

-- 
Don Fry
brazilnut@us.ibm.com
