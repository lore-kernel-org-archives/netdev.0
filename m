From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 7/8] ixgbe: Release semaphore bits in the right order
Date: Mon,  4 May 2015 02:40:26 -0700
Message-ID: <1430732427-29984-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1430732427-29984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53718 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752090AbbEDJkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 05:40:52 -0400
In-Reply-To: <1430732427-29984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

The global semaphore bits should be released in the reverse of the
order that they were taken, so correct that.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index f5f948d..0a8b5e4 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -696,14 +696,14 @@ static void ixgbe_release_swfw_sync_semaphore(struct ixgbe_hw *hw)
 
 	/* Release both semaphores by writing 0 to the bits REGSMP and SMBI */
 
-	swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
-	swsm &= ~IXGBE_SWSM_SMBI;
-	IXGBE_WRITE_REG(hw, IXGBE_SWSM, swsm);
-
 	swsm = IXGBE_READ_REG(hw, IXGBE_SWFW_SYNC);
 	swsm &= ~IXGBE_SWFW_REGSMP;
 	IXGBE_WRITE_REG(hw, IXGBE_SWFW_SYNC, swsm);
 
+	swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+	swsm &= ~IXGBE_SWSM_SMBI;
+	IXGBE_WRITE_REG(hw, IXGBE_SWSM, swsm);
+
 	IXGBE_WRITE_FLUSH(hw);
 }
 
-- 
2.1.0
