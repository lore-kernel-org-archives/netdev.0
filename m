From: Ondrej Puzman <puzman@gmail.com>
Subject: [PATCH 1/4] pch_gbe: Fix transmit queue management
Date: Thu, 28 Nov 2013 10:44:39 +0100
Message-ID: <1385631882-12827-2-git-send-email-puzman@gmail.com>
References: <20131127.203929.1379316258754767343.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ondrej Puzman <puzman@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131127.203929.1379316258754767343.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to Documentation/networking/driver.txt the ndo_start_xmit method should not return NETDEV_TX_BUSY under normal circumstances.
Stop the transmit queue when tx_ring is full.

Signed-off-by: Ondrej Puzman <puzman@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 27ffe0e..6764e59 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2157,6 +2157,10 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	/* CRC,ITAG no support */
 	pch_gbe_tx_queue(adapter, tx_ring, skb);
+
+	if (unlikely(!PCH_GBE_DESC_UNUSED(tx_ring)))
+		netif_stop_queue(netdev);
+
 	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
-- 
1.7.2.3
