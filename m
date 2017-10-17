From: <netanel@amazon.com>
Subject: [PATCH net 3/3] net: ena: fix wrong max Tx/Rx queues on ethtool
Date: Tue, 17 Oct 2017 07:33:05 +0000
Message-ID: <1508225585-106167-4-git-send-email-netanel@amazon.com>
References: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:22711 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932887AbdJQHd1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:33:27 -0400
In-Reply-To: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

ethtool ena_get_channels() expose the max number of queues as the max
number of queues ENA supports (128 queues) and not the actual number
of created queues.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_ethtool.c b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
index b1212debc2e1..967020fb26ee 100644
--- a/drivers/net/ethernet/amazon/ena/ena_ethtool.c
+++ b/drivers/net/ethernet/amazon/ena/ena_ethtool.c
@@ -742,8 +742,8 @@ static void ena_get_channels(struct net_device *netdev,
 {
 	struct ena_adapter *adapter = netdev_priv(netdev);
 
-	channels->max_rx = ENA_MAX_NUM_IO_QUEUES;
-	channels->max_tx = ENA_MAX_NUM_IO_QUEUES;
+	channels->max_rx = adapter->num_queues;
+	channels->max_tx = adapter->num_queues;
 	channels->max_other = 0;
 	channels->max_combined = 0;
 	channels->rx_count = adapter->num_queues;
-- 
1.8.3.1
