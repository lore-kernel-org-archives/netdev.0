From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: group autoneg PHY types together
Date: Tue, 17 Oct 2017 11:21:12 -0700
Message-ID: <20171017182119.71989-9-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3560 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937342AbdJQSVn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:43 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This separates the setting of autoneg in i40e_phy_types_to_ethtool into
its own conditional.  Doing this adds clarity as what PHYs
support/advertise autoneg and makes it easier to add new PHY types in
the future.

This also fixes an issue on devices with CRT_RETIMER where advertising
autoneg was being set, but supported autoneg was not.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 85 +++++++++++++-------------
 1 file changed, 41 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 89ab398a7d30..30deae77e745 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -268,9 +268,7 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	*advertising = 0x0;
 
 	if (phy_types & I40E_CAP_PHY_TYPE_SGMII) {
-		*supported |= SUPPORTED_Autoneg |
-			      SUPPORTED_1000baseT_Full;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_1000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			*advertising |= ADVERTISED_1000baseT_Full;
 		if (pf->hw_features & I40E_HW_100M_SGMII_CAPABLE) {
@@ -289,9 +287,7 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_T ||
 	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SR ||
 	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_LR) {
-		*supported |= SUPPORTED_Autoneg |
-			      SUPPORTED_10000baseT_Full;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_10000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
 			*advertising |= ADVERTISED_10000baseT_Full;
 	}
@@ -301,16 +297,12 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 		*supported |= SUPPORTED_40000baseCR4_Full;
 	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4_CU ||
 	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4) {
-		*supported |= SUPPORTED_Autoneg |
-			      SUPPORTED_40000baseCR4_Full;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_40000baseCR4_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_40GB)
 			*advertising |= ADVERTISED_40000baseCR4_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) {
-		*supported |= SUPPORTED_Autoneg |
-			      SUPPORTED_100baseT_Full;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_100baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_100MB)
 			*advertising |= ADVERTISED_100baseT_Full;
 	}
@@ -318,9 +310,7 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_SX ||
 	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_LX ||
 	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL) {
-		*supported |= SUPPORTED_Autoneg |
-			      SUPPORTED_1000baseT_Full;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_1000baseT_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
 			*advertising |= ADVERTISED_1000baseT_Full;
 	}
@@ -329,47 +319,54 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_LR4)
 		*supported |= SUPPORTED_40000baseLR4_Full;
 	if (phy_types & I40E_CAP_PHY_TYPE_40GBASE_KR4) {
-		*supported |= SUPPORTED_40000baseKR4_Full |
-			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_40000baseKR4_Full |
-				ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_40000baseKR4_Full;
+		*advertising |= ADVERTISED_40000baseKR4_Full;
 	}
 	if (phy_types & I40E_CAP_PHY_TYPE_20GBASE_KR2) {
-		*supported |= SUPPORTED_20000baseKR2_Full |
-			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_20000baseKR2_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_20GB)
 			*advertising |= ADVERTISED_20000baseKR2_Full;
 	}
-	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR) {
-		if (!(pf->hw_features & I40E_HW_HAVE_CRT_RETIMER))
-			*supported |= SUPPORTED_10000baseKR_Full |
-				      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_Autoneg;
-		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
-			if (!(pf->hw_features & I40E_HW_HAVE_CRT_RETIMER))
-				*advertising |= ADVERTISED_10000baseKR_Full;
-	}
 	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KX4) {
-		*supported |= SUPPORTED_10000baseKX4_Full |
-			      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_Autoneg;
+		*supported |= SUPPORTED_10000baseKX4_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
 			*advertising |= ADVERTISED_10000baseKX4_Full;
 	}
-	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX) {
-		if (!(pf->hw_features & I40E_HW_HAVE_CRT_RETIMER))
-			*supported |= SUPPORTED_1000baseKX_Full |
-				      SUPPORTED_Autoneg;
-		*advertising |= ADVERTISED_Autoneg;
+	if (phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR &&
+	    !(pf->hw_features & I40E_HW_HAVE_CRT_RETIMER)) {
+		*supported |= SUPPORTED_10000baseKR_Full;
+		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_10GB)
+			*advertising |= ADVERTISED_10000baseKR_Full;
+	}
+	if (phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX &&
+	    !(pf->hw_features & I40E_HW_HAVE_CRT_RETIMER)) {
+		*supported |= SUPPORTED_1000baseKX_Full;
 		if (hw_link_info->requested_speeds & I40E_LINK_SPEED_1GB)
-			if (!(pf->hw_features & I40E_HW_HAVE_CRT_RETIMER))
-				*advertising |= ADVERTISED_1000baseKX_Full;
+			*advertising |= ADVERTISED_1000baseKX_Full;
 	}
-	if (phy_types & I40E_CAP_PHY_TYPE_25GBASE_KR ||
-	    phy_types & I40E_CAP_PHY_TYPE_25GBASE_CR ||
+	/* Autoneg PHY types */
+	if (phy_types & I40E_CAP_PHY_TYPE_SGMII ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_KR4 ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_40GBASE_CR4 ||
 	    phy_types & I40E_CAP_PHY_TYPE_25GBASE_SR ||
-	    phy_types & I40E_CAP_PHY_TYPE_25GBASE_LR) {
+	    phy_types & I40E_CAP_PHY_TYPE_25GBASE_LR ||
+	    phy_types & I40E_CAP_PHY_TYPE_25GBASE_KR ||
+	    phy_types & I40E_CAP_PHY_TYPE_25GBASE_CR ||
+	    phy_types & I40E_CAP_PHY_TYPE_20GBASE_KR2 ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_T ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_SR ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_LR ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_KX4 ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_KR ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1_CU ||
+	    phy_types & I40E_CAP_PHY_TYPE_10GBASE_CR1 ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T_OPTICAL ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_T ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_SX ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_LX ||
+	    phy_types & I40E_CAP_PHY_TYPE_1000BASE_KX ||
+	    phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) {
 		*supported |= SUPPORTED_Autoneg;
 		*advertising |= ADVERTISED_Autoneg;
 	}
-- 
2.14.2
