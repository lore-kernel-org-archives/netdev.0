From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] ixgbe: fix setup_fc for x550em
Date: Fri, 22 Jul 2016 23:49:44 -0700
Message-ID: <1469256591-109822-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:6141 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751111AbcGWGuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 02:50:11 -0400
In-Reply-To: <1469256591-109822-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

mac->ops.setup_fc can be null for backplanes which can cause the driver
to crash on load.

Reported-by: Patrick McLean <patrickm@gaikai.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index 19b75cd..4716ca4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -1618,6 +1618,8 @@ static void ixgbe_init_mac_link_ops_X550em(struct ixgbe_hw *hw)
 {
 	struct ixgbe_mac_info *mac = &hw->mac;
 
+	mac->ops.setup_fc = ixgbe_setup_fc_x550em;
+
 	switch (mac->ops.get_media_type(hw)) {
 	case ixgbe_media_type_fiber:
 		/* CS4227 does not support autoneg, so disable the laser control
@@ -1627,7 +1629,6 @@ static void ixgbe_init_mac_link_ops_X550em(struct ixgbe_hw *hw)
 		mac->ops.enable_tx_laser = NULL;
 		mac->ops.flap_tx_laser = NULL;
 		mac->ops.setup_link = ixgbe_setup_mac_link_multispeed_fiber;
-		mac->ops.setup_fc = ixgbe_setup_fc_x550em;
 		switch (hw->device_id) {
 		case IXGBE_DEV_ID_X550EM_A_SFP_N:
 			mac->ops.setup_mac_link = ixgbe_setup_mac_link_sfp_n;
@@ -1655,7 +1656,6 @@ static void ixgbe_init_mac_link_ops_X550em(struct ixgbe_hw *hw)
 			mac->ops.setup_link = ixgbe_setup_sgmii;
 		break;
 	default:
-		mac->ops.setup_fc = ixgbe_setup_fc_x550em;
 		break;
 	}
 }
-- 
2.5.5
