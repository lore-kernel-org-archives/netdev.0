From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 01/19] net/ethernet/silan/sc92031: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:42:06 +0200
Message-ID: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Jiri Pirko <jiri@resnulli.us>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
This time against net-next and compile tested on x86 with allmodconfig.
Sorry for the broken/duplicated patches yesterday

 drivers/net/ethernet/silan/sc92031.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 28f7268..5eb933c 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1578,19 +1578,7 @@ static struct pci_driver sc92031_pci_driver = {
 	.resume		= sc92031_resume,
 };
 
-static int __init sc92031_init(void)
-{
-	return pci_register_driver(&sc92031_pci_driver);
-}
-
-static void __exit sc92031_exit(void)
-{
-	pci_unregister_driver(&sc92031_pci_driver);
-}
-
-module_init(sc92031_init);
-module_exit(sc92031_exit);
-
+module_pci_driver(sc92031_pci_driver);
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Cesar Eduardo Barros <cesarb@cesarb.net>");
 MODULE_DESCRIPTION("Silan SC92031 PCI Fast Ethernet Adapter driver");
-- 
1.8.1.5
