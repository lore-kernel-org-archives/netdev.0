From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] ixgbe: Ping the VFs on link status change to trigger link change
Date: Tue, 17 Jul 2012 19:20:40 -0700
Message-ID: <1342578045-17778-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6702 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057Ab2GRCUt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 22:20:49 -0400
In-Reply-To: <1342578045-17778-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

When the link status changes on the PF we need to notify the VFs. In order
to do this we should ping all of the VFs in order to trigger a link status
change on them as well.

This fixes issues in which the PF would reset, but the VF didn't because the
NAK flag was not set in the VF mailbox.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ee230f5..17f46f0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5390,6 +5390,9 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 
 	netif_carrier_on(netdev);
 	ixgbe_check_vf_rate_limit(adapter);
+
+	/* ping all the active vfs to let them know link has changed */
+	ixgbe_ping_all_vfs(adapter);
 }
 
 /**
@@ -5419,6 +5422,9 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 
 	e_info(drv, "NIC Link is Down\n");
 	netif_carrier_off(netdev);
+
+	/* ping all the active vfs to let them know link has changed */
+	ixgbe_ping_all_vfs(adapter);
 }
 
 /**
-- 
1.7.10.4
