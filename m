From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] ixgbevf: use ether_addr_copy instead of memcpy
Date: Mon, 23 Nov 2015 11:36:14 -0800
Message-ID: <1448307376-20063-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44986 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876AbbKWTg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:26 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

replace some instances of memcpy for setting up the mac address with
ether_addr_copy()

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1b15f95..47c71e1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2260,10 +2260,8 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 	}
 
 	if (is_valid_ether_addr(adapter->hw.mac.addr)) {
-		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
-		       netdev->addr_len);
-		memcpy(netdev->perm_addr, adapter->hw.mac.addr,
-		       netdev->addr_len);
+		ether_addr_copy(netdev->dev_addr, adapter->hw.mac.addr);
+		ether_addr_copy(netdev->perm_addr, adapter->hw.mac.addr);
 	}
 
 	adapter->last_reset = jiffies;
@@ -2659,13 +2657,13 @@ static int ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 		else if (is_zero_ether_addr(adapter->hw.mac.addr))
 			dev_info(&pdev->dev,
 				 "MAC address not assigned by administrator.\n");
-		memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
+		ether_addr_copy(netdev->dev_addr, hw->mac.addr);
 	}
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		dev_info(&pdev->dev, "Assigning random MAC address\n");
 		eth_hw_addr_random(netdev);
-		memcpy(hw->mac.addr, netdev->dev_addr, netdev->addr_len);
+		ether_addr_copy(hw->mac.addr, netdev->dev_addr);
 	}
 
 	/* Enable dynamic interrupt throttling rates */
@@ -3695,8 +3693,8 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(hw->mac.addr, addr->sa_data, netdev->addr_len);
+	ether_addr_copy(netdev->dev_addr, addr->sa_data);
+	ether_addr_copy(hw->mac.addr, addr->sa_data);
 
 	spin_lock_bh(&adapter->mbx_lock);
 
-- 
2.5.0
