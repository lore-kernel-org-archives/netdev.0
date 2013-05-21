From: Peter Huewe <peterhuewe@gmx.de>
Subject: [PATCH 05/19] net/ethernet/sis/sis190: Use module_pci_driver to register driver
Date: Wed, 22 May 2013 00:42:10 +0200
Message-ID: <1369176146-19383-5-git-send-email-peterhuewe@gmx.de>
References: <1369176146-19383-1-git-send-email-peterhuewe@gmx.de>
Cc: Peter Huewe <peterhuewe@gmx.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org (open list:SIS 190 ETHERNET...),
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
 drivers/net/ethernet/sis/sis190.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index 9a9c379..02df089 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -1934,15 +1934,4 @@ static struct pci_driver sis190_pci_driver = {
 	.remove		= sis190_remove_one,
 };
 
-static int __init sis190_init_module(void)
-{
-	return pci_register_driver(&sis190_pci_driver);
-}
-
-static void __exit sis190_cleanup_module(void)
-{
-	pci_unregister_driver(&sis190_pci_driver);
-}
-
-module_init(sis190_init_module);
-module_exit(sis190_cleanup_module);
+module_pci_driver(sis190_pci_driver);
-- 
1.8.1.5
