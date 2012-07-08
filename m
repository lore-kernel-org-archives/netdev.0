From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] r6040: use module_pci_driver macro
Date: Sun,  8 Jul 2012 21:27:57 +0530
Message-ID: <1341763077-938-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:62650 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab2GHP6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2012 11:58:07 -0400
Received: by pbbrp8 with SMTP id rp8so17836171pbb.19
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2012 08:58:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

as the manual of module_pci_driver says that
it can be used when the init and exit functions of
the module does nothing but the pci_register_driver
and pci_unregister_driver.

use it for rdc's r6040 driver, as the init and exit
paths does as above, and also this reduces a little
amount of code.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |   15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 9acc026..557a265 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1277,17 +1277,4 @@ static struct pci_driver r6040_driver = {
 	.remove		= __devexit_p(r6040_remove_one),
 };
 
-
-static int __init r6040_init(void)
-{
-	return pci_register_driver(&r6040_driver);
-}
-
-
-static void __exit r6040_cleanup(void)
-{
-	pci_unregister_driver(&r6040_driver);
-}
-
-module_init(r6040_init);
-module_exit(r6040_cleanup);
+module_pci_driver(r6040_driver);
-- 
1.7.9.5
