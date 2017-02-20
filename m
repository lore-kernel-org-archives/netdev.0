From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v3 04/12] net: ethernet: aquantia: Using module_pci_driver.
Date: Mon, 20 Feb 2017 14:41:46 +0300
Message-ID: <7597a017aa4fcfbf69a393cee4ce367acd77f66f.1487590641.git.pavel.belous@aquantia.com>
References: <cover.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0086.outbound.protection.outlook.com ([104.47.42.86]:47808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752195AbdBTLmy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 06:42:54 -0500
In-Reply-To: <cover.1487590641.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Remove boilerplate code by using macro module_pci_driver.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c | 20 +-------------------
 1 file changed, 1 insertion(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
index 45c769e..91c66f5 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -242,22 +242,4 @@ static struct pci_driver aq_pci_ops = {
 	.resume = aq_pci_resume,
 };
 
-static int __init aq_module_init(void)
-{
-	int err = 0;
-
-	err = pci_register_driver(&aq_pci_ops);
-	if (err < 0)
-		goto err_exit;
-
-err_exit:
-	return err;
-}
-
-static void __exit aq_module_exit(void)
-{
-	pci_unregister_driver(&aq_pci_ops);
-}
-
-module_init(aq_module_init);
-module_exit(aq_module_exit);
+module_pci_driver(aq_pci_ops);
-- 
2.7.4
