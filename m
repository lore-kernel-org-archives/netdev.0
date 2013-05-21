From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 16/19] net/hippi/rrunner: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 01:42:53 +0200
Message-ID: <1369179778-20115-16-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Jes Sorensen <jes@trained-monkey.org>,
	linux-hippi@sunsite.dk (open list:HIPPI),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing some boilerplate by using module_pci_driver instead of calling
register and unregister in the otherwise empty init/exit functions.

Signed-off-by: Peter Huewe <peterhuewe@gmx.de>
---
 drivers/net/hippi/rrunner.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 3c4d627..00ed751 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1686,15 +1686,4 @@ static struct pci_driver rr_driver = {
 	.remove		= rr_remove_one,
 };
 
-static int __init rr_init_module(void)
-{
-	return pci_register_driver(&rr_driver);
-}
-
-static void __exit rr_cleanup_module(void)
-{
-	pci_unregister_driver(&rr_driver);
-}
-
-module_init(rr_init_module);
-module_exit(rr_cleanup_module);
+module_pci_driver(rr_driver);
-- 
1.8.1.5
