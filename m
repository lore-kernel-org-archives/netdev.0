From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH net-next] ixgbe: Fix for RAR0 not being set to default MAC addr
Date: Wed,  6 Jan 2016 12:05:29 -0800
Message-ID: <1452110729-15659-1-git-send-email-tushar.n.dave@oracle.com>
Cc: davem@davemloft.net, Tushar Dave <tushar.n.dave@oracle.com>
To: jesse.brandeburg@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, carolyn.wyborny@intel.com,
	netdev@vger.kernel.org, duyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:23319 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbcAFUH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:07:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit c9f53e63c208 ("ixgbe: Refactor MAC address configuration code")
introduced code that doesn't set HW register RAR0 to default mac address
but FF:FF:FF:FF:FF:FF. Due to this, ixgbe HW discards all incoming packets
that doesn't have destination mac address equals to FF:FF:FF:FF:FF:FF.

This commit sets RAR0 correctly to default HW mac address.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ea9537d..7e6ce13 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9084,6 +9084,8 @@ skip_sriov:
 		goto err_sw_init;
 	}
 
+	/* Set hw->addr to permanent mac address*/
+	ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
 	ixgbe_mac_set_default_filter(adapter);
 
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
-- 
1.9.1
