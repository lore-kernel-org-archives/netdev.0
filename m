From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.7-rc3-mm2 1/5] via-velocity: PCI ID move
Date: Fri, 18 Jun 2004 22:10:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618221014.A15640@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@redhat.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(Note: this serie requires a -mm based kernel as the via-velocity patches
are not included in Jeff's -netdev patches).



PCI ID moved from the driver to the kernel database. A change for the
pci.ids file project at souceforge has been submitted as well.

diff -puN drivers/net/via-velocity.c~via-velocity-20 drivers/net/via-velocity.c
--- linux-2.6.7-rc3/drivers/net/via-velocity.c~via-velocity-20	2004-06-18 21:24:53.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.c	2004-06-18 21:32:01.000000000 +0200
@@ -290,8 +290,9 @@ static struct velocity_info_tbl chip_inf
  */
 
 static struct pci_device_id velocity_id_table[] __devinitdata = {
-	{0x1106, 0x3119, PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) &chip_info_table[0]},
-	{0,}
+	{PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X,
+	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, (unsigned long) chip_info_table},
+	{0, }
 };
 
 MODULE_DEVICE_TABLE(pci, velocity_id_table);
diff -puN include/linux/pci_ids.h~via-velocity-20 include/linux/pci_ids.h
--- linux-2.6.7-rc3/include/linux/pci_ids.h~via-velocity-20	2004-06-18 21:24:53.000000000 +0200
+++ linux-2.6.7-rc3-fr/include/linux/pci_ids.h	2004-06-18 21:24:53.000000000 +0200
@@ -1214,6 +1214,7 @@
 #define PCI_DEVICE_ID_VIA_8233C_0	0x3109
 #define PCI_DEVICE_ID_VIA_8361		0x3112
 #define PCI_DEVICE_ID_VIA_XM266		0x3116
+#define PCI_DEVICE_ID_VIA_612X		0x3119
 #define PCI_DEVICE_ID_VIA_862X_0	0x3123
 #define PCI_DEVICE_ID_VIA_8753_0	0x3128
 #define PCI_DEVICE_ID_VIA_8233A		0x3147
diff -puN drivers/net/via-velocity.h~via-velocity-20 drivers/net/via-velocity.h
--- linux-2.6.7-rc3/drivers/net/via-velocity.h~via-velocity-20	2004-06-18 21:24:53.000000000 +0200
+++ linux-2.6.7-rc3-fr/drivers/net/via-velocity.h	2004-06-18 21:32:00.000000000 +0200
@@ -37,7 +37,6 @@
 #define OPTION_DEFAULT      { [0 ... MAX_UNITS-1] = -1}
 
 #define REV_ID_VT6110       (0)
-#define DEVICE_ID           (0x3119)
 
 #define BYTE_REG_BITS_ON(x,p)       do { writeb(readb((p))|(x),(p));} while (0)
 #define WORD_REG_BITS_ON(x,p)       do { writew(readw((p))|(x),(p));} while (0)

_
