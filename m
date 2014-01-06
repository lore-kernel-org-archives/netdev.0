From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: move the actions of saving the information of the device
Date: Mon, 6 Jan 2014 14:39:25 +0800
Message-ID: <1388990366-8508-3-git-send-email-hayeswang@realtek.com>
References: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some information of the device may be used in other functions. Move
the relative code to make sure it would be initialzed correctly
before using it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 095f15b..8615681 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2759,6 +2759,10 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tp = netdev_priv(netdev);
 	tp->msg_enable = 0x7FFF;
 
+	tp->udev = udev;
+	tp->netdev = netdev;
+	tp->intf = intf;
+
 	if (!rtl_ops_init(tp, id)) {
 		netif_err(tp, probe, netdev, "Unknown Device");
 		return -ENODEV;
@@ -2767,9 +2771,6 @@ static int rtl8152_probe(struct usb_interface *intf,
 	tasklet_init(&tp->tl, bottom_half, (unsigned long)tp);
 	INIT_DELAYED_WORK(&tp->schedule, rtl_work_func_t);
 
-	tp->udev = udev;
-	tp->netdev = netdev;
-	tp->intf = intf;
 	netdev->netdev_ops = &rtl8152_netdev_ops;
 	netdev->watchdog_timeo = RTL8152_TX_TIMEOUT;
 
-- 
1.8.4.2
