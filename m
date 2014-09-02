From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 1/6] ixgb: remove the boilerplate of
	ixgb module for init/exit
Date: Tue,  2 Sep 2014 03:36:51 -0600
Message-ID: <1409650616-1035-2-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux.nics@intel.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use module_pci_driver() to simplify ixgb driver module init/exit
routine. 

After the change, the basic driver info doesn't print unless the
pertinent hardware is present. Printing such info generally
pronounces the presence of the hardware and it should be part of the
probe routine. Blindly printing not only clutters the console, but
also incurs unnecessary confusion.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 39 ++++-------------------------
 1 file changed, 5 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 055961b0f24b..339e1535482e 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -70,8 +70,6 @@ static const struct pci_device_id ixgb_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci, ixgb_pci_tbl);
 
 /* Local Function Prototypes */
-static int ixgb_init_module(void);
-static void ixgb_exit_module(void);
 static int ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void ixgb_remove(struct pci_dev *pdev);
 static int ixgb_sw_init(struct ixgb_adapter *adapter);
@@ -141,38 +139,7 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
-/**
- * ixgb_init_module - Driver Registration Routine
- *
- * ixgb_init_module is the first routine called when the driver is
- * loaded. All it does is register with the PCI subsystem.
- **/
-
-static int __init
-ixgb_init_module(void)
-{
-	pr_info("%s - version %s\n", ixgb_driver_string, ixgb_driver_version);
-	pr_info("%s\n", ixgb_copyright);
-
-	return pci_register_driver(&ixgb_driver);
-}
-
-module_init(ixgb_init_module);
-
-/**
- * ixgb_exit_module - Driver Exit Cleanup Routine
- *
- * ixgb_exit_module is called just before the driver is removed
- * from memory.
- **/
-
-static void __exit
-ixgb_exit_module(void)
-{
-	pci_unregister_driver(&ixgb_driver);
-}
-
-module_exit(ixgb_exit_module);
+module_pci_driver(ixgb_driver);
 
 /**
  * ixgb_irq_disable - Mask off interrupt generation on the NIC
@@ -403,6 +370,10 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int i;
 	int err;
 
+	pr_info_once("%s - version %s\n",
+		     ixgb_driver_string, ixgb_driver_version);
+	pr_info_once("%s\n", ixgb_copyright);
+
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
