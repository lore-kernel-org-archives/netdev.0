From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/17] i40e: allow FD SB if MFP mode only has 1 partition
Date: Thu, 15 Oct 2015 02:39:56 -0700
Message-ID: <1444902004-14433-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20496 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752375AbbJOJm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 05:42:27 -0400
In-Reply-To: <1444902004-14433-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Even though the device might be in MFP mode, if there's only one partition
enabled, then we still have plenty of interrupts for managing the Flow
Directory Sideband activity.  This patch enables FD SB in this case.
This patch also reverses the sense of the conditional in order to remove
the negative logic.

Change-ID: I9edf211a6219fc8d159b4be9964f9fd7f4e00bc0
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c4f26eb..0f8ab65 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7949,12 +7949,12 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	    (pf->hw.func_caps.fd_filters_best_effort > 0)) {
 		pf->flags |= I40E_FLAG_FD_ATR_ENABLED;
 		pf->atr_sample_rate = I40E_DEFAULT_ATR_SAMPLE_RATE;
-		if (!(pf->flags & I40E_FLAG_MFP_ENABLED)) {
-			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
-		} else {
+		if (pf->flags & I40E_FLAG_MFP_ENABLED &&
+		    pf->hw.num_partitions > 1)
 			dev_info(&pf->pdev->dev,
 				 "Flow Director Sideband mode Disabled in MFP mode\n");
-		}
+		else
+			pf->flags |= I40E_FLAG_FD_SB_ENABLED;
 		pf->fdir_pf_filter_count =
 				 pf->hw.func_caps.fd_filters_guaranteed;
 		pf->hw.fdir_shared_filter_count =
-- 
2.4.3
