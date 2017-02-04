From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 07/14] i40e: Deprecating unused macro
Date: Fri,  3 Feb 2017 18:56:38 -0800
Message-ID: <20170204025645.174793-8-jeffrey.t.kirsher@intel.com>
References: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Cc: Bimmy Pujari <bimmy.pujari@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24543 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753521AbdBDC4t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 21:56:49 -0500
In-Reply-To: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bimmy Pujari <bimmy.pujari@intel.com>

I40E_MAC_X710 was supposed to be for 10G and I40E_MAC_XL710
was supposed to be for 40G. But function i40e_is_mac_710
sets I40E_MAC_XL710 for all device IDS, I40E_MAC_X710 is not
used at all. As there is nothing to compare there is no need
for this function. Thus deprecating this extra macro and
removing this function entirely and replacing it with a direct
check.

Change-ID: I7d1769954dccd574a290ac04adb836ebd156730e
Signed-off-by: Bimmy Pujari <bimmy.pujari@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h        | 13 -------------
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  6 +++---
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  1 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  1 -
 4 files changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8bb0f4b..cdf812c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -134,19 +134,6 @@
 /* default to trying for four seconds */
 #define I40E_TRY_LINK_TIMEOUT	(4 * HZ)
 
-/**
- * i40e_is_mac_710 - Return true if MAC is X710/XL710
- * @hw: ptr to the hardware info
- **/
-static inline bool i40e_is_mac_710(struct i40e_hw *hw)
-{
-	if ((hw->mac.type == I40E_MAC_X710) ||
-	    (hw->mac.type == I40E_MAC_XL710))
-		return true;
-
-	return false;
-}
-
 /* driver state flags */
 enum i40e_state_t {
 	__I40E_TESTING,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2d689e0..2481924 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8684,7 +8684,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 				 pf->hw.func_caps.fd_filters_best_effort;
 	}
 
-	if (i40e_is_mac_710(&pf->hw) &&
+	if ((pf->hw.mac.type == I40E_MAC_XL710) &&
 	    (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 33)) ||
 	    (pf->hw.aq.fw_maj_ver < 4))) {
 		pf->flags |= I40E_FLAG_RESTART_AUTONEG;
@@ -8693,13 +8693,13 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	}
 
 	/* Disable FW LLDP if FW < v4.3 */
-	if (i40e_is_mac_710(&pf->hw) &&
+	if ((pf->hw.mac.type == I40E_MAC_XL710) &&
 	    (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver < 3)) ||
 	    (pf->hw.aq.fw_maj_ver < 4)))
 		pf->flags |= I40E_FLAG_STOP_FW_LLDP;
 
 	/* Use the FW Set LLDP MIB API if FW > v4.40 */
-	if (i40e_is_mac_710(&pf->hw) &&
+	if ((pf->hw.mac.type == I40E_MAC_XL710) &&
 	    (((pf->hw.aq.fw_maj_ver == 4) && (pf->hw.aq.fw_min_ver >= 40)) ||
 	    (pf->hw.aq.fw_maj_ver >= 5)))
 		pf->flags |= I40E_FLAG_USE_SET_LLDP_MIB;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index edc0abd..b6cf8d2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -125,7 +125,6 @@ enum i40e_debug_mask {
  */
 enum i40e_mac_type {
 	I40E_MAC_UNKNOWN = 0,
-	I40E_MAC_X710,
 	I40E_MAC_XL710,
 	I40E_MAC_VF,
 	I40E_MAC_X722,
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index c85e8a3..92ac60d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -100,7 +100,6 @@ enum i40e_debug_mask {
  */
 enum i40e_mac_type {
 	I40E_MAC_UNKNOWN = 0,
-	I40E_MAC_X710,
 	I40E_MAC_XL710,
 	I40E_MAC_VF,
 	I40E_MAC_X722,
-- 
2.10.2
