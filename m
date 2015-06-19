From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] ixgbe: use kzalloc for allocating one thing
Date: Fri, 19 Jun 2015 09:37:55 +0530
Message-ID: <1434686875-13040-1-git-send-email-maninder1.s@samsung.com>
Cc: pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3bf2f3c..3f58757 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8134,7 +8134,7 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 	    (adapter->num_rx_pools > IXGBE_MAX_MACVLANS))
 		return ERR_PTR(-EBUSY);
 
-	fwd_adapter = kcalloc(1, sizeof(struct ixgbe_fwd_adapter), GFP_KERNEL);
+	fwd_adapter = kzalloc(sizeof(*fwd_adapter), GFP_KERNEL);
 	if (!fwd_adapter)
 		return ERR_PTR(-ENOMEM);
 
-- 
1.7.1
