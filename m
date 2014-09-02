From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 2/6] ixgbevf: remove the boilerplate
	of ixgbevf module for init/exit
Date: Tue,  2 Sep 2014 03:36:52 -0600
Message-ID: <1409650616-1035-3-git-send-email-sakiwit@gmail.com>
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

Use module_pci_driver() to simplify ixgbevf driver module init/exit
routine.

After the change, the basic driver info doesn't print unless the
pertinent hardware is present. Printing such info generally
pronounces the presence of the hardware and it should be part of the
probe routine. Blindly printing not only clutters the console, but
also incurs unnecessary confusion.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 38 ++++-------------------
 1 file changed, 6 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index c22a00c3621a..e93b4d2a17f8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3467,6 +3467,10 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int cards_found;
 	int err, pci_using_dac;
 
+	pr_info_once("%s - version %s\n",
+		     ixgbevf_driver_string, ixgbevf_driver_version);
+	pr_info_once("%s\n", ixgbevf_copyright);
+
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
@@ -3761,37 +3765,6 @@ static struct pci_driver ixgbevf_driver = {
 	.err_handler = &ixgbevf_err_handler
 };
 
-/**
- * ixgbevf_init_module - Driver Registration Routine
- *
- * ixgbevf_init_module is the first routine called when the driver is
- * loaded. All it does is register with the PCI subsystem.
- **/
-static int __init ixgbevf_init_module(void)
-{
-	int ret;
-	pr_info("%s - version %s\n", ixgbevf_driver_string,
-		ixgbevf_driver_version);
-
-	pr_info("%s\n", ixgbevf_copyright);
-
-	ret = pci_register_driver(&ixgbevf_driver);
-	return ret;
-}
-
-module_init(ixgbevf_init_module);
-
-/**
- * ixgbevf_exit_module - Driver Exit Cleanup Routine
- *
- * ixgbevf_exit_module is called just before the driver is removed
- * from memory.
- **/
-static void __exit ixgbevf_exit_module(void)
-{
-	pci_unregister_driver(&ixgbevf_driver);
-}
-
 #ifdef DEBUG
 /**
  * ixgbevf_get_hw_dev_name - return device name string
@@ -3804,6 +3777,7 @@ char *ixgbevf_get_hw_dev_name(struct ixgbe_hw *hw)
 }
 
 #endif
-module_exit(ixgbevf_exit_module);
+
+module_pci_driver(ixgbevf_driver);
 
 /* ixgbevf_main.c */

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
