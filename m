From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  05/15] igb: Update MTU so that it is always at least a standard frame size
Date: Wed, 21 Aug 2013 01:23:26 -0700
Message-ID: <1377073416-7872-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2670 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab3HUIXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 04:23:46 -0400
In-Reply-To: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we limit the lower bound for max_frame_size to
the size of a standard Ethernet frame.  This allows for feature parity with
other Intel based drivers such as ixgbe.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 94295a0..1a0137d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4813,6 +4813,10 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 		return -EINVAL;
 	}
 
+	/* adjust max frame to be at least the size of a standard frame */
+	if (max_frame < (ETH_FRAME_LEN + ETH_FCS_LEN))
+		max_frame = ETH_FRAME_LEN + ETH_FCS_LEN;
+
 	while (test_and_set_bit(__IGB_RESETTING, &adapter->state))
 		msleep(1);
 
-- 
1.8.3.1
