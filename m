From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 09/13] e1000: drop redunant line of code, cleanup
Date: Fri, 25 Sep 2009 15:19:23 -0700
Message-ID: <20090925221923.26715.61459.stgit@localhost.localdomain>
References: <20090925221613.26715.66796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:48124
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752875AbZIYWTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 18:19:41 -0400
In-Reply-To: <20090925221613.26715.66796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

adapter was being assigned twice, also clarified variable name and unwrapped
line.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 2178e0d..d7dea69 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3394,17 +3394,13 @@ static irqreturn_t e1000_intr(int irq, void *data)
 static int e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
-	struct net_device *poll_dev = adapter->netdev;
-	int tx_cleaned = 0, work_done = 0;
+	int tx_clean_complete = 0, work_done = 0;
 
-	adapter = netdev_priv(poll_dev);
+	tx_clean_complete = e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
 
-	tx_cleaned = e1000_clean_tx_irq(adapter, &adapter->tx_ring[0]);
+	adapter->clean_rx(adapter, &adapter->rx_ring[0], &work_done, budget);
 
-	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, budget);
-
-	if (!tx_cleaned)
+	if (!tx_clean_complete)
 		work_done = budget;
 
 	/* If budget not fully consumed, exit the polling mode */

