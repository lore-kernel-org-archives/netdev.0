From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] ksz884x: use module_pci_driver to simplify the code
Date: Wed, 7 Nov 2012 20:54:30 +0800
Message-ID: <CAPgLHd8mrDXyiJ4rNFLHsYWEreVRiKXwqqr7umtSY36RkzXjUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:55973 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822Ab2KGMyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 07:54:31 -0500
Received: by mail-qc0-f174.google.com with SMTP id o22so987131qcr.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 04:54:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Use the module_pci_driver() macro to make the code simpler
by eliminating module_init and module_exit calls.

dpatch engine is used to auto generate this patch.
(https://github.com/weiyj/dpatch)

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/micrel/ksz884x.c | 13 +------------
 1 file changed, 1 insertion(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e558edd..e4ba868 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7251,18 +7251,7 @@ static struct pci_driver pci_device_driver = {
 	.remove		= pcidev_exit
 };
 
-static int __init ksz884x_init_module(void)
-{
-	return pci_register_driver(&pci_device_driver);
-}
-
-static void __exit ksz884x_cleanup_module(void)
-{
-	pci_unregister_driver(&pci_device_driver);
-}
-
-module_init(ksz884x_init_module);
-module_exit(ksz884x_cleanup_module);
+module_pci_driver(pci_device_driver);
 
 MODULE_DESCRIPTION("KSZ8841/2 PCI network driver");
 MODULE_AUTHOR("Tristram Ha <Tristram.Ha@micrel.com>");
