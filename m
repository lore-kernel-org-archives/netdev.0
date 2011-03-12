From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 19/21] ixgbe: DCB, set minimum bandwidth per traffic class
Date: Sat, 12 Mar 2011 04:20:26 -0800
Message-ID: <1299932428-3114-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:2695 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753971Ab1CLMU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:57 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

DCB provides a guaranteed bandwidth in the case with 0%
bandwidth then no bandwidth is guaranteed. However the
traffic class should still be able to transmit traffic.
For this to work the traffic class must be given the
minimum credits required to send a frame.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb.c b/drivers/net/ixgbe/ixgbe_dcb.c
index e7b551a..41c529f 100644
--- a/drivers/net/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ixgbe/ixgbe_dcb.c
@@ -64,7 +64,7 @@ s32 ixgbe_ieee_credits(__u8 *bw, __u16 *refill, __u16 *max, int max_frame)
 			val = min_credit;
 		refill[i] = val;
 
-		max[i] = (bw[i] * MAX_CREDIT)/100;
+		max[i] = bw[i] ? (bw[i] * MAX_CREDIT)/100 : min_credit;
 	}
 	return 0;
 }
-- 
1.7.4

