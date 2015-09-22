From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] ixgbe: Add SFP+ detection for X550 hardware
Date: Tue, 22 Sep 2015 16:54:21 -0700
Message-ID: <1442966076-14359-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8434 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934682AbbIVXyi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:38 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch is part of the future enablement of X550 SFP+ support.  This
HW uses different SDP so the interrupts need to be set up accordingly.

Signed-off-by: Donald C Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index acb1b91..5f04ad4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4904,9 +4904,15 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		gpie |= IXGBE_SDP1_GPIEN(hw);
 
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		gpie |= IXGBE_SDP1_GPIEN_8259X;
-		gpie |= IXGBE_SDP2_GPIEN_8259X;
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+		gpie |= IXGBE_SDP1_GPIEN_8259X | IXGBE_SDP2_GPIEN_8259X;
+		break;
+	case ixgbe_mac_X550EM_x:
+		gpie |= IXGBE_SDP0_GPIEN_X540;
+		break;
+	default:
+		break;
 	}
 
 	IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
-- 
2.4.3
