From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/4] e1000e: Use kmemdup rather than duplicating its implementation
Date: Sat, 22 Jan 2011 03:56:15 -0800
Message-ID: <1295697376-2984-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38728 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab1AVL4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 06:56:32 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <1295697376-2984-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The semantic patch that makes this output is available
in scripts/coccinelle/api/memdup.cocci.

More information about semantic patching is available at
http://coccinelle.lip6.fr/

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/ethtool.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 323fd12..daa7fe4 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -684,20 +684,13 @@ static int e1000_set_ringparam(struct net_device *netdev,
 	rx_old = adapter->rx_ring;
 
 	err = -ENOMEM;
-	tx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	tx_ring = kmemdup(tx_old, sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!tx_ring)
 		goto err_alloc_tx;
-	/*
-	 * use a memcpy to save any previously configured
-	 * items like napi structs from having to be
-	 * reinitialized
-	 */
-	memcpy(tx_ring, tx_old, sizeof(struct e1000_ring));
 
-	rx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
+	rx_ring = kmemdup(rx_old, sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!rx_ring)
 		goto err_alloc_rx;
-	memcpy(rx_ring, rx_old, sizeof(struct e1000_ring));
 
 	adapter->tx_ring = tx_ring;
 	adapter->rx_ring = rx_ring;
-- 
1.7.3.4

