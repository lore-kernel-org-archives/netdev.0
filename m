From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 6/6] i40evf: remove the boilerplate
	of i40evf module for init/exit
Date: Tue,  2 Sep 2014 03:36:56 -0600
Message-ID: <1409650616-1035-7-git-send-email-sakiwit@gmail.com>
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

Use module_pci_driver() to simplify i40evf driver module init/exit
routine.

After the change, the basic driver info doesn't print unless the
pertinent hardware is present. Printing such info generally
pronounces the presence of the hardware and it should be part of the
probe routine. Blindly printing not only clutters the console, but
also incurs unnecessary confusion.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 37 ++++---------------------
 1 file changed, 5 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 38429fae4fcf..e577b1c6dcab 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2255,6 +2255,10 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct i40e_hw *hw = NULL;
 	int err;
 
+	pr_info_once("i40evf: %s - version %s\n",
+		     i40evf_driver_string, i40evf_driver_version);
+	pr_info_once("%s\n", i40evf_copyright);
+
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
@@ -2491,37 +2495,6 @@ static struct pci_driver i40evf_driver = {
 	.shutdown = i40evf_shutdown,
 };
 
-/**
- * i40e_init_module - Driver Registration Routine
- *
- * i40e_init_module is the first routine called when the driver is
- * loaded. All it does is register with the PCI subsystem.
- **/
-static int __init i40evf_init_module(void)
-{
-	int ret;
-	pr_info("i40evf: %s - version %s\n", i40evf_driver_string,
-	       i40evf_driver_version);
-
-	pr_info("%s\n", i40evf_copyright);
-
-	ret = pci_register_driver(&i40evf_driver);
-	return ret;
-}
-
-module_init(i40evf_init_module);
-
-/**
- * i40e_exit_module - Driver Exit Cleanup Routine
- *
- * i40e_exit_module is called just before the driver is removed
- * from memory.
- **/
-static void __exit i40evf_exit_module(void)
-{
-	pci_unregister_driver(&i40evf_driver);
-}
-
-module_exit(i40evf_exit_module);
+module_pci_driver(i40evf_driver);
 
 /* i40evf_main.c */

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
