From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 03/11] ixgb: Fix hard coded numbers
Date: Fri, 21 Apr 2006 18:00:37 -0700
Message-ID: <20060422010036.24255.25895.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:11950 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750808AbWDVA5c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:32 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- removed hard coded numbers and used constants instead

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |    4 +++-
 drivers/net/ixgb/ixgb_main.c    |    8 ++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index e8d83de..978be30 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -44,6 +44,8 @@ extern void ixgb_free_rx_resources(struc
 extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
 extern void ixgb_update_stats(struct ixgb_adapter *adapter);
 
+#define IXGB_ALL_RAR_ENTRIES 16
+
 struct ixgb_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
@@ -317,7 +319,7 @@ ixgb_get_regs(struct net_device *netdev,
 	*reg++ = IXGB_READ_REG(hw, RXCSUM);	/*  20 */
 
 	/* there are 16 RAR entries in hardware, we only use 3 */
-	for(i = 0; i < 16; i++) {
+	for(i = 0; i < IXGB_ALL_RAR_ENTRIES; i++) {
 		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1)); /*21,...,51 */
 		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1)); /*22,...,52 */
 	}
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6f8fd6f..f468d5d 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1227,11 +1227,11 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 		if(++i == adapter->tx_ring.count) i = 0;
 		adapter->tx_ring.next_to_use = i;
 
-		return 1;
+		return TRUE;
 	}
 #endif
 
-	return 0;
+	return FALSE;
 }
 
 static inline boolean_t
@@ -1413,7 +1413,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 	if(unlikely(IXGB_DESC_UNUSED(&adapter->tx_ring) < DESC_NEEDED)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
@@ -1440,7 +1440,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 
 	netdev->trans_start = jiffies;
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**

