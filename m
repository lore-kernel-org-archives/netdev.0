From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/2] be2net: fix ethtool ringparam reporting
Date: Tue, 13 Dec 2011 16:28:49 +0530
Message-ID: <1323773930-6617-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27578 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751571Ab1LMLHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 06:07:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool "-g" option is supposed to report the max queue length and
user modified queue length for RX and TX queues.  be2net doesn't support
user modification of queue lengths. So, the correct values for these
would be the max numbers.
be2net incorrectly reports the queue used values for these fields.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 575c783..6ba2dc6 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -520,16 +520,13 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
-static void
-be_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
+static void be_get_ringparam(struct net_device *netdev,
+			     struct ethtool_ringparam *ring)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
 
-	ring->rx_max_pending = adapter->rx_obj[0].q.len;
-	ring->tx_max_pending = adapter->tx_obj[0].q.len;
-
-	ring->rx_pending = atomic_read(&adapter->rx_obj[0].q.used);
-	ring->tx_pending = atomic_read(&adapter->tx_obj[0].q.used);
+	ring->rx_max_pending = ring->rx_pending = adapter->rx_obj[0].q.len;
+	ring->tx_max_pending = ring->tx_pending = adapter->tx_obj[0].q.len;
 }
 
 static void
-- 
1.7.4
