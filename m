From: Vincenzo Maffione <v.maffione@gmail.com>
Subject: [PATCH] drivers: net: xen-netfront: fix array initialization bug
Date: Sat, 12 Apr 2014 11:55:40 +0200
Message-ID: <1397296540-3007-1-git-send-email-v.maffione@gmail.com>
Cc: boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Vincenzo Maffione <v.maffione@gmail.com>
To: konrad.wilk@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the initialization of an array used in the TX
datapath that was mistakenly initialized together with the
RX datapath arrays. An out of range array access could happen
when RX and TX rings had different sizes.

Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>
---
 drivers/net/xen-netfront.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 057b057..158b5e6 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1291,13 +1291,13 @@ static struct net_device *xennet_create_dev(struct xenbus_device *dev)
 	for (i = 0; i < NET_TX_RING_SIZE; i++) {
 		skb_entry_set_link(&np->tx_skbs[i], i+1);
 		np->grant_tx_ref[i] = GRANT_INVALID_REF;
+		np->grant_tx_page[i] = NULL;
 	}
 
 	/* Clear out rx_skbs */
 	for (i = 0; i < NET_RX_RING_SIZE; i++) {
 		np->rx_skbs[i] = NULL;
 		np->grant_rx_ref[i] = GRANT_INVALID_REF;
-		np->grant_tx_page[i] = NULL;
 	}
 
 	/* A grant for every tx ring slot */
-- 
1.9.1
