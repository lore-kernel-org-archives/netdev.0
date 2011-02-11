From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 01/15] e1000e: replace unbounded sprintf with snprintf
Date: Fri, 11 Feb 2011 09:20:48 -0800
Message-ID: <1297444862-32091-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11125 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757855Ab1BKRVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:19 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 6025d5f..7cedfeb 100644
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

