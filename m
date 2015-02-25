From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40evf: allow enabling of debug prints via ethtool
Date: Wed, 25 Feb 2015 00:58:29 -0800
Message-ID: <1424854720-18825-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ashish Shah <ashish.n.shah@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20292 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752368AbbBYI6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:46 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Shah <ashish.n.shah@intel.com>

Copy setting from ethtool to the HW specific struct to actually
enable prints.  Change print from i40e to i40evf to differentiate
drivers in bare metal scenarios.

Also update the copyright year.

Change-ID: I06fee26247299a08f2e1c70fc811a9ea0931c4dd
Signed-off-by: Ashish Shah <ashish.n.shah@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 69b97ba..c5ffacc 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
  *
  * Intel Ethernet Controller XL710 Family Linux Virtual Function Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -180,7 +180,7 @@ static u32 i40evf_get_msglevel(struct net_device *netdev)
 }
 
 /**
- * i40evf_get_msglevel - Set debug message level
+ * i40evf_set_msglevel - Set debug message level
  * @netdev: network interface device structure
  * @data: message level
  *
@@ -191,6 +191,8 @@ static void i40evf_set_msglevel(struct net_device *netdev, u32 data)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
+	if (I40E_DEBUG_USER & data)
+		adapter->hw.debug_mask = data;
 	adapter->msg_enable = data;
 }
 
-- 
1.9.3
