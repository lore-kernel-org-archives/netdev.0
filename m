From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: replace tp->netdev with netdev
Date: Thu, 6 Mar 2014 15:07:17 +0800
Message-ID: <1394089638-1580-3-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394089638-1580-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394089638-1580-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace some tp->netdev with netdev.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index c8bad62..151398b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1037,6 +1037,7 @@ static void read_bulk_callback(struct urb *urb)
 static void write_bulk_callback(struct urb *urb)
 {
 	struct net_device_stats *stats;
+	struct net_device *netdev;
 	unsigned long flags;
 	struct tx_agg *agg;
 	struct r8152 *tp;
@@ -1050,10 +1051,11 @@ static void write_bulk_callback(struct urb *urb)
 	if (!tp)
 		return;
 
-	stats = rtl8152_get_stats(tp->netdev);
+	netdev = tp->netdev;
+	stats = rtl8152_get_stats(netdev);
 	if (status) {
 		if (net_ratelimit())
-			netdev_warn(tp->netdev, "Tx status %d\n", status);
+			netdev_warn(netdev, "Tx status %d\n", status);
 		stats->tx_errors += agg->skb_num;
 	} else {
 		stats->tx_packets += agg->skb_num;
@@ -1066,7 +1068,7 @@ static void write_bulk_callback(struct urb *urb)
 
 	usb_autopm_put_interface_async(tp->intf);
 
-	if (!netif_carrier_ok(tp->netdev))
+	if (!netif_carrier_ok(netdev))
 		return;
 
 	if (!test_bit(WORK_ENABLE, &tp->flags))
-- 
1.8.4.2
