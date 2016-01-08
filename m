From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/8] ixgbe: Fix to get FDMI HBA attributes information with X550
Date: Fri,  8 Jan 2016 05:00:28 -0800
Message-ID: <1452258030-63996-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Usha Ketineni <usha.k.ketineni@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55493 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbcAHNAe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 08:00:34 -0500
In-Reply-To: <1452258030-63996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Usha Ketineni <usha.k.ketineni@intel.com>

Check whether the FCOE support is enabled for the devices to get the
 FDMI HBA attributes information instead of checking each device id.
Also, add Model string information for X550.

Signed-off-by: Usha Ketineni <usha.k.ketineni@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 5982937..df1647f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -996,8 +996,7 @@ int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
 		return -EINVAL;
 
 	/* Don't return information on unsupported devices */
-	if (hw->mac.type != ixgbe_mac_82599EB &&
-	    hw->mac.type != ixgbe_mac_X540)
+	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
 		return -EINVAL;
 
 	/* Manufacturer */
@@ -1043,6 +1042,10 @@ int ixgbe_fcoe_get_hbainfo(struct net_device *netdev,
 		snprintf(info->model,
 			 sizeof(info->model),
 			 "Intel 82599");
+	} else if (hw->mac.type == ixgbe_mac_X550) {
+		snprintf(info->model,
+			 sizeof(info->model),
+			 "Intel X550");
 	} else {
 		snprintf(info->model,
 			 sizeof(info->model),
-- 
2.5.0
