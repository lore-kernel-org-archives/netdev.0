From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] i40e: remove read/write failed messages from nvmupdate
Date: Thu, 15 Oct 2015 14:43:14 -0700
Message-ID: <1444945404-30654-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:32107 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753002AbbJOVna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 17:43:30 -0400
In-Reply-To: <1444945404-30654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Allow the nvmupdate application to decide when a read or write error
should be exposed to the user.  Since the application needs to use
write probes to find the ReadOnly sections on a potentially unknown NVM
version in the HW and read probes to check the status of the last write,
some error messages are expected, but need not be shown to the users.
The driver doesn't know which are ignorable from real errors, so needs
to let the application make the decision.

Change-ID: I78fca8ab672bede11c10c820b83c26adfd536d03
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 923f95e..d9c4f07 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -993,9 +993,7 @@ static int i40e_get_eeprom(struct net_device *netdev,
 
 		cmd = (struct i40e_nvm_access *)eeprom;
 		ret_val = i40e_nvmupd_command(hw, cmd, bytes, &errno);
-		if (ret_val &&
-		    ((hw->aq.asq_last_status != I40E_AQ_RC_EACCES) ||
-		     (hw->debug_mask & I40E_DEBUG_NVM)))
+		if (ret_val && (hw->debug_mask & I40E_DEBUG_NVM))
 			dev_info(&pf->pdev->dev,
 				 "NVMUpdate read failed err=%d status=0x%x errno=%d module=%d offset=0x%x size=%d\n",
 				 ret_val, hw->aq.asq_last_status, errno,
@@ -1099,10 +1097,7 @@ static int i40e_set_eeprom(struct net_device *netdev,
 
 	cmd = (struct i40e_nvm_access *)eeprom;
 	ret_val = i40e_nvmupd_command(hw, cmd, bytes, &errno);
-	if (ret_val &&
-	    ((hw->aq.asq_last_status != I40E_AQ_RC_EPERM &&
-	      hw->aq.asq_last_status != I40E_AQ_RC_EBUSY) ||
-	     (hw->debug_mask & I40E_DEBUG_NVM)))
+	if (ret_val && (hw->debug_mask & I40E_DEBUG_NVM))
 		dev_info(&pf->pdev->dev,
 			 "NVMUpdate write failed err=%d status=0x%x errno=%d module=%d offset=0x%x size=%d\n",
 			 ret_val, hw->aq.asq_last_status, errno,
-- 
2.4.3
