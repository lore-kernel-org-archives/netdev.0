From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.4-rc3] pcnet32.c oops
Date: Wed, 10 Mar 2004 13:08:17 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403102108.i2AL8Is04491@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please apply the following fix to 2.6.3-rc4.

When adding an additional device, a variable which has been removed
is accessed.  Adding the first device or a 4-port card works.
Adding a second device was not done in PCI hot plug testing.  Now
tested on IA32.

--- linux-2.6.4-rc3/drivers/net/orig.pcnet32.c	Wed Mar 10 08:55:40 2004
+++ linux-2.6.4-rc3/drivers/net/pcnet32.c	Wed Mar 10 11:35:41 2004
@@ -69,7 +69,7 @@
 
 MODULE_DEVICE_TABLE (pci, pcnet32_pci_tbl);
 
-int cards_found __initdata;
+static int cards_found;
 
 /*
  * VLB I/O addresses

-- 
Don Fry
brazilnut@us.ibm.com
