From: maks attems <debian@sternwelten.at>
Subject: [patch-kj] remove old ifdefs net/eepro100.c
Date: Fri, 23 Jul 2004 17:43:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040723154312.GO1795@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: saw@saw.sw.com.sg, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



 Patches to remove some old ifdefs, 2.2 comptability.
 then remove unused #include <linux/version.h>

applies cleanly to 2.6.8-rc2

From: Domen Puncer <domen@coderock.org>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>



---

 linux-2.6.7-bk20-max/drivers/net/eepro100.c |   17 -----------------
 1 files changed, 17 deletions(-)

diff -puN drivers/net/eepro100.c~remove-old-ifdefs-eepro100 drivers/net/eepro100.c
--- linux-2.6.7-bk20/drivers/net/eepro100.c~remove-old-ifdefs-eepro100	2004-07-11 14:42:27.000000000 +0200
+++ linux-2.6.7-bk20-max/drivers/net/eepro100.c	2004-07-11 14:42:27.000000000 +0200
@@ -88,7 +88,6 @@ static int options[] = {-1, -1, -1, -1, 
 #define PKT_BUF_SZ		1536
 
 #include <linux/config.h>
-#include <linux/version.h>
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -2447,22 +2446,6 @@ static struct pci_driver eepro100_driver
 #endif /* CONFIG_PM */
 };
 
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,3,48)
-static int pci_module_init(struct pci_driver *pdev)
-{
-	int rc;
-
-	rc = pci_register_driver(pdev);
-	if (rc <= 0) {
-		printk(KERN_INFO "%s: No cards found, driver not installed.\n",
-			   pdev->name);
-		pci_unregister_driver(pdev);
-		return -ENODEV;
-	}
-	return 0;
-}
-#endif
-
 static int __init eepro100_init_module(void)
 {
 #ifdef MODULE
