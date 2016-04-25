From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: use msleep for long delays
Date: Mon, 25 Apr 2016 05:44:29 -0700
Message-ID: <1461588269-128728-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:36355 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631AbcDYMoe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 08:44:34 -0400
In-Reply-To: <1461588269-128728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>

The newly added x550em_a support causes a link failure on ARM because of
an overly long time passed into udelay():

ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko] undefined!

There are multiple variants of the ixgbe_acquire_swfw_sync_*() function,
and the other ones all use msleep(), so we can safely assume that all
callers are allowed to sleep, which makes msleep() a better replacement
than mdelay().

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC type")
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
index c8a4f5e..19b75cd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c
@@ -2765,7 +2765,7 @@ static s32 ixgbe_acquire_swfw_sync_x550em_a(struct ixgbe_hw *hw, u32 mask)
 			ixgbe_release_swfw_sync_X540(hw, hmask);
 		if (status != IXGBE_ERR_TOKEN_RETRY)
 			return status;
-		udelay(FW_PHY_TOKEN_DELAY * 1000);
+		msleep(FW_PHY_TOKEN_DELAY);
 	}
 
 	return status;
-- 
2.5.5
