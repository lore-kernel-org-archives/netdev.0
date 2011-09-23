From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/8] ixgbe: dcb, set priority to traffic class mappings
Date: Fri, 23 Sep 2011 09:12:44 -0700
Message-ID: <1316794367-23265-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35028 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab1IWQTA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 12:19:00 -0400
In-Reply-To: <1316794367-23265-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

This patch adds support for configuring the priority to
traffic class mapping.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index 22caad7..1d38955 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -572,6 +572,9 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
 	if (max_tc != netdev_get_num_tc(dev))
 		ixgbe_setup_tc(dev, max_tc);
 
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++)
+		netdev_set_prio_tc_map(dev, i, ets->prio_tc[i]);
+
 	return ixgbe_dcb_hw_ets(&adapter->hw, ets, max_frame);
 }
 
-- 
1.7.6.2
