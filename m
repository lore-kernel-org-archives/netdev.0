From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] igb/e1000e: Naming interrupt vectors
Date: Fri, 05 Dec 2008 15:06:49 -0800
Message-ID: <20081205230649.3109.1959.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:55828
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754081AbYLEXHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 18:07:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Change interrupt vector naming to match recent changes from Robert Olsson.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    4 ++--
 drivers/net/igb/igb_main.c  |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 65fd979..a4278bb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1478,7 +1478,7 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	int err = 0, vector = 0;
 
 	if (strlen(netdev->name) < (IFNAMSIZ - 5))
-		sprintf(adapter->rx_ring->name, "%s-rx0", netdev->name);
+		sprintf(adapter->rx_ring->name, "%s-rx-0", netdev->name);
 	else
 		memcpy(adapter->rx_ring->name, netdev->name, IFNAMSIZ);
 	err = request_irq(adapter->msix_entries[vector].vector,
@@ -1491,7 +1491,7 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	vector++;
 
 	if (strlen(netdev->name) < (IFNAMSIZ - 5))
-		sprintf(adapter->tx_ring->name, "%s-tx0", netdev->name);
+		sprintf(adapter->tx_ring->name, "%s-tx-0", netdev->name);
 	else
 		memcpy(adapter->tx_ring->name, netdev->name, IFNAMSIZ);
 	err = request_irq(adapter->msix_entries[vector].vector,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a08921e..c49b8d8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -446,7 +446,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		struct igb_ring *ring = &(adapter->tx_ring[i]);
-		sprintf(ring->name, "%s-tx%d", netdev->name, i);
+		sprintf(ring->name, "%s-tx-%d", netdev->name, i);
 		err = request_irq(adapter->msix_entries[vector].vector,
 				  &igb_msix_tx, 0, ring->name,
 				  &(adapter->tx_ring[i]));
@@ -459,7 +459,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &(adapter->rx_ring[i]);
 		if (strlen(netdev->name) < (IFNAMSIZ - 5))
-			sprintf(ring->name, "%s-rx%d", netdev->name, i);
+			sprintf(ring->name, "%s-rx-%d", netdev->name, i);
 		else
 			memcpy(ring->name, netdev->name, IFNAMSIZ);
 		err = request_irq(adapter->msix_entries[vector].vector,

