From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 16/21] ixgbe: remove timer reset to 0 on timeout
Date: Sat, 12 Mar 2011 04:20:23 -0800
Message-ID: <1299932428-3114-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58767 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983Ab1CLMU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:59 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The VF mailbox polling for acks and messages would reset the timer to zero
on a timeout. Under heavy load a timeout may actually occur without being
the result of an error and when this occurs it is not practical to perform
a full VF driver reset on every message timeout. Instead, just return an
error (which is already done) and the VF driver will have an opportunity
to retry the operation.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_mbx.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index c7ed82e..1ff0eef 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -154,9 +154,6 @@ static s32 ixgbe_poll_for_msg(struct ixgbe_hw *hw, u16 mbx_id)
 		udelay(mbx->usec_delay);
 	}
 
-	/* if we failed, all future posted messages fail until reset */
-	if (!countdown)
-		mbx->timeout = 0;
 out:
 	return countdown ? 0 : IXGBE_ERR_MBX;
 }
@@ -183,9 +180,6 @@ static s32 ixgbe_poll_for_ack(struct ixgbe_hw *hw, u16 mbx_id)
 		udelay(mbx->usec_delay);
 	}
 
-	/* if we failed, all future posted messages fail until reset */
-	if (!countdown)
-		mbx->timeout = 0;
 out:
 	return countdown ? 0 : IXGBE_ERR_MBX;
 }
-- 
1.7.4

