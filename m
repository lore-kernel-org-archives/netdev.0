From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH] 2.4.25 pcnet32.c wrong vendor ID fix
Date: Thu, 19 Feb 2004 09:15:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402191715.i1JHFfZ05059@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch was originally sent by Jon Mason on Sat Jan 31.

"I created a patch that allows pcnet32 adapters sold in IBM RS/6000 systems
to be recognized in non-ppc computers.  The problem is that the Vendor ID
of this adapter is incorrect.  There is a ppc specific workaround to get
it working on that architecture (checkout
http://lxr.linux.no/source/arch/ppc/kernel/pci.c?a=ppc#L87
for the workaround), but it obviously won't fix the problem in non-ppc
architectures."

--- linux-2.4.25/drivers/net/hang.pcnet32.c	Thu Feb 19 08:51:34 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Thu Feb 19 08:54:43 2004
@@ -61,6 +61,12 @@
 static struct pci_device_id pcnet32_pci_tbl[] __devinitdata = {
     { PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
     { PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+    /*
+     * Adapters that were sold with IBM's RS/6000 or pSeries hardware have
+     * the incorrect vendor id.
+     */
+    { PCI_VENDOR_ID_TRIDENT, PCI_DEVICE_ID_AMD_LANCE, PCI_ANY_ID, PCI_ANY_ID,
+	    PCI_CLASS_NETWORK_ETHERNET << 8, 0xffff00, 0 },
     { 0, }
 };
 

-- 
Don Fry
brazilnut@us.ibm.com
