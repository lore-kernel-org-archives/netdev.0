From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/8] ixgbe: Fix case of Tx Hang in PF with 32 VFs
Date: Wed,  8 Feb 2012 01:36:34 -0800
Message-ID: <1328693798-27323-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:21470 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751314Ab2BHJgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 04:36:46 -0500
In-Reply-To: <1328693798-27323-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

A check for the number of VFs allocated should have used a greater than
equal operator instead of just greater than.  This caused allocation of
exactly 32 VFs to not enable the PF transmit and receive enables.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Robert E Garrett <robertX.e.garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 92192c6..819b5c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2830,7 +2830,7 @@ static void ixgbe_configure_virtualization(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl | vt_reg_bits);
 
 	vf_shift = adapter->num_vfs % 32;
-	reg_offset = (adapter->num_vfs > 32) ? 1 : 0;
+	reg_offset = (adapter->num_vfs >= 32) ? 1 : 0;
 
 	/* Enable only the PF's pool for Tx/Rx */
 	IXGBE_WRITE_REG(hw, IXGBE_VFRE(reg_offset), (1 << vf_shift));
-- 
1.7.7.6
