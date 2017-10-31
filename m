From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] i40e: mark PM functions as __maybe_unused
Date: Tue, 31 Oct 2017 11:40:04 -0700
Message-ID: <20171031184012.29690-2-jeffrey.t.kirsher@intel.com>
References: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21198 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932584AbdJaSkg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:40:36 -0400
In-Reply-To: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

A cleanup of the PM code left an incorrect #ifdef in place, leading
to a harmless build warning:

drivers/net/ethernet/intel/i40e/i40e_main.c:12223:12: error: 'i40e_resume' defined but not used [-Werror=unused-function]
drivers/net/ethernet/intel/i40e/i40e_main.c:12185:12: error: 'i40e_suspend' defined but not used [-Werror=unused-function]

It's easier to use __maybe_unused attributes here, since you
can't pick the wrong one.

Fixes: 0e5d3da40055 ("i40e: use newer generic PM support instead of legacy PM callbacks")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Acked-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 54ff34faca37..2a087319c09b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9557,7 +9557,6 @@ static int i40e_init_interrupt_scheme(struct i40e_pf *pf)
 	return 0;
 }
 
-#ifdef CONFIG_PM
 /**
  * i40e_restore_interrupt_scheme - Restore the interrupt scheme
  * @pf: private board data structure
@@ -9606,7 +9605,6 @@ static int i40e_restore_interrupt_scheme(struct i40e_pf *pf)
 
 	return err;
 }
-#endif /* CONFIG_PM */
 
 /**
  * i40e_setup_misc_vector - Setup the misc vector to handle non queue events
@@ -13285,12 +13283,11 @@ static void i40e_shutdown(struct pci_dev *pdev)
 	}
 }
 
-#ifdef CONFIG_PM
 /**
  * i40e_suspend - PM callback for moving to D3
  * @dev: generic device information structure
  **/
-static int i40e_suspend(struct device *dev)
+static int __maybe_unused i40e_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
@@ -13328,7 +13325,7 @@ static int i40e_suspend(struct device *dev)
  * i40e_resume - PM callback for waking up from D3
  * @dev: generic device information structure
  **/
-static int i40e_resume(struct device *dev)
+static int __maybe_unused i40e_resume(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
@@ -13360,8 +13357,6 @@ static int i40e_resume(struct device *dev)
 	return 0;
 }
 
-#endif /* CONFIG_PM */
-
 static const struct pci_error_handlers i40e_err_handler = {
 	.error_detected = i40e_pci_error_detected,
 	.slot_reset = i40e_pci_error_slot_reset,
@@ -13377,11 +13372,9 @@ static struct pci_driver i40e_driver = {
 	.id_table = i40e_pci_tbl,
 	.probe    = i40e_probe,
 	.remove   = i40e_remove,
-#ifdef CONFIG_PM
 	.driver   = {
 		.pm = &i40e_pm_ops,
 	},
-#endif /* CONFIG_PM */
 	.shutdown = i40e_shutdown,
 	.err_handler = &i40e_err_handler,
 	.sriov_configure = i40e_pci_sriov_configure,
-- 
2.14.2
