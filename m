From: Benoit Cousson <b-cousson@ti.com>
Subject: [PATCH] ks8851: Fix NOHZ local_softirq_pending 08 warning
Date: Mon, 13 Feb 2012 18:37:12 +0100
Message-ID: <1329154632-12745-1-git-send-email-b-cousson@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>, Benoit Cousson <b-cousson@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <linux-omap-owner@vger.kernel.org>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fix a similar problem as in 72092cc45378176ba700034c91b7af2db524df26
and 481a8199142c050b72bff8a1956a49fd0a75bbe0 ("can:
fix NOHZ local_softirq_pending 08 warning"). This fix replaces netif_rx()
with netif_rx_ni() which has to be used from process/softirq context.

Signed-off-by: Benoit Cousson <b-cousson@ti.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/micrel/ks8851.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index 6b35e7d..0c3e400 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -583,7 +583,7 @@ static void ks8851_rx_pkts(struct ks8851_net *ks)
 					ks8851_dbg_dumpkkt(ks, rxpkt);
 
 				skb->protocol = eth_type_trans(skb, ks->netdev);
-				netif_rx(skb);
+				netif_rx_ni(skb);
 
 				ks->netdev->stats.rx_packets++;
 				ks->netdev->stats.rx_bytes += rxlen;
-- 
1.7.0.4

