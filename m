From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/13] ixgbe: dcbnl reduce duplicated code and indentation
Date: Fri, 10 Jun 2011 20:02:09 -0700
Message-ID: <1307761341-5267-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29360 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756800Ab1FKDCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 23:02:25 -0400
In-Reply-To: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Replace duplicated code in if/else branches with single
check and ixgbe_init_interrupt_scheme().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |   51 ++++++++++++++++++--------------------
 1 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 5e7ed22..293ff06 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -146,37 +146,34 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		adapter->flags |= IXGBE_FLAG_DCB_ENABLED;
 		if (!netdev_get_num_tc(netdev))
 			ixgbe_setup_tc(netdev, MAX_TRAFFIC_CLASS);
-
-		ixgbe_init_interrupt_scheme(adapter);
-		if (netif_running(netdev))
-			netdev->netdev_ops->ndo_open(netdev);
 	} else {
 		/* Turn off DCB */
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			if (netif_running(netdev))
-				netdev->netdev_ops->ndo_stop(netdev);
-			ixgbe_clear_interrupt_scheme(adapter);
+		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+			goto out;
 
-			adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
-			adapter->temp_dcb_cfg.pfc_mode_enable = false;
-			adapter->dcb_cfg.pfc_mode_enable = false;
-			adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
-			switch (adapter->hw.mac.type) {
-			case ixgbe_mac_82599EB:
-			case ixgbe_mac_X540:
-				adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
-				break;
-			default:
-				break;
-			}
-
-			ixgbe_setup_tc(netdev, 0);
-
-			ixgbe_init_interrupt_scheme(adapter);
-			if (netif_running(netdev))
-				netdev->netdev_ops->ndo_open(netdev);
+		if (netif_running(netdev))
+			netdev->netdev_ops->ndo_stop(netdev);
+		ixgbe_clear_interrupt_scheme(adapter);
+
+		adapter->hw.fc.requested_mode = adapter->last_lfc_mode;
+		adapter->temp_dcb_cfg.pfc_mode_enable = false;
+		adapter->dcb_cfg.pfc_mode_enable = false;
+		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
+		switch (adapter->hw.mac.type) {
+		case ixgbe_mac_82599EB:
+		case ixgbe_mac_X540:
+			adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
+			break;
+		default:
+			break;
 		}
+
+		ixgbe_setup_tc(netdev, 0);
 	}
+
+	ixgbe_init_interrupt_scheme(adapter);
+	if (netif_running(netdev))
+		netdev->netdev_ops->ndo_open(netdev);
 out:
 	return err;
 }
-- 
1.7.5.2

