From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: rename 'change' variable to 'autoneg_changed'
Date: Tue, 17 Oct 2017 11:21:17 -0700
Message-ID: <20171017182119.71989-14-jeffrey.t.kirsher@intel.com>
References: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:39766 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937368AbdJQSVo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Oct 2017 14:21:44 -0400
In-Reply-To: <20171017182119.71989-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

This variable isn't actually very descriptive and makes the code a bit
confusing as to what it is being used for.  This patch enhances the
variable with the longer name, 'autoneg_changed', which makes it clear
we are concerned with autoneg changing in this context.

Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 913ba91fac6c..9c70555bf49c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -822,14 +822,14 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_aq_get_phy_abilities_resp abilities;
+	struct ethtool_link_ksettings safe_ks;
+	struct ethtool_link_ksettings copy_ks;
 	struct i40e_aq_set_phy_config config;
 	struct i40e_pf *pf = np->vsi->back;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_hw *hw = &pf->hw;
-	struct ethtool_link_ksettings safe_ks;
-	struct ethtool_link_ksettings copy_ks;
+	bool autoneg_changed = false;
 	i40e_status status = 0;
-	bool change = false;
 	int timeout = 50;
 	int err = 0;
 	u32 autoneg;
@@ -922,7 +922,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 			/* Autoneg is allowed to change */
 			config.abilities = abilities.abilities |
 					   I40E_AQ_PHY_ENABLE_AN;
-			change = true;
+			autoneg_changed = true;
 		}
 	} else {
 		/* If autoneg is currently enabled */
@@ -942,7 +942,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 			/* Autoneg is allowed to change */
 			config.abilities = abilities.abilities &
 					   ~I40E_AQ_PHY_ENABLE_AN;
-			change = true;
+			autoneg_changed = true;
 		}
 	}
 
@@ -976,7 +976,7 @@ static int i40e_set_link_ksettings(struct net_device *netdev,
 	 */
 	if (!config.link_speed)
 		config.link_speed = abilities.link_speed;
-	if (change || (abilities.link_speed != config.link_speed)) {
+	if (autoneg_changed || abilities.link_speed != config.link_speed) {
 		/* copy over the rest of the abilities */
 		config.phy_type = abilities.phy_type;
 		config.phy_type_ext = abilities.phy_type_ext;
-- 
2.14.2
