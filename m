From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.25] pcnet32.c another diff error fix.
Date: Mon, 23 Feb 2004 11:04:59 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402231904.i1NJ4xj18531@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I made another diff file error in my previous series of patches to 2.4.25

The following patch should be done after "handle failures in open" and
before "non-mii errors with ethtool".

--- linux-2.4.25/drivers/net/clean.pcnet32.c	Mon Feb 23 10:16:35 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Mon Feb 23 10:17:05 2004
@@ -401,13 +401,13 @@
 }
 
 static struct pcnet32_access pcnet32_wio = {
-    read_csr:	pcnet32_wio_read_csr,
-    write_csr:	pcnet32_wio_write_csr,
-    read_bcr:	pcnet32_wio_read_bcr,
-    write_bcr:	pcnet32_wio_write_bcr,
-    read_rap:	pcnet32_wio_read_rap,
-    write_rap:	pcnet32_wio_write_rap,
-    reset:	pcnet32_wio_reset
+    .read_csr	= pcnet32_wio_read_csr,
+    .write_csr	= pcnet32_wio_write_csr,
+    .read_bcr	= pcnet32_wio_read_bcr,
+    .write_bcr	= pcnet32_wio_write_bcr,
+    .read_rap	= pcnet32_wio_read_rap,
+    .write_rap	= pcnet32_wio_write_rap,
+    .reset	= pcnet32_wio_reset
 };
 
 static u16 pcnet32_dwio_read_csr (unsigned long addr, int index)
@@ -456,13 +456,13 @@
 }
 
 static struct pcnet32_access pcnet32_dwio = {
-    read_csr:	pcnet32_dwio_read_csr,
-    write_csr:	pcnet32_dwio_write_csr,
-    read_bcr:	pcnet32_dwio_read_bcr,
-    write_bcr:	pcnet32_dwio_write_bcr,
-    read_rap:	pcnet32_dwio_read_rap,
-    write_rap:	pcnet32_dwio_write_rap,
-    reset:	pcnet32_dwio_reset
+    .read_csr	= pcnet32_dwio_read_csr,
+    .write_csr	= pcnet32_dwio_write_csr,
+    .read_bcr	= pcnet32_dwio_read_bcr,
+    .write_bcr	= pcnet32_dwio_write_bcr,
+    .read_rap	= pcnet32_dwio_read_rap,
+    .write_rap	= pcnet32_dwio_write_rap,
+    .reset	= pcnet32_dwio_reset
 };
 
 
@@ -1624,7 +1624,9 @@
 	
 	crc = ether_crc_le(6, addrs);
 	crc = crc >> 26;
-	mcast_table [crc >> 4] |= cpu_to_le16(1 << (crc & 0xf));
+	mcast_table [crc >> 4] = le16_to_cpu(
+		le16_to_cpu(mcast_table [crc >> 4]) | (1 << (crc & 0xf))
+	);
     }
     return;
 }
@@ -1709,9 +1711,9 @@
 }
 
 static struct pci_driver pcnet32_driver = {
-    name:	DRV_NAME,
-    probe:	pcnet32_probe_pci,
-    id_table:	pcnet32_pci_tbl,
+    .name	= DRV_NAME,
+    .probe	= pcnet32_probe_pci,
+    .id_table	= pcnet32_pci_tbl,
 };
 
 MODULE_PARM(debug, "i");

-- 
Don Fry
brazilnut@us.ibm.com
