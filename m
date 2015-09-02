From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/19] ixgbe: use kzalloc for allocating one thing
Date: Tue,  1 Sep 2015 18:13:55 -0700
Message-ID: <1441156443-33381-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Maninder Singh <maninder1.s@samsung.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754587AbbIBBOM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 21:14:12 -0400
In-Reply-To: <1441156443-33381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maninder Singh <maninder1.s@samsung.com>

Use kzalloc rather than kcalloc(1..

The semantic patch that makes this change is as follows:

// <smpl>
@@
@@

- kcalloc(1,
+ kzalloc(
          ...)
// </smpl>

and removing checkpatch below CHECK:
CHECK: Prefer kzalloc(sizeof(*fwd_adapter)...) over
kzalloc(sizeof(struct ixgbe_fwd_adapter)...)

Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
Reviewed-by: Vaneet Narang <v.narang@samsung.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7e33125..7389c96 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8261,7 +8261,7 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 	    (adapter->num_rx_pools > IXGBE_MAX_MACVLANS))
 		return ERR_PTR(-EBUSY);
 
-	fwd_adapter = kcalloc(1, sizeof(struct ixgbe_fwd_adapter), GFP_KERNEL);
+	fwd_adapter = kzalloc(sizeof(*fwd_adapter), GFP_KERNEL);
 	if (!fwd_adapter)
 		return ERR_PTR(-ENOMEM);
 
-- 
2.4.3
