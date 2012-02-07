From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] e1000e: add missing initializers reported when compiling with W=1
Date: Tue,  7 Feb 2012 04:33:50 -0800
Message-ID: <1328618038-5008-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47275 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755676Ab2BGMeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 07:34:13 -0500
In-Reply-To: <1328618038-5008-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

warning: missing initializer

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 1a8dd2f..c05137f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -137,7 +137,7 @@ static const struct e1000_reg_info e1000_reg_info_tbl[] = {
 	{E1000_TDFPC, "TDFPC"},
 
 	/* List Terminator */
-	{}
+	{0, NULL}
 };
 
 /*
@@ -6502,7 +6502,7 @@ static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH2_LV_LM), board_pch2lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH2_LV_V), board_pch2lan },
 
-	{ }	/* terminate list */
+	{ 0, 0, 0, 0, 0, 0, 0 }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
 
@@ -6521,7 +6521,9 @@ static struct pci_driver e1000_driver = {
 	.probe    = e1000_probe,
 	.remove   = __devexit_p(e1000_remove),
 #ifdef CONFIG_PM
-	.driver.pm = &e1000_pm_ops,
+	.driver   = {
+		.pm = &e1000_pm_ops,
+	},
 #endif
 	.shutdown = e1000_shutdown,
 	.err_handler = &e1000_err_handler
-- 
1.7.7.6
