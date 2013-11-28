From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 7/8] ixgbe: turn NETIF_F_HW_L2FW_DOFFLOAD off by default
Date: Wed, 27 Nov 2013 23:36:01 -0800
Message-ID: <1385624162-10116-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4773 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754070Ab3K1Hge (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Nov 2013 02:36:34 -0500
In-Reply-To: <1385624162-10116-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

NETIF_F_HW_L2FW_DOFFLOAD allows upper layer net devices such
as macvlan to use queues in the hardware to directly submit and
receive skbs.

This creates a subtle change in the datapath though. One change
being the skb may no longer use the root devices qdisc.

Because users may not expect this we can't enable the feature
by default unless the hardware can offload all the software
functionality above it. So for now disable it by default and
let users opt in.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ad9d670..cc06854 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7986,10 +7986,9 @@ skip_sriov:
 			   NETIF_F_TSO |
 			   NETIF_F_TSO6 |
 			   NETIF_F_RXHASH |
-			   NETIF_F_RXCSUM |
-			   NETIF_F_HW_L2FW_DOFFLOAD;
+			   NETIF_F_RXCSUM;
 
-	netdev->hw_features = netdev->features;
+	netdev->hw_features = netdev->features | NETIF_F_HW_L2FW_DOFFLOAD;
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82599EB:
-- 
1.8.3.1
