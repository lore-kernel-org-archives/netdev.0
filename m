From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] atm: simplify lanai.c by using module_pci_driver
Date: Wed, 15 Oct 2014 09:45:50 +0200
Message-ID: <1413359150-13552-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: chas@cmf.nrl.navy.mil
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This simplifies the lanai.c driver by using
the module_pci_driver() macro, at the expense
of losing only debugging messages.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/atm/lanai.c | 22 +---------------------
 1 file changed, 1 insertion(+), 21 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index fa7d701933ba..93eaf8d94492 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -2614,27 +2614,7 @@ static struct pci_driver lanai_driver = {
 	.probe    = lanai_init_one,
 };
 
-static int __init lanai_module_init(void)
-{
-	int x;
-
-	x = pci_register_driver(&lanai_driver);
-	if (x != 0)
-		printk(KERN_ERR DEV_LABEL ": no adapter found\n");
-	return x;
-}
-
-static void __exit lanai_module_exit(void)
-{
-	/* We'll only get called when all the interfaces are already
-	 * gone, so there isn't much to do
-	 */
-	DPRINTK("cleanup_module()\n");
-	pci_unregister_driver(&lanai_driver);
-}
-
-module_init(lanai_module_init);
-module_exit(lanai_module_exit);
+module_pci_driver(lanai_driver);
 
 MODULE_AUTHOR("Mitchell Blank Jr <mitch@sfgoth.com>");
 MODULE_DESCRIPTION("Efficient Networks Speedstream 3010 driver");
-- 
1.9.1
