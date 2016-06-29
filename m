From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] i40e: Removing unnecessary code which caused supported link mode bug
Date: Tue, 28 Jun 2016 21:40:55 -0700
Message-ID: <1467175262-54719-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Avinash Dayanand <avinash.dayanand@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751290AbcF2EnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:18 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Avinash Dayanand <avinash.dayanand@intel.com>

Removing this code which wasn't allowing 100BaseT to show up in the supported
link modes for 10GBaseT PHYs.

Change-ID: Iada2eafa7ef6b4bac9a2a1380ff533ae5de51e1d
Signed-off-by: Avinash Dayanand <avinash.dayanand@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 8381dab..4962e85 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -313,8 +313,7 @@ static void i40e_phy_type_to_ethtool(struct i40e_pf *pf, u32 *supported,
 		*advertising |= ADVERTISED_Autoneg |
 				ADVERTISED_40000baseCR4_Full;
 	}
-	if ((phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) &&
-	    !(phy_types & I40E_CAP_PHY_TYPE_1000BASE_T)) {
+	if (phy_types & I40E_CAP_PHY_TYPE_100BASE_TX) {
 		*supported |= SUPPORTED_Autoneg |
 			      SUPPORTED_100baseT_Full;
 		*advertising |= ADVERTISED_Autoneg |
-- 
2.5.5
