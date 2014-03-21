From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/16] ixgbe: Break recursion in case of removal
Date: Fri, 21 Mar 2014 05:09:55 -0700
Message-ID: <1395403806-29302-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20076 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965477AbaCUMKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:12 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

When an adapter is removed and registers all read as all one's,
an infinite recursion can happen between ixgbe_clear_vmdq_generic
and ixgbe_clear_rar_generic. Adding a check for removal breaks
this recursion.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 911b711..24fba39 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -2913,6 +2913,9 @@ s32 ixgbe_clear_vmdq_generic(struct ixgbe_hw *hw, u32 rar, u32 vmdq)
 	mpsar_lo = IXGBE_READ_REG(hw, IXGBE_MPSAR_LO(rar));
 	mpsar_hi = IXGBE_READ_REG(hw, IXGBE_MPSAR_HI(rar));
 
+	if (ixgbe_removed(hw->hw_addr))
+		goto done;
+
 	if (!mpsar_lo && !mpsar_hi)
 		goto done;
 
-- 
1.8.3.1
