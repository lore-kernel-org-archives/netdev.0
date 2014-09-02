From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 3/6] e100: remove the boilerplate of
	e100 module for init/exit
Date: Tue,  2 Sep 2014 03:36:53 -0600
Message-ID: <1409650616-1035-4-git-send-email-sakiwit@gmail.com>
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

Use module_pci_driver() to simplify e100 driver module init/exit
routine.

After the change, the basic driver info doesn't print unless the
pertinent hardware is present. Printing such info generally
pronounces the presence of the hardware and it should be part of the
probe routine. Blindly printing not only clutters the console, but
also incurs unnecessary confusion.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/e100.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index 781065eb5431..8b95129fcf91 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2846,6 +2846,11 @@ static int e100_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct nic *nic;
 	int err;
 
+	if (((1 << debug) - 1) & NETIF_MSG_DRV) {
+		pr_info_once("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+		pr_info_once("%s\n", DRV_COPYRIGHT);
+	}
+
 	if (!(netdev = alloc_etherdev(sizeof(struct nic))))
 		return -ENOMEM;
 
@@ -3184,19 +3189,4 @@ static struct pci_driver e100_driver = {
 	.err_handler = &e100_err_handler,
 };
 
-static int __init e100_init_module(void)
-{
-	if (((1 << debug) - 1) & NETIF_MSG_DRV) {
-		pr_info("%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
-		pr_info("%s\n", DRV_COPYRIGHT);
-	}
-	return pci_register_driver(&e100_driver);
-}
-
-static void __exit e100_cleanup_module(void)
-{
-	pci_unregister_driver(&e100_driver);
-}
-
-module_init(e100_init_module);
-module_exit(e100_cleanup_module);
+module_pci_driver(e100_driver);

------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
