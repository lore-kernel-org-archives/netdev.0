From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: Save more link abilities when using ethtool
Date: Sat, 11 Feb 2017 21:30:28 -0800
Message-ID: <20170212053028.98581-15-jeffrey.t.kirsher@intel.com>
References: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Cc: Henry Tieman <henry.w.tieman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:32945 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbdBLFab (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 00:30:31 -0500
In-Reply-To: <20170212053028.98581-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Tieman <henry.w.tieman@intel.com>

Ethtool support needs to save more PHY information. The
added information includes FEC capabilities and 25G link
types. Without this change it is possible to lose 25G or
FEC settings by using ethtool.

Change-ID: Ie42255b1e901ffbf9583b8c46466a54894114280
Signed-off-by: Henry Tieman <henry.w.tieman@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c4ab3c1..a22e262 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -803,9 +803,12 @@ static int i40e_set_settings(struct net_device *netdev,
 	if (change || (abilities.link_speed != config.link_speed)) {
 		/* copy over the rest of the abilities */
 		config.phy_type = abilities.phy_type;
+		config.phy_type_ext = abilities.phy_type_ext;
 		config.eee_capability = abilities.eee_capability;
 		config.eeer = abilities.eeer_val;
 		config.low_power_ctrl = abilities.d3_lpan;
+		config.fec_config = abilities.fec_cfg_curr_mod_ext_info &
+				    I40E_AQ_PHY_FEC_CONFIG_MASK;
 
 		/* save the requested speeds */
 		hw->phy.link_info.requested_speeds = config.link_speed;
-- 
2.10.2
