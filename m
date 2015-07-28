From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v2 2/2] r8152: reset device when tx timeout
Date: Tue, 28 Jul 2015 20:08:42 +0800
Message-ID: <1394712342-15778-161-Taiwan-albertk@realtek.com>
References: <1394712342-15778-156-Taiwan-albertk@realtek.com>
 <1394712342-15778-159-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-159-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device reset is necessary if the hw becomes abnormal and stops
transmitting packets.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e1b6d6d..6af299f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -27,7 +27,7 @@
 #include <linux/usb/cdc.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.08.0 (2015/01/13)"
+#define DRIVER_VERSION "v1.08.1 (2015/07/28)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -1902,11 +1902,11 @@ static void rtl_drop_queued_tx(struct r8152 *tp)
 static void rtl8152_tx_timeout(struct net_device *netdev)
 {
 	struct r8152 *tp = netdev_priv(netdev);
-	int i;
 
 	netif_warn(tp, tx_err, netdev, "Tx timeout\n");
-	for (i = 0; i < RTL8152_MAX_TX; i++)
-		usb_unlink_urb(tp->tx_info[i].urb);
+
+	usb_queue_reset_device(tp->intf);
+	cancel_delayed_work(&tp->schedule);
 }
 
 static void rtl8152_set_rx_mode(struct net_device *netdev)
-- 
2.4.2
