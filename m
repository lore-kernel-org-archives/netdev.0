From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/25] fm10k: Corrected an error in Tx statistics
Date: Tue, 14 Apr 2015 16:50:47 -0700
Message-ID: <1429055471-401-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62596 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950AbbDNXvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 19:51:14 -0400
In-Reply-To: <1429055471-401-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function collecting Tx statistics was actually using values from the RX
ring. Thus, Tx and Rx statistics values reported by "ifconfig" will
return identical values. This change corrects this error and the Tx
statistics is now reading from the Tx ring.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index d5b303d..a7db5e2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1126,7 +1126,7 @@ static struct rtnl_link_stats64 *fm10k_get_stats64(struct net_device *netdev,
 	}
 
 	for (i = 0; i < interface->num_tx_queues; i++) {
-		ring = ACCESS_ONCE(interface->rx_ring[i]);
+		ring = ACCESS_ONCE(interface->tx_ring[i]);
 
 		if (!ring)
 			continue;
-- 
1.9.3
