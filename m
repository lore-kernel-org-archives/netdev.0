From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 4/7] r8152: calculate the dropped packets for rx
Date: Fri, 7 Mar 2014 11:04:37 +0800
Message-ID: <1394161480-2918-5-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394161480-2918-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Continue dealing with the remain rx packets, even though the allocation
of the skb fail. This could calculate the correct dropped packets.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f1eaa18..08f4e870 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1456,7 +1456,7 @@ static void rx_bottom(struct r8152 *tp)
 			skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
 			if (!skb) {
 				stats->rx_dropped++;
-				break;
+				goto find_next_rx;
 			}
 			memcpy(skb->data, rx_data, pkt_len);
 			skb_put(skb, pkt_len);
@@ -1465,6 +1465,7 @@ static void rx_bottom(struct r8152 *tp)
 			stats->rx_packets++;
 			stats->rx_bytes += pkt_len;
 
+find_next_rx:
 			rx_data = rx_agg_align(rx_data + pkt_len + CRC_SIZE);
 			rx_desc = (struct rx_desc *)rx_data;
 			len_used = (int)(rx_data - (u8 *)agg->head);
-- 
1.8.4.2
