From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/16] fm10k: use ether_addr_copy to copy MAC address
Date: Tue,  5 Apr 2016 01:01:18 -0700
Message-ID: <1459843288-40623-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25315 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757558AbcDEIC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:26 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Cleanup the remaining instances of using memcpy() instead of the preferred
ether_addr_copy().

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 60a70e9..6190a81 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1776,8 +1776,8 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 		netdev->addr_assign_type |= NET_ADDR_RANDOM;
 	}
 
-	memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
-	memcpy(netdev->perm_addr, hw->mac.addr, netdev->addr_len);
+	ether_addr_copy(netdev->dev_addr, hw->mac.addr);
+	ether_addr_copy(netdev->perm_addr, hw->mac.addr);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		dev_err(&pdev->dev, "Invalid MAC Address\n");
-- 
2.5.5
