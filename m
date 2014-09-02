From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 4/6] igbvf: remove the boilerplate of
	igbvf module for init/exit
Date: Tue,  2 Sep 2014 03:36:54 -0600
Message-ID: <1409650616-1035-5-git-send-email-sakiwit@gmail.com>
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

Use module_pci_driver() to simplify igbvf driver module init/exit
routine.

After the change, the basic driver info doesn't print unless the
pertinent hardware is present. Printing such info generally
pronounces the presence of the hardware and it should be part of the
probe routine. Blindly printing not only clutters the console, but
also incurs unnecessary confusion.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 35 +++++--------------------------
 1 file changed, 5 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 63c807c9b21c..f3b4d7f676f1 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2630,6 +2630,10 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	static int cards_found;
 	int err, pci_using_dac;
 
+	pr_info_once("%s - version %s\n",
+		     igbvf_driver_string, igbvf_driver_version);
+	pr_info_once("%s\n", igbvf_copyright);
+
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
@@ -2875,36 +2879,7 @@ static struct pci_driver igbvf_driver = {
 	.err_handler = &igbvf_err_handler
 };
 
-/**
- * igbvf_init_module - Driver Registration Routine
- *
- * igbvf_init_module is the first routine called when the driver is
- * loaded. All it does is register with the PCI subsystem.
- **/
-static int __init igbvf_init_module(void)
-{
-	int ret;
-	pr_info("%s - version %s\n", igbvf_driver_string, igbvf_driver_version);
-	pr_info("%s\n", igbvf_copyright);
-
-	ret = pci_register_driver(&igbvf_driver);
-
-	return ret;
-}
-module_init(igbvf_init_module);
-
-/**
- * igbvf_exit_module - Driver Exit Cleanup Routine
- *
- * igbvf_exit_module is called just before the driver is removed
- * from memory.
- **/
-static void __exit igbvf_exit_module(void)
-{
-	pci_unregister_driver(&igbvf_driver);
-}
-module_exit(igbvf_exit_module);
-
+module_pci_driver(igbvf_driver);
 
 MODULE_AUTHOR("Intel Corporation, <e1000-devel@lists.sourceforge.net>");
 MODULE_DESCRIPTION("Intel(R) Gigabit Virtual Function Network Driver");

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
