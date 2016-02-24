From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/20] e1000e: Increase ULP timer
Date: Tue, 23 Feb 2016 20:26:05 -0800
Message-ID: <1456287984-10459-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12818 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757335AbcBXE02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 23:26:28 -0500
In-Reply-To: <1456287984-10459-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

Due to system level changes introduced in Skylake, ULP exit takes
significantly longer to occur.  Therefore, driver must wait longer for.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index a049e30..c731465 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1252,9 +1252,9 @@ static s32 e1000_disable_ulp_lpt_lp(struct e1000_hw *hw, bool force)
 			ew32(H2ME, mac_reg);
 		}
 
-		/* Poll up to 100msec for ME to clear ULP_CFG_DONE */
+		/* Poll up to 300msec for ME to clear ULP_CFG_DONE. */
 		while (er32(FWSM) & E1000_FWSM_ULP_CFG_DONE) {
-			if (i++ == 10) {
+			if (i++ == 30) {
 				ret_val = -E1000_ERR_PHY;
 				goto out;
 			}
-- 
2.5.0
