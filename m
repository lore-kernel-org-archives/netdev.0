From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] ixgbe: Use correct FC setup function for x550em_a
Date: Mon, 25 Apr 2016 05:44:22 -0700
Message-ID: <1461588269-128728-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:40700 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754637AbcDYMof (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:35 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Somehow the wrong fc_setup function was used for x550em_a, so
correct that. Also set setup_link to NULL as its value is
determined later, just like it is with X550EM_x.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index ea25f00..a17e398 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2926,13 +2926,13 @@ static struct ixgbe_mac_operations mac_ops_x550em_a = {
 	.get_media_type		= ixgbe_get_media_type_X550em,
 	.get_san_mac_addr	= NULL,
 	.get_wwn_prefix		= NULL,
-	.setup_link		= &ixgbe_setup_mac_link_X540,
+	.setup_link		= NULL, /* defined later */
 	.get_link_capabilities	= ixgbe_get_link_capabilities_X550em,
 	.get_bus_info		= ixgbe_get_bus_info_X550em,
 	.setup_sfp		= ixgbe_setup_sfp_modules_X550em,
 	.acquire_swfw_sync	= ixgbe_acquire_swfw_sync_x550em_a,
 	.release_swfw_sync	= ixgbe_release_swfw_sync_x550em_a,
-	.setup_fc		= ixgbe_setup_fc_generic,
+	.setup_fc		= ixgbe_setup_fc_x550em,
 	.read_iosf_sb_reg	= ixgbe_read_iosf_sb_reg_x550a,
 	.write_iosf_sb_reg	= ixgbe_write_iosf_sb_reg_x550a,
 };
-- 
2.5.5
