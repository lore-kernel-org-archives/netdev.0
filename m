From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] ixgbe: Convert some udelays to usleep_range
Date: Fri, 25 Jul 2014 21:45:11 -0700
Message-ID: <1406349922-9883-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:5410 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750803AbaGZEpZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:25 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Convert some udelay calls to the preferred usleep_range.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c   | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 3f318c5..db759f9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -1386,7 +1386,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 			status = 0;
 			break;
 		}
-		udelay(50);
+		usleep_range(50, 100);
 	}
 
 	if (i == timeout) {
@@ -1399,7 +1399,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 		 */
 		ixgbe_release_eeprom_semaphore(hw);
 
-		udelay(50);
+		usleep_range(50, 100);
 		/*
 		 * one last try
 		 * If the SMBI bit is 0 when we read it, then the bit will be
@@ -1427,7 +1427,7 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 			if (swsm & IXGBE_SWSM_SWESMBI)
 				break;
 
-			udelay(50);
+			usleep_range(50, 100);
 		}
 
 		/*
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
index 40dd798..942ad13 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x540.c
@@ -699,7 +699,7 @@ static s32 ixgbe_get_swfw_sync_semaphore(struct ixgbe_hw *hw)
 			status = 0;
 			break;
 		}
-		udelay(50);
+		usleep_range(50, 100);
 	}
 
 	/* Now get the semaphore between SW/FW through the REGSMP bit */
@@ -709,7 +709,7 @@ static s32 ixgbe_get_swfw_sync_semaphore(struct ixgbe_hw *hw)
 			if (!(swsm & IXGBE_SWFW_REGSMP))
 				break;
 
-			udelay(50);
+			usleep_range(50, 100);
 		}
 	} else {
 		hw_dbg(hw, "Software semaphore SMBI between device drivers not granted.\n");
-- 
1.9.3
