From: Axel Lin <axel.lin@gmail.com>
Subject: [PATCH 3/3] net/wan: use module_pci_driver
Date: Sat, 14 Apr 2012 12:41:21 +0800
Message-ID: <1334378481.2862.4.camel@phoenix>
References: <1334378323.2862.1.camel@phoenix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45008 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab2DNEl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2012 00:41:27 -0400
Received: by pbcun15 with SMTP id un15so4317868pbc.19
        for <netdev@vger.kernel.org>; Fri, 13 Apr 2012 21:41:26 -0700 (PDT)
In-Reply-To: <1334378323.2862.1.camel@phoenix>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the drivers in drivers/net/wan/* to use
module_pci_driver() macro which makes the code smaller and a bit simpler.

Signed-off-by: Axel Lin <axel.lin@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/wan/dscc4.c        |   13 +------------
 drivers/net/wan/lmc/lmc_main.c |   13 +------------
 2 files changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index c676de7..9eb6479 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -2055,15 +2055,4 @@ static struct pci_driver dscc4_driver = {
 	.remove		= __devexit_p(dscc4_remove_one),
 };
 
-static int __init dscc4_init_module(void)
-{
-	return pci_register_driver(&dscc4_driver);
-}
-
-static void __exit dscc4_cleanup_module(void)
-{
-	pci_unregister_driver(&dscc4_driver);
-}
-
-module_init(dscc4_init_module);
-module_exit(dscc4_cleanup_module);
+module_pci_driver(dscc4_driver);
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 76a8a4a..b8da30a 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1736,18 +1736,7 @@ static struct pci_driver lmc_driver = {
 	.remove		= __devexit_p(lmc_remove_one),
 };
 
-static int __init init_lmc(void)
-{
-    return pci_register_driver(&lmc_driver);
-}
-
-static void __exit exit_lmc(void)
-{
-    pci_unregister_driver(&lmc_driver);
-}
-
-module_init(init_lmc);
-module_exit(exit_lmc);
+module_pci_driver(lmc_driver);
 
 unsigned lmc_mii_readreg (lmc_softc_t * const sc, unsigned devaddr, unsigned regno) /*fold00*/
 {
-- 
1.7.5.4
