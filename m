From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: firmware version fields offsets update
Date: Fri,  6 Dec 2013 00:06:18 -0800
Message-ID: <1386317188-13944-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42213 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752656Ab3LFIGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:35 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai jain <anjali.singhai@intel.com>

The version bits reported by the hardware changed, so fix
up the offsets to print the version correctly.

Change-Id: I8a8207b401ea88f6da024aebafe7d3826ee6512c
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 17 +++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_main.c |  7 +++++++
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 1ca9834..b82f501 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -81,11 +81,14 @@
 #define I40E_DEFAULT_MSG_ENABLE       4
 
 #define I40E_NVM_VERSION_LO_SHIFT  0
-#define I40E_NVM_VERSION_LO_MASK   (0xf << I40E_NVM_VERSION_LO_SHIFT)
-#define I40E_NVM_VERSION_MID_SHIFT 4
-#define I40E_NVM_VERSION_MID_MASK  (0xff << I40E_NVM_VERSION_MID_SHIFT)
-#define I40E_NVM_VERSION_HI_SHIFT  12
-#define I40E_NVM_VERSION_HI_MASK   (0xf << I40E_NVM_VERSION_HI_SHIFT)
+#define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
+#define I40E_NVM_VERSION_HI_SHIFT  8
+#define I40E_NVM_VERSION_HI_MASK   (0xff << I40E_NVM_VERSION_HI_SHIFT)
+
+/* The values in here are decimal coded as hex as is the case in the NVM map*/
+#define I40E_CURRENT_NVM_VERSION_HI 0x2
+#define I40E_CURRENT_NVM_VERSION_LO 0x1
+
 
 /* magic for getting defines into strings */
 #define STRINGIFY(foo)  #foo
@@ -441,13 +444,11 @@ static inline char *i40e_fw_version_str(struct i40e_hw *hw)
 	static char buf[32];
 
 	snprintf(buf, sizeof(buf),
-		 "f%d.%d a%d.%d n%02d.%02d.%02d e%08x",
+		 "f%d.%d a%d.%d n%02x.%02x e%08x",
 		 hw->aq.fw_maj_ver, hw->aq.fw_min_ver,
 		 hw->aq.api_maj_ver, hw->aq.api_min_ver,
 		 (hw->nvm.version & I40E_NVM_VERSION_HI_MASK)
 						>> I40E_NVM_VERSION_HI_SHIFT,
-		 (hw->nvm.version & I40E_NVM_VERSION_MID_MASK)
-						>> I40E_NVM_VERSION_MID_SHIFT,
 		 (hw->nvm.version & I40E_NVM_VERSION_LO_MASK)
 						>> I40E_NVM_VERSION_LO_SHIFT,
 		 hw->nvm.eetrack);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index be15938..6e0f2cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7141,6 +7141,13 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = i40e_init_adminq(hw);
 	dev_info(&pdev->dev, "%s\n", i40e_fw_version_str(hw));
+	if (((hw->nvm.version & I40E_NVM_VERSION_HI_MASK)
+		 >> I40E_NVM_VERSION_HI_SHIFT) != I40E_CURRENT_NVM_VERSION_HI) {
+		dev_info(&pdev->dev,
+			 "warning: NVM version not supported, supported version: %02x.%02x\n",
+			 I40E_CURRENT_NVM_VERSION_HI,
+			 I40E_CURRENT_NVM_VERSION_LO);
+	}
 	if (err) {
 		dev_info(&pdev->dev,
 			 "init_adminq failed: %d expecting API %02x.%02x\n",
-- 
1.8.3.1
