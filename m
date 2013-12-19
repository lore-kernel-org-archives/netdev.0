From: Betty Dall <betty.dall@hp.com>
Subject: [PATCH] Check return from pci_find_ext_capability() in atl1c_reset_pcie()
Date: Thu, 19 Dec 2013 10:59:09 -0700
Message-ID: <1387475949-30452-1-git-send-email-betty.dall@hp.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Betty Dall <betty.dall@hp.com>
To: jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function atl1c_reset_pcie() does not check the return from
pci_find_ext_cabability() where it is getting the postion of the
PCI_EXT_CAP_ID_ERR. It is possible for the return to be 0.

Signed-off-by: Betty Dall <betty.dall@hp.com>
---

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)


diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index a36a760..2980175 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -145,9 +145,11 @@ static void atl1c_reset_pcie(struct atl1c_hw *hw, u32 flag)
 	 * Mask some pcie error bits
 	 */
 	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_ERR);
-	pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &data);
-	data &= ~(PCI_ERR_UNC_DLP | PCI_ERR_UNC_FCP);
-	pci_write_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, data);
+	if (pos) {
+		pci_read_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, &data);
+		data &= ~(PCI_ERR_UNC_DLP | PCI_ERR_UNC_FCP);
+		pci_write_config_dword(pdev, pos + PCI_ERR_UNCOR_SEVER, data);
+	}
 	/* clear error status */
 	pcie_capability_write_word(pdev, PCI_EXP_DEVSTA,
 			PCI_EXP_DEVSTA_NFED |
