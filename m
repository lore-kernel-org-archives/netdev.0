From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] i40e: Increase the amount of time we wait for reset to be done
Date: Wed,  7 Oct 2015 15:46:55 -0700
Message-ID: <1444258032-41476-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752AbbJGWrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:22 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>

In some rare cases the reset can take longer to complete so increase the
amount of time we wait.

Change-ID: Ib5628ec54b526a811ee33d1214fe763226406671
Signed-off-by: Paul M Stillwell Jr <paul.m.stillwell.jr@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 6833717..1e81f4e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1256,7 +1256,7 @@ i40e_status i40e_pf_reset(struct i40e_hw *hw)
 	grst_del = (rd32(hw, I40E_GLGEN_RSTCTL) &
 		    I40E_GLGEN_RSTCTL_GRSTDEL_MASK) >>
 		    I40E_GLGEN_RSTCTL_GRSTDEL_SHIFT;
-	for (cnt = 0; cnt < grst_del + 2; cnt++) {
+	for (cnt = 0; cnt < grst_del + 10; cnt++) {
 		reg = rd32(hw, I40E_GLGEN_RSTAT);
 		if (!(reg & I40E_GLGEN_RSTAT_DEVSTATE_MASK))
 			break;
-- 
2.4.3
