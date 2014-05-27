From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] ixgbe: fix linking at 100Mbps on copper devices with MNG FW enabled
Date: Tue, 27 May 2014 02:12:17 -0700
Message-ID: <1401181951-31358-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17019 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751854AbaE0JMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:35 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Driver was calling setup_link to make sure that fiber interfaces with MNG FW
enabled will get link on probe because the laser was most likely turned off.
This prevented non-fiber devices with MNG FW from linking at 100Mbps.

This patch adds a check to only call setup_link for fiber devices.

Reported-and-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Tony Luck <tony.luck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3d66602..cf9956a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8449,8 +8449,8 @@ skip_sriov:
 
 	ixgbe_dbg_adapter_init(adapter);
 
-	/* Need link setup for MNG FW, else wait for IXGBE_UP */
-	if (ixgbe_mng_enabled(hw) && hw->mac.ops.setup_link)
+	/* setup link for SFP devices with MNG FW, else wait for IXGBE_UP */
+	if (ixgbe_mng_enabled(hw) && ixgbe_is_sfp(hw) && hw->mac.ops.setup_link)
 		hw->mac.ops.setup_link(hw,
 			IXGBE_LINK_SPEED_10GB_FULL | IXGBE_LINK_SPEED_1GB_FULL,
 			true);
-- 
1.9.3
