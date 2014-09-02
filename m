From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 5/6] e1000e: remove the boilerplate
	of e1000e module for init/exit
Date: Tue,  2 Sep 2014 03:36:55 -0600
Message-ID: <1409650616-1035-6-git-send-email-sakiwit@gmail.com>
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

Use module_pci_driver() to simplify e1000e driver module init/exit
routine.

After the change, the basic driver info doesn't print unless the
pertinent hardware is present. Printing such info generally
pronounces the presence of the hardware and it should be part of the
probe routine. Blindly printing not only clutters the console, but
also incurs unnecessary confusion.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 35 +++++-------------------------
 1 file changed, 5 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 65c3aef2bd36..1b5f99028ac6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6741,6 +6741,10 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	s32 rval = 0;
 
+	pr_info_once("Intel(R) PRO/1000 Network Driver - %s\n",
+		     e1000e_driver_version);
+	pr_info_once("Copyright(c) 1999 - 2014 Intel Corporation.\n");
+
 	if (ei->flags2 & FLAG2_DISABLE_ASPM_L0S)
 		aspm_disable_flag = PCIE_LINK_STATE_L0S;
 	if (ei->flags2 & FLAG2_DISABLE_ASPM_L1)
@@ -7249,36 +7253,7 @@ static struct pci_driver e1000_driver = {
 	.err_handler = &e1000_err_handler
 };
 
-/**
- * e1000_init_module - Driver Registration Routine
- *
- * e1000_init_module is the first routine called when the driver is
- * loaded. All it does is register with the PCI subsystem.
- **/
-static int __init e1000_init_module(void)
-{
-	int ret;
-
-	pr_info("Intel(R) PRO/1000 Network Driver - %s\n",
-		e1000e_driver_version);
-	pr_info("Copyright(c) 1999 - 2014 Intel Corporation.\n");
-	ret = pci_register_driver(&e1000_driver);
-
-	return ret;
-}
-module_init(e1000_init_module);
-
-/**
- * e1000_exit_module - Driver Exit Cleanup Routine
- *
- * e1000_exit_module is called just before the driver is removed
- * from memory.
- **/
-static void __exit e1000_exit_module(void)
-{
-	pci_unregister_driver(&e1000_driver);
-}
-module_exit(e1000_exit_module);
+module_pci_driver(e1000_driver);
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
