From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/14] ixgbe: fix missing function pointer conversion
Date: Mon,  7 Mar 2011 18:24:57 -0800
Message-ID: <1299551108-23663-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:37667 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779Ab1CHC0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:06 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

In the previous commit:
  commit 5e655105e3e19d746f9e95c514b014c11c3d1b6a
  Author: Don Skidmore <donald.c.skidmore@intel.com>
  Date:   Fri Feb 25 01:58:04 2011 +0000

  ixgbe: add function pointer for semaphore function

there was one release of the semaphore function call which
did not get converted to a function pointer.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index a7fb2e0..94a5621 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1075,7 +1075,7 @@ static void ixgbe_release_eeprom(struct ixgbe_hw *hw)
 	eec &= ~IXGBE_EEC_REQ;
 	IXGBE_WRITE_REG(hw, IXGBE_EEC, eec);
 
-	ixgbe_release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
+	hw->mac.ops.release_swfw_sync(hw, IXGBE_GSSR_EEP_SM);
 
 	/* Delay before attempt to obtain semaphore again to allow FW access */
 	msleep(hw->eeprom.semaphore_delay);
-- 
1.7.4

