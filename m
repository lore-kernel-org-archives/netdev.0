From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e/i40evf: grab NVM devstarter version not image version
Date: Thu,  5 Mar 2015 08:46:22 -0800
Message-ID: <1425573992-30955-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8609 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757936AbbCEQqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 11:46:53 -0500
In-Reply-To: <1425573992-30955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

0x2A is the NVM version so it has useful data but it is per image
version every image can have a different one. 0x18 is the dev starter
version which all the images for release will have the same version.
Of the two 0x18 is more useful and is what should be displayed.

Change-ID: Idf493da13a42ab211e2de0bef287f5de51033cca
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 3 ++-
 drivers/net/ethernet/intel/i40e/i40e_type.h   | 2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h | 2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index dc2ed35..3e0d200 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -606,7 +606,8 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 		goto init_adminq_free_arq;
 
 	/* get the NVM version info */
-	i40e_read_nvm_word(hw, I40E_SR_NVM_IMAGE_VERSION, &hw->nvm.version);
+	i40e_read_nvm_word(hw, I40E_SR_NVM_DEV_STARTER_VERSION,
+			   &hw->nvm.version);
 	i40e_read_nvm_word(hw, I40E_SR_NVM_EETRACK_LO, &eetrack_lo);
 	i40e_read_nvm_word(hw, I40E_SR_NVM_EETRACK_HI, &eetrack_hi);
 	hw->nvm.eetrack = (eetrack_hi << 16) | eetrack_lo;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 9006939..83032d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -1143,7 +1143,7 @@ struct i40e_hw_port_stats {
 #define I40E_SR_EMP_MODULE_PTR			0x0F
 #define I40E_SR_PBA_FLAGS			0x15
 #define I40E_SR_PBA_BLOCK_PTR			0x16
-#define I40E_SR_NVM_IMAGE_VERSION		0x18
+#define I40E_SR_NVM_DEV_STARTER_VERSION		0x18
 #define I40E_SR_NVM_WAKE_ON_LAN			0x19
 #define I40E_SR_ALTERNATE_SAN_MAC_ADDRESS_PTR	0x27
 #define I40E_SR_NVM_EETRACK_LO			0x2D
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index a269386..eba6e4b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -1116,7 +1116,7 @@ struct i40e_hw_port_stats {
 /* Checksum and Shadow RAM pointers */
 #define I40E_SR_NVM_CONTROL_WORD		0x00
 #define I40E_SR_EMP_MODULE_PTR			0x0F
-#define I40E_SR_NVM_IMAGE_VERSION		0x18
+#define I40E_SR_NVM_DEV_STARTER_VERSION		0x18
 #define I40E_SR_NVM_WAKE_ON_LAN			0x19
 #define I40E_SR_ALTERNATE_SAN_MAC_ADDRESS_PTR	0x27
 #define I40E_SR_NVM_EETRACK_LO			0x2D
-- 
1.9.3
