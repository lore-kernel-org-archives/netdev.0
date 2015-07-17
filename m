From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] ixgbe: Don't report flow director filter's status
Date: Fri, 17 Jul 2015 07:25:22 -0700
Message-ID: <1437143123-5031-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Fan Du <fan.du@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19033 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757898AbbGQOZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 10:25:44 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@intel.com>

For two reasons I want to disable this:
1. Not any part actually check the report status(Alexander Duyck)
2. To report hash value of a packet to stack,
   RSS -> 32bits hash value
   Perfect match fdir filter -> 13bits hash value
   Hashed-based fdir filter -> 31bits hash value

   fdir filter might hash on masked tuples for IP address,
   so it's still not desirable for usage.

So for now, just stick to RSS 32bits hash value.

Signed-off-by: Fan Du <fan.du@intel.com>
Suggested-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 6b87d96..b1e364d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1394,14 +1394,12 @@ s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 fdirctrl)
 	/*
 	 * Continue setup of fdirctrl register bits:
 	 *  Turn perfect match filtering on
-	 *  Report hash in RSS field of Rx wb descriptor
 	 *  Initialize the drop queue
 	 *  Move the flexible bytes to use the ethertype - shift 6 words
 	 *  Set the maximum length per hash bucket to 0xA filters
 	 *  Send interrupt when 64 (0x4 * 16) filters are left
 	 */
 	fdirctrl |= IXGBE_FDIRCTRL_PERFECT_MATCH |
-		    IXGBE_FDIRCTRL_REPORT_STATUS |
 		    (IXGBE_FDIR_DROP_QUEUE << IXGBE_FDIRCTRL_DROP_Q_SHIFT) |
 		    (0x6 << IXGBE_FDIRCTRL_FLEX_SHIFT) |
 		    (0xA << IXGBE_FDIRCTRL_MAX_LENGTH_SHIFT) |
-- 
2.4.3
