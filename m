From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40e: fix nvm version and remove firmware report
Date: Wed,  5 Mar 2014 20:21:42 -0800
Message-ID: <1394079704-1108-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49472 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752840AbaCFEV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 23:21:56 -0500
In-Reply-To: <1394079704-1108-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The driver needs to use the format that the current NVM
uses when printing the version of the NVM.  It should remain
this way from now on forward.

The driver was reporting when firmware was less than
an expected version number, but this is not a requirement
for the product and we print the firmware number at
init and in ethtool -i output.  Just remove the print.

Change-ID: Ide0b856cd454ebf867610ef9a0d639bb358a4a60
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 14 +++++++-------
 drivers/net/ethernet/intel/i40e/i40e_main.c |  7 -------
 2 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ba77fca..838b69b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -86,12 +86,12 @@
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
-#define I40E_NVM_VERSION_HI_SHIFT  8
-#define I40E_NVM_VERSION_HI_MASK   (0xff << I40E_NVM_VERSION_HI_SHIFT)
+#define I40E_NVM_VERSION_HI_SHIFT  12
+#define I40E_NVM_VERSION_HI_MASK   (0xf << I40E_NVM_VERSION_HI_SHIFT)
 
 /* The values in here are decimal coded as hex as is the case in the NVM map*/
 #define I40E_CURRENT_NVM_VERSION_HI 0x2
-#define I40E_CURRENT_NVM_VERSION_LO 0x30
+#define I40E_CURRENT_NVM_VERSION_LO 0x40
 
 /* magic for getting defines into strings */
 #define STRINGIFY(foo)  #foo
@@ -489,10 +489,10 @@ static inline char *i40e_fw_version_str(struct i40e_hw *hw)
 		 "f%d.%d a%d.%d n%02x.%02x e%08x",
 		 hw->aq.fw_maj_ver, hw->aq.fw_min_ver,
 		 hw->aq.api_maj_ver, hw->aq.api_min_ver,
-		 (hw->nvm.version & I40E_NVM_VERSION_HI_MASK)
-						>> I40E_NVM_VERSION_HI_SHIFT,
-		 (hw->nvm.version & I40E_NVM_VERSION_LO_MASK)
-						>> I40E_NVM_VERSION_LO_SHIFT,
+		 (hw->nvm.version & I40E_NVM_VERSION_HI_MASK) >>
+			I40E_NVM_VERSION_HI_SHIFT,
+		 (hw->nvm.version & I40E_NVM_VERSION_LO_MASK) >>
+			I40E_NVM_VERSION_LO_SHIFT,
 		 hw->nvm.eetrack);
 
 	return buf;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5bb0670..6365837 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7985,13 +7985,6 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = i40e_init_adminq(hw);
 	dev_info(&pdev->dev, "%s\n", i40e_fw_version_str(hw));
-	if (((hw->nvm.version & I40E_NVM_VERSION_HI_MASK)
-		 >> I40E_NVM_VERSION_HI_SHIFT) != I40E_CURRENT_NVM_VERSION_HI) {
-		dev_info(&pdev->dev,
-			 "warning: NVM version not supported, supported version: %02x.%02x\n",
-			 I40E_CURRENT_NVM_VERSION_HI,
-			 I40E_CURRENT_NVM_VERSION_LO);
-	}
 	if (err) {
 		dev_info(&pdev->dev,
 			 "init_adminq failed: %d expecting API %02x.%02x\n",
-- 
1.8.3.1
