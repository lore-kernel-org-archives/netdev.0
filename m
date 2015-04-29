From: Fan Du <fan.du@intel.com>
Subject: [PATCH v2 3/3] ixgbe: Don't report flow director filter's status
Date: Wed, 29 Apr 2015 10:57:41 +0800
Message-ID: <1430276261-29821-4-git-send-email-fan.du@intel.com>
References: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Cc: alexander.h.duyck@redhat.com, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	Fan Du <fan.du@intel.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41037 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031479AbbD2DEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Apr 2015 23:04:14 -0400
In-Reply-To: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index e0c3639..de83b6f 100644
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
1.7.1
