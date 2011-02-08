From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 01/16] e1000e: replace unbounded sprintf with snprintf
Date: Tue,  8 Feb 2011 04:29:12 -0800
Message-ID: <1297168167-15755-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58635 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab1BHM3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:33 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/netdev.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5b916b0..80614c9 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1843,7 +1843,9 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	int err = 0, vector = 0;
 
 	if (strlen(netdev->name) < (IFNAMSIZ - 5))
-		sprintf(adapter->rx_ring->name, "%s-rx-0", netdev->name);
+		snprintf(adapter->rx_ring->name,
+			 sizeof(adapter->rx_ring->name) - 1,
+			 "%s-rx-0", netdev->name);
 	else
 		memcpy(adapter->rx_ring->name, netdev->name, IFNAMSIZ);
 	err = request_irq(adapter->msix_entries[vector].vector,
@@ -1856,7 +1858,9 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	vector++;
 
 	if (strlen(netdev->name) < (IFNAMSIZ - 5))
-		sprintf(adapter->tx_ring->name, "%s-tx-0", netdev->name);
+		snprintf(adapter->tx_ring->name,
+			 sizeof(adapter->tx_ring->name) - 1,
+			 "%s-tx-0", netdev->name);
 	else
 		memcpy(adapter->tx_ring->name, netdev->name, IFNAMSIZ);
 	err = request_irq(adapter->msix_entries[vector].vector,
-- 
1.7.4

