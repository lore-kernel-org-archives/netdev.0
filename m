From: varkabhadram@gmail.com
Subject: [PATCH net-next v3 1/2] ethernet: realtek: use module_pci_driver
Date: Wed, 23 Jul 2014 09:19:48 +0530
Message-ID: <1406087389-4436-2-git-send-email-varkabhadram@gmail.com>
References: <1406087389-4436-1-git-send-email-varkabhadram@gmail.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406087389-4436-1-git-send-email-varkabhadram@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram <varkab@cdac.in>

This patch converts to use the macro module_pci_driver, which makes
the code smaller and simpler.

Previously in this driver we are having driver version info will be
printed log buffer based on whether the driver selected as module
or statically into image itself. By using the module_pci_driver that
part of the code removed. For the first time of the device init,
we are making the version info to be printed once.

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/realtek/8139cp.c |   22 ++--------------------
 1 file changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 2bc728e..be101ca 100644
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
+	pr_info_once("%s", version);
 
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
