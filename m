From: <netanel@amazon.com>
Subject: [PATCH net 1/3] net: ena: reduce the severity of some printouts
Date: Tue, 17 Oct 2017 07:33:03 +0000
Message-ID: <1508225585-106167-2-git-send-email-netanel@amazon.com>
References: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:17124 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754307AbdJQHdw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:33:52 -0400
In-Reply-To: <1508225585-106167-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Decrease log level of checksum errors as these messages can be
triggered remotely by bad packets.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index f7dc22f65d9f..7040b9052747 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -966,7 +966,7 @@ static inline void ena_rx_checksum(struct ena_ring *rx_ring,
 		u64_stats_update_begin(&rx_ring->syncp);
 		rx_ring->rx_stats.bad_csum++;
 		u64_stats_update_end(&rx_ring->syncp);
-		netif_err(rx_ring->adapter, rx_err, rx_ring->netdev,
+		netif_dbg(rx_ring->adapter, rx_err, rx_ring->netdev,
 			  "RX IPv4 header checksum error\n");
 		return;
 	}
@@ -979,7 +979,7 @@ static inline void ena_rx_checksum(struct ena_ring *rx_ring,
 			u64_stats_update_begin(&rx_ring->syncp);
 			rx_ring->rx_stats.bad_csum++;
 			u64_stats_update_end(&rx_ring->syncp);
-			netif_err(rx_ring->adapter, rx_err, rx_ring->netdev,
+			netif_dbg(rx_ring->adapter, rx_err, rx_ring->netdev,
 				  "RX L4 checksum error\n");
 			skb->ip_summed = CHECKSUM_NONE;
 			return;
-- 
1.8.3.1
