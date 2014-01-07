From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: correct some messages
Date: Tue, 7 Jan 2014 11:18:22 +0800
Message-ID: <1389064702-1173-1-git-send-email-hayeswang@realtek.com>
References: <1388999999-9218-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388999999-9218-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 - Replace pr_warn_ratelimited() with net_ratelimit() and netdev_warn().
 - Adjust the algnment of some messages.
 - Remove the peroid.
 - Fix some messages don't have terminating newline.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 5107372..49632ff 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -814,10 +814,12 @@ static void read_bulk_callback(struct urb *urb)
 	case -ENOENT:
 		return;	/* the urb is in unlink state */
 	case -ETIME:
-		pr_warn_ratelimited("may be reset is needed?..\n");
+		if (net_ratelimit())
+			netdev_warn(netdev, "maybe reset is needed?\n");
 		break;
 	default:
-		pr_warn_ratelimited("Rx status %d\n", status);
+		if (net_ratelimit())
+			netdev_warn(netdev, "Rx status %d\n", status);
 		break;
 	}
 
@@ -850,7 +852,8 @@ static void write_bulk_callback(struct urb *urb)
 
 	stats = rtl8152_get_stats(tp->netdev);
 	if (status) {
-		pr_warn_ratelimited("Tx status %d\n", status);
+		if (net_ratelimit())
+			netdev_warn(tp->netdev, "Tx status %d\n", status);
 		stats->tx_errors += agg->skb_num;
 	} else {
 		stats->tx_packets += agg->skb_num;
@@ -927,7 +930,7 @@ resubmit:
 		netif_device_detach(tp->netdev);
 	else if (res)
 		netif_err(tp, intr, tp->netdev,
-			"can't resubmit intr, status %d\n", res);
+			  "can't resubmit intr, status %d\n", res);
 }
 
 static inline void *rx_agg_align(void *data)
@@ -1336,7 +1339,7 @@ static void rtl8152_tx_timeout(struct net_device *netdev)
 	struct r8152 *tp = netdev_priv(netdev);
 	int i;
 
-	netif_warn(tp, tx_err, netdev, "Tx timeout.\n");
+	netif_warn(tp, tx_err, netdev, "Tx timeout\n");
 	for (i = 0; i < RTL8152_MAX_TX; i++)
 		usb_unlink_urb(tp->tx_info[i].urb);
 }
@@ -1806,8 +1809,8 @@ static int rtl8152_open(struct net_device *netdev)
 	if (res) {
 		if (res == -ENODEV)
 			netif_device_detach(tp->netdev);
-		netif_warn(tp, ifup, netdev,
-			"intr_urb submit failed: %d\n", res);
+		netif_warn(tp, ifup, netdev, "intr_urb submit failed: %d\n",
+			   res);
 		return res;
 	}
 
@@ -2094,7 +2097,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	netdev = alloc_etherdev(sizeof(struct r8152));
 	if (!netdev) {
-		dev_err(&intf->dev, "Out of memory");
+		dev_err(&intf->dev, "Out of memory\n");
 		return -ENOMEM;
 	}
 
@@ -2135,11 +2138,11 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	ret = register_netdev(netdev);
 	if (ret != 0) {
-		netif_err(tp, probe, netdev, "couldn't register the device");
+		netif_err(tp, probe, netdev, "couldn't register the device\n");
 		goto out1;
 	}
 
-	netif_info(tp, probe, netdev, "%s", DRIVER_VERSION);
+	netif_info(tp, probe, netdev, "%s\n", DRIVER_VERSION);
 
 	return 0;
 
-- 
1.8.4.2
