From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 10/11] r8152: avoid rx queue more than 1000 packets
Date: Fri, 9 Jun 2017 17:11:47 +0800
Message-ID: <1394712342-15778-270-Taiwan-albertk@realtek.com>
References: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stop queuing rx packets if it is more than 1000.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 204f4b2..fa29583 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1813,6 +1813,10 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			unsigned int pkt_len;
 			struct sk_buff *skb;
 
+			/* limite the skb numbers for rx_queue */
+			if (unlikely(skb_queue_len(&tp->rx_queue) >= 1000))
+				break;
+
 			pkt_len = le32_to_cpu(rx_desc->opts1) & RX_LEN_MASK;
 			if (pkt_len < ETH_ZLEN)
 				break;
-- 
2.7.4
