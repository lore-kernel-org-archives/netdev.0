From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/18] ixgbe: Add const string for overheat message
Date: Tue,  9 Jun 2015 18:10:19 -0700
Message-ID: <1433898629-76729-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:56324 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933139AbbFJBKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 21:10:45 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The over heat message is displayed for multiple reasons but the text is
cut-n-pasted for each of these cases.  This patch pulls the text from the
same location.  I noticed this as I am about to add another case.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1b2bdbf..30adfb8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -81,6 +81,8 @@ const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2014 Intel Corporation.";
 
+static const char ixgbe_overheat_msg[] = "Network adapter has been stopped because it has over heated. Restart the computer. If the problem persists, power off the system and replace the adapter";
+
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598]		= &ixgbe_82598_info,
 	[board_82599]		= &ixgbe_82599_info,
@@ -2390,10 +2392,7 @@ static void ixgbe_check_overtemp_subtask(struct ixgbe_adapter *adapter)
 			return;
 		break;
 	}
-	e_crit(drv,
-	       "Network adapter has been stopped because it has over heated. "
-	       "Restart the computer. If the problem persists, "
-	       "power off the system and replace the adapter\n");
+	e_crit(drv, "%s\n", ixgbe_overheat_msg);
 
 	adapter->interrupt_event = 0;
 }
@@ -2440,10 +2439,7 @@ static void ixgbe_check_overtemp_event(struct ixgbe_adapter *adapter, u32 eicr)
 		return;
 	}
 
-	e_crit(drv,
-	       "Network adapter has been stopped because it has over heated. "
-	       "Restart the computer. If the problem persists, "
-	       "power off the system and replace the adapter\n");
+	e_crit(drv, "%s\n", ixgbe_overheat_msg);
 }
 
 static void ixgbe_check_sfp_event(struct ixgbe_adapter *adapter, u32 eicr)
-- 
2.4.2
