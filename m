From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 12/14] r8152: replace netif_rx with netif_receive_skb
Date: Tue, 18 Feb 2014 21:49:09 +0800
Message-ID: <1392731351-25502-13-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace netif_rx with netif_receive_skb to avoid disabling irq frequently
for increasing the efficiency.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3ff11ed..ff02d5d 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1464,7 +1464,7 @@ static void rx_bottom(struct r8152 *tp)
 			memcpy(skb->data, rx_data, pkt_len);
 			skb_put(skb, pkt_len);
 			skb->protocol = eth_type_trans(skb, netdev);
-			netif_rx(skb);
+			netif_receive_skb(skb);
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
 
-- 
1.8.4.2
