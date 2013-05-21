From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 11/19] net/ethernet/broadcom/tg3: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:58:06 +0200
Message-ID: <1369177096-19674-11-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org (open list:BROADCOM TG3 GIGA...),
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
 drivers/net/ethernet/broadcom/tg3.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index fb06aa1..4f0e3fe 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17804,15 +17804,4 @@ static struct pci_driver tg3_driver = {
 	.driver.pm	= &tg3_pm_ops,
 };
 
-static int __init tg3_init(void)
-{
-	return pci_register_driver(&tg3_driver);
-}
-
-static void __exit tg3_cleanup(void)
-{
-	pci_unregister_driver(&tg3_driver);
-}
-
-module_init(tg3_init);
-module_exit(tg3_cleanup);
+module_pci_driver(tg3_driver);
-- 
1.8.1.5
