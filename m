From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/7] igb: change type for ring sizes to u16 in
	igb_set_ring_param
Date: Thu, 12 Nov 2009 20:36:41 -0800
Message-ID: <20091113043604.1240.80142.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:35538 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755635AbZKMEgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:36:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Change the type for the ring size values to u16 and use min/max_t instead of
min/max.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 90b89a8..f2b2825 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -735,17 +735,17 @@ static int igb_set_ringparam(struct net_device *netdev,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct igb_ring *temp_ring;
 	int i, err = 0;
-	u32 new_rx_count, new_tx_count;
+	u16 new_rx_count, new_tx_count;
 
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	new_rx_count = min(ring->rx_pending, (u32)IGB_MAX_RXD);
-	new_rx_count = max(new_rx_count, (u32)IGB_MIN_RXD);
+	new_rx_count = min_t(u32, ring->rx_pending, IGB_MAX_RXD);
+	new_rx_count = max_t(u16, new_rx_count, IGB_MIN_RXD);
 	new_rx_count = ALIGN(new_rx_count, REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	new_tx_count = min(ring->tx_pending, (u32)IGB_MAX_TXD);
-	new_tx_count = max(new_tx_count, (u32)IGB_MIN_TXD);
+	new_tx_count = min_t(u32, ring->tx_pending, IGB_MAX_TXD);
+	new_tx_count = max_t(u16, new_tx_count, IGB_MIN_TXD);
 	new_tx_count = ALIGN(new_tx_count, REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if ((new_tx_count == adapter->tx_ring_count) &&

