From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] i40e: Increase timeout when checking GLGEN_RSTAT_DEVSTATE bit
Date: Fri, 19 Feb 2016 01:54:01 -0800
Message-ID: <1455875651-21696-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kevin Scott <kevin.c.scott@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:35306 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1427411AbcBSJyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2016 04:54:21 -0500
In-Reply-To: <1455875651-21696-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Scott <kevin.c.scott@intel.com>

When linking with particular PHY types (ex: copper PHY), the amount of
time it takes for the GLGEN_RSTAT_DEVSTATE to be set increases greatly,
which can lead to a timeout and failure to load the driver.

Change-ID: If02be0dfcd7c57fdde2d5c81cd63651260cd2029
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index d417193..3a57e59 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1239,7 +1239,13 @@ i40e_status i40e_pf_reset(struct i40e_hw *hw)
 	grst_del = (rd32(hw, I40E_GLGEN_RSTCTL) &
 		    I40E_GLGEN_RSTCTL_GRSTDEL_MASK) >>
 		    I40E_GLGEN_RSTCTL_GRSTDEL_SHIFT;
-	for (cnt = 0; cnt < grst_del + 10; cnt++) {
+
+	/* It can take upto 15 secs for GRST steady state.
+	 * Bump it to 16 secs max to be safe.
+	 */
+	grst_del = grst_del * 20;
+
+	for (cnt = 0; cnt < grst_del; cnt++) {
 		reg = rd32(hw, I40E_GLGEN_RSTAT);
 		if (!(reg & I40E_GLGEN_RSTAT_DEVSTATE_MASK))
 			break;
-- 
2.5.0
