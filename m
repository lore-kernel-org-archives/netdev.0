From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: replace netdev_alloc_skb_ip_align with napi_alloc_skb
Date: Wed, 8 Jun 2016 14:52:33 +0800
Message-ID: <1394712342-15778-174-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:37897 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbcFHGxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 02:53:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace netdev_alloc_skb_ip_align() with napi_alloc_skb() which can save
several CPU cycles by avoiding having to disable and re-enable IRQs.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3f9f6ed..161c25e 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1742,7 +1742,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 			pkt_len -= CRC_SIZE;
 			rx_data += sizeof(struct rx_desc);
 
-			skb = netdev_alloc_skb_ip_align(netdev, pkt_len);
+			skb = napi_alloc_skb(&tp->napi, pkt_len);
 			if (!skb) {
 				stats->rx_dropped++;
 				goto find_next_rx;
-- 
2.4.11
