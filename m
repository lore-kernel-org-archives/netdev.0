From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: relax the firmware API version check
Date: Thu, 29 May 2014 08:10:16 -0700
Message-ID: <1401376216-12531-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14215 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933219AbaE2PKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:41 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

As long as the Firmware isn't reporting a higher API major version number
than what the driver knows about, the driver does not need to worry as
much about greater minor numbers.  The API changes minor numbers when
things get added to the API, but no existing structs or calls are changed.
The driver has the option of warning that the minor numbers don't match.

This will allow a little more flexibility in handling newer NICs and NVMs
in the field.

Change-ID: I5302acd2d147a2992328991ee7223b2ff39c8741
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index 34415d3..ba2811b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -587,8 +587,7 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw)
 	i40e_read_nvm_word(hw, I40E_SR_NVM_EETRACK_HI, &eetrack_hi);
 	hw->nvm.eetrack = (eetrack_hi << 16) | eetrack_lo;
 
-	if (hw->aq.api_maj_ver != I40E_FW_API_VERSION_MAJOR ||
-	    hw->aq.api_min_ver > I40E_FW_API_VERSION_MINOR) {
+	if (hw->aq.api_maj_ver > I40E_FW_API_VERSION_MAJOR) {
 		ret_code = I40E_ERR_FIRMWARE_API_VERSION;
 		goto init_adminq_free_arq;
 	}
-- 
1.9.3
