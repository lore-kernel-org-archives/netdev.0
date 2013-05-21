From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 18/19] net/ethernet/chelsio/cxgb/cxgb2: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 01:42:55 +0200
Message-ID: <1369179778-20115-18-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

The name of the pci_driver struct had to be changed in order to prevent
a build failure.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index 9624cfe..d7048db 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -1351,22 +1351,11 @@ static void remove_one(struct pci_dev *pdev)
 	t1_sw_reset(pdev);
 }
 
-static struct pci_driver driver = {
+static struct pci_driver cxgb_pci_driver = {
 	.name     = DRV_NAME,
 	.id_table = t1_pci_tbl,
 	.probe    = init_one,
 	.remove   = remove_one,
 };
 
-static int __init t1_init_module(void)
-{
-	return pci_register_driver(&driver);
-}
-
-static void __exit t1_cleanup_module(void)
-{
-	pci_unregister_driver(&driver);
-}
-
-module_init(t1_init_module);
-module_exit(t1_cleanup_module);
+module_pci_driver(cxgb_pci_driver);
-- 
1.8.1.5
