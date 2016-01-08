From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] ixgbe: fix broken PFC with X550
Date: Fri,  8 Jan 2016 05:00:25 -0800
Message-ID: <1452258030-63996-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26376 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041AbcAHNAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:33 -0500
In-Reply-To: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

PFC is configuration is skipped for X550 devices due to a incorrect
device id check, fixing that to include X550 PFC configuration.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
index 23277ab..b5cc989 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.c
@@ -223,13 +223,13 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en, u8 *prio_tc)
 	reg |= IXGBE_MFLCN_DPF;
 
 	/*
-	 * X540 supports per TC Rx priority flow control.  So
-	 * clear all TCs and only enable those that should be
+	 * X540 & X550 supports per TC Rx priority flow control.
+	 * So clear all TCs and only enable those that should be
 	 * enabled.
 	 */
 	reg &= ~(IXGBE_MFLCN_RPFCE_MASK | IXGBE_MFLCN_RFCE);
 
-	if (hw->mac.type == ixgbe_mac_X540)
+	if (hw->mac.type >= ixgbe_mac_X540)
 		reg |= pfc_en << IXGBE_MFLCN_RPFCE_SHIFT;
 
 	if (pfc_en)
-- 
2.5.0
