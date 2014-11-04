From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 02/12] amd-xgbe: Rename pre_xmit function to
 dev_xmit
Date: Tue, 4 Nov 2014 16:06:32 -0600
Message-ID: <20141104220632.24738.58488.stgit@tlendack-t1.amdoffice.net>
References: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0104.outbound.protection.outlook.com ([157.56.110.104]:44390
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752193AbaKDWGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 17:06:36 -0500
In-Reply-To: <20141104220620.24738.10070.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pre_xmit function name implies that it performs operations prior
to transmitting the packet when in fact it is responsible for setting
up the descriptors and initiating the transmit.  Rename this to
function from pre_xmit to dev_xmit, which is consistent with the name
used during receive processing - dev_read.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    8 ++++----
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h     |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 9da3a03..7b97d38 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1198,7 +1198,7 @@ static void xgbe_config_dcb_pfc(struct xgbe_prv_data *pdata)
 	xgbe_config_flow_control(pdata);
 }
 
-static void xgbe_pre_xmit(struct xgbe_channel *channel)
+static void xgbe_dev_xmit(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
 	struct xgbe_ring *ring = channel->tx_ring;
@@ -1211,7 +1211,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 	int start_index = ring->cur;
 	int i;
 
-	DBGPR("-->xgbe_pre_xmit\n");
+	DBGPR("-->xgbe_dev_xmit\n");
 
 	csum = XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
 			      CSUM_ENABLE);
@@ -1410,7 +1410,7 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 	      channel->name, start_index & (ring->rdesc_count - 1),
 	      (ring->cur - 1) & (ring->rdesc_count - 1));
 
-	DBGPR("<--xgbe_pre_xmit\n");
+	DBGPR("<--xgbe_dev_xmit\n");
 }
 
 static int xgbe_dev_read(struct xgbe_channel *channel)
@@ -2561,7 +2561,7 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 	hw_if->powerup_rx = xgbe_powerup_rx;
 	hw_if->powerdown_rx = xgbe_powerdown_rx;
 
-	hw_if->pre_xmit = xgbe_pre_xmit;
+	hw_if->dev_xmit = xgbe_dev_xmit;
 	hw_if->dev_read = xgbe_dev_read;
 	hw_if->enable_int = xgbe_enable_int;
 	hw_if->disable_int = xgbe_disable_int;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 07b00bd..8cb2372 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1343,7 +1343,7 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 	xgbe_prep_tx_tstamp(pdata, skb, packet);
 
 	/* Configure required descriptor fields for transmission */
-	hw_if->pre_xmit(channel);
+	hw_if->dev_xmit(channel);
 
 #ifdef XGMAC_ENABLE_TX_PKT_DUMP
 	xgbe_print_pkt(netdev, skb, true);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 789957d..0dc15d7 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -456,7 +456,7 @@ struct xgbe_hw_if {
 
 	int (*enable_int)(struct xgbe_channel *, enum xgbe_int);
 	int (*disable_int)(struct xgbe_channel *, enum xgbe_int);
-	void (*pre_xmit)(struct xgbe_channel *);
+	void (*dev_xmit)(struct xgbe_channel *);
 	int (*dev_read)(struct xgbe_channel *);
 	void (*tx_desc_init)(struct xgbe_channel *);
 	void (*rx_desc_init)(struct xgbe_channel *);
