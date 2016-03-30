From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 01/11] ixgbe: Fix for RAR0 not being set to default MAC addr
Date: Wed, 30 Mar 2016 16:00:45 -0700
Message-ID: <1459378855-139837-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49527 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755201AbcC3XBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:17 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

commit c9f53e63c208 ("ixgbe: Refactor MAC address configuration code")
introduced code that doesn't set HW register RAR0 to default mac address
but FF:FF:FF:FF:FF:FF. Due to this, ixgbe HW discards all incoming packets
that doesn't have destination mac address equals to FF:FF:FF:FF:FF:FF.

This commit sets RAR0 correctly to default HW mac address.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Tested-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 569cb07..f193273 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9329,6 +9329,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	/* Set hw->mac.addr to permanent MAC address */
+	ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
 	ixgbe_mac_set_default_filter(adapter);
 
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
-- 
2.5.5
