From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 10/19] net/ethernet/broadcom/bnx2: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:58:05 +0200
Message-ID: <1369177096-19674-10-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>, Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org (open list:BROADCOM BNX2 GIG...),
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
 drivers/net/ethernet/broadcom/bnx2.c | 16 +---------------
 1 file changed, 1 insertion(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 5d20449..1a1b23e 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -8764,18 +8764,4 @@ static struct pci_driver bnx2_pci_driver = {
 	.err_handler	= &bnx2_err_handler,
 };
 
-static int __init bnx2_init(void)
-{
-	return pci_register_driver(&bnx2_pci_driver);
-}
-
-static void __exit bnx2_cleanup(void)
-{
-	pci_unregister_driver(&bnx2_pci_driver);
-}
-
-module_init(bnx2_init);
-module_exit(bnx2_cleanup);
-
-
-
+module_pci_driver(bnx2_pci_driver);
-- 
1.8.1.5
