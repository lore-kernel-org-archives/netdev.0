From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] net: fix pch_gbe section mismatch warning
Date: Thu, 24 Mar 2011 13:28:12 -0700
Message-ID: <20110324132812.5bd28f51.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50107 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933155Ab1CXU2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2011 16:28:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix section mismatch warning by renaming the pci_driver variable to a
recognized (whitelisted) name.

WARNING: drivers/net/pch_gbe/pch_gbe.o(.data+0x1f8): Section mismatch in reference from the variable pch_gbe_pcidev to the variable .devinit.rodata:pch_gbe_pcidev_id
The variable pch_gbe_pcidev references
the variable __devinitconst pch_gbe_pcidev_id
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*driver, *_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-2.6.38-git13.orig/drivers/net/pch_gbe/pch_gbe_main.c
+++ linux-2.6.38-git13/drivers/net/pch_gbe/pch_gbe_main.c
@@ -2441,7 +2441,7 @@ static struct pci_error_handlers pch_gbe
 	.resume = pch_gbe_io_resume
 };
 
-static struct pci_driver pch_gbe_pcidev = {
+static struct pci_driver pch_gbe_driver = {
 	.name = KBUILD_MODNAME,
 	.id_table = pch_gbe_pcidev_id,
 	.probe = pch_gbe_probe,
@@ -2458,7 +2458,7 @@ static int __init pch_gbe_init_module(vo
 {
 	int ret;
 
-	ret = pci_register_driver(&pch_gbe_pcidev);
+	ret = pci_register_driver(&pch_gbe_driver);
 	if (copybreak != PCH_GBE_COPYBREAK_DEFAULT) {
 		if (copybreak == 0) {
 			pr_info("copybreak disabled\n");
@@ -2472,7 +2472,7 @@ static int __init pch_gbe_init_module(vo
 
 static void __exit pch_gbe_exit_module(void)
 {
-	pci_unregister_driver(&pch_gbe_pcidev);
+	pci_unregister_driver(&pch_gbe_driver);
 }
 
 module_init(pch_gbe_init_module);
