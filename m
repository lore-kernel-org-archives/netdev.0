From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 7 2.6.7-bk11] pcnet32: change to use module_param
Date: Mon, 28 Jun 2004 16:08:09 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406282308.i5SN8AB11334@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change the pcnet32 driver to use module_param and module_param_array.

--- linux-2.6.7-bk11/drivers/net/half.pcnet32.c	Mon Jun 28 12:08:57 2004
+++ linux-2.6.7-bk11/drivers/net/pcnet32.c	Mon Jun 28 15:02:23 2004
@@ -22,8 +22,8 @@
  *************************************************************************/
 
 #define DRV_NAME	"pcnet32"
-#define DRV_VERSION	"1.30h"
-#define DRV_RELDATE	"06.24.2004"
+#define DRV_VERSION	"1.30i"
+#define DRV_RELDATE	"06.28.2004"
 #define PFX		DRV_NAME ": "
 
 static const char *version =
@@ -46,6 +46,7 @@ DRV_NAME ".c:v" DRV_VERSION " " DRV_RELD
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
+#include <linux/moduleparam.h>
 
 #include <asm/bitops.h>
 #include <asm/dma.h>
@@ -254,6 +255,7 @@ static int homepna[MAX_UNITS];
  * v1.30g  22 Jun 2004 Patrick Simmons <psimmons@flash.net> added option
  *	   homepna for selecting HomePNA mode for PCNet/Home 79C978.
  * v1.30h  24 Jun 2004 Don Fry correctly select auto, speed, duplex in bcr32.
+ * v1.30i  28 Jun 2004 Don Fry change to use module_param.
  */
 
 
@@ -2258,22 +2260,28 @@ static struct pci_driver pcnet32_driver 
     .id_table	= pcnet32_pci_tbl,
 };
 
-MODULE_PARM(debug, "i");
+/* An additional parameter that may be passed in... */
+static int debug = -1;
+static int tx_start_pt = -1;
+static int pcnet32_have_pci;
+static int num_params;
+
+module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, DRV_NAME " debug level");
-MODULE_PARM(max_interrupt_work, "i");
+module_param(max_interrupt_work, int, 0);
 MODULE_PARM_DESC(max_interrupt_work, DRV_NAME " maximum events handled per interrupt");
-MODULE_PARM(rx_copybreak, "i");
+module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, DRV_NAME " copy breakpoint for copy-only-tiny-frames");
-MODULE_PARM(tx_start_pt, "i");
+module_param(tx_start_pt, int, 0);
 MODULE_PARM_DESC(tx_start_pt, DRV_NAME " transmit start point (0-3)");
-MODULE_PARM(pcnet32vlb, "i");
+module_param(pcnet32vlb, int, 0);
 MODULE_PARM_DESC(pcnet32vlb, DRV_NAME " Vesa local bus (VLB) support (0/1)");
-MODULE_PARM(options, "1-" __MODULE_STRING(MAX_UNITS) "i");
+module_param_array(options, int, num_params, 0);
 MODULE_PARM_DESC(options, DRV_NAME " initial option setting(s) (0-15)");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(MAX_UNITS) "i");
+module_param_array(full_duplex, int, num_params, 0);
 MODULE_PARM_DESC(full_duplex, DRV_NAME " full duplex setting(s) (1)");
 /* Module Parameter for HomePNA cards added by Patrick Simmons, 2004 */
-MODULE_PARM(homepna,"1-" __MODULE_STRING(MAX_UNITS) "i");
+module_param_array(homepna, int, num_params, 0);
 MODULE_PARM_DESC(homepna, DRV_NAME " mode for 79C978 cards (1 for HomePNA, 0 for Ethernet, default Ethernet");
 
 MODULE_AUTHOR("Thomas Bogendoerfer");
@@ -2282,11 +2290,6 @@ MODULE_LICENSE("GPL");
 
 #define PCNET32_MSG_DEFAULT (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
-/* An additional parameter that may be passed in... */
-static int debug = -1;
-static int tx_start_pt = -1;
-static int pcnet32_have_pci;
-
 static int __init pcnet32_init_module(void)
 {
     printk(KERN_INFO "%s", version);

-- 
Don Fry
brazilnut@us.ibm.com
