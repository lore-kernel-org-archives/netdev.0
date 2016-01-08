From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/8] ixgbe: use correct FCoE DDP max check
Date: Fri,  8 Jan 2016 05:00:24 -0800
Message-ID: <1452258030-63996-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55493 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863AbcAHNAd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:33 -0500
In-Reply-To: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Use fcoe_ddp_xid from netdev as this is correctly set for different
device IDs to avoid DDP skip error on X550 as "xid=0x20b out-of-range"

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 5f98870..5982937 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -77,7 +77,7 @@ int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid)
 	if (!netdev)
 		return 0;
 
-	if (xid >= IXGBE_FCOE_DDP_MAX)
+	if (xid >= netdev->fcoe_ddp_xid)
 		return 0;
 
 	adapter = netdev_priv(netdev);
@@ -177,7 +177,7 @@ static int ixgbe_fcoe_ddp_setup(struct net_device *netdev, u16 xid,
 		return 0;
 
 	adapter = netdev_priv(netdev);
-	if (xid >= IXGBE_FCOE_DDP_MAX) {
+	if (xid >= netdev->fcoe_ddp_xid) {
 		e_warn(drv, "xid=0x%x out-of-range\n", xid);
 		return 0;
 	}
-- 
2.5.0
