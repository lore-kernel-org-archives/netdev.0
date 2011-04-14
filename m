From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 11/24] ixgbe: fix return value checks
Date: Wed, 13 Apr 2011 18:02:07 -0700
Message-ID: <1302742940-22141-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65381 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758119Ab1DNBCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 21:02:33 -0400
In-Reply-To: <1302742940-22141-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The value of status was incorrectly tested. Also whitespace cleanup.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_x540.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index d9323c0..7ce3f45 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -452,7 +452,7 @@ static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw)
 	IXGBE_WRITE_REG(hw, IXGBE_EEC, flup);
 
 	status = ixgbe_poll_flash_update_done_X540(hw);
-	if (status)
+	if (status == 0)
 		hw_dbg(hw, "Flash update complete\n");
 	else
 		hw_dbg(hw, "Flash update time out\n");
@@ -466,11 +466,10 @@ static s32 ixgbe_update_flash_X540(struct ixgbe_hw *hw)
 		}
 
 		status = ixgbe_poll_flash_update_done_X540(hw);
-		if (status)
+		if (status == 0)
 			hw_dbg(hw, "Flash update complete\n");
 		else
 			hw_dbg(hw, "Flash update time out\n");
-
 	}
 out:
 	return status;
-- 
1.7.4.2

