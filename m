From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] i40e: move nway reset
Date: Wed,  2 Jul 2014 19:40:29 -0700
Message-ID: <1404355233-30123-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40797 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754960AbaGCClU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:20 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Just move nway reset up, will be used in the next patch.

Change-ID: Ice3b631fa2044debc5c4541b42872a48163f8452
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 38 +++++++++++++-------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index b105e6f..6508a1b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -412,6 +412,25 @@ no_valid_phy_type:
 	return 0;
 }
 
+static int i40e_nway_reset(struct net_device *netdev)
+{
+	/* restart autonegotiation */
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	bool link_up = hw->phy.link_info.link_info & I40E_AQ_LINK_UP;
+	i40e_status ret = 0;
+
+	ret = i40e_aq_set_link_restart_an(hw, link_up, NULL);
+	if (ret) {
+		netdev_info(netdev, "link restart failed, aq_err=%d\n",
+			    pf->hw.aq.asq_last_status);
+		return -EIO;
+	}
+
+	return 0;
+}
+
 /**
  * i40e_get_pauseparam -  Get Flow Control status
  * Return tx/rx-pause status
@@ -1125,25 +1144,6 @@ static int i40e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	return 0;
 }
 
-static int i40e_nway_reset(struct net_device *netdev)
-{
-	/* restart autonegotiation */
-	struct i40e_netdev_priv *np = netdev_priv(netdev);
-	struct i40e_pf *pf = np->vsi->back;
-	struct i40e_hw *hw = &pf->hw;
-	bool link_up = hw->phy.link_info.link_info & I40E_AQ_LINK_UP;
-	i40e_status ret = 0;
-
-	ret = i40e_aq_set_link_restart_an(hw, link_up, NULL);
-	if (ret) {
-		netdev_info(netdev, "link restart failed, aq_err=%d\n",
-			    pf->hw.aq.asq_last_status);
-		return -EIO;
-	}
-
-	return 0;
-}
-
 static int i40e_set_phys_id(struct net_device *netdev,
 			    enum ethtool_phys_id_state state)
 {
-- 
1.9.3
