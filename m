From: varkabhadram@gmail.com
Subject: [PATCH net-next v2 1/2] ethernet: realtek: use module_pci_driver
Date: Tue, 22 Jul 2014 12:50:21 +0530
Message-ID: <1406013622-27869-2-git-send-email-varkabhadram@gmail.com>
References: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>
Cc: davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:59578 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbaGVHWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 03:22:06 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so10783665pdj.29
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 00:22:06 -0700 (PDT)
In-Reply-To: <1406013622-27869-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch converts to use the macro module_pci_driver, which makes
the code smaller and simpler.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/realtek/8139cp.c |   22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 2bc728e..9fb68b9 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -1887,11 +1887,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	resource_size_t pciaddr;
 	unsigned int addr_len, i, pci_using_dac;
 
-#ifndef MODULE
-	static int version_printed;
-	if (version_printed++ == 0)
-		pr_info("%s", version);
-#endif
+	pr_info("%s", version);
 
 	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
 	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && pdev->revision < 0x20) {
@@ -2121,18 +2117,4 @@ static struct pci_driver cp_driver = {
 #endif
 };
 
-static int __init cp_init (void)
-{
-#ifdef MODULE
-	pr_info("%s", version);
-#endif
-	return pci_register_driver(&cp_driver);
-}
-
-static void __exit cp_exit (void)
-{
-	pci_unregister_driver (&cp_driver);
-}
-
-module_init(cp_init);
-module_exit(cp_exit);
+module_pci_driver(cp_driver);
-- 
1.7.9.5
