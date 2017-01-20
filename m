From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: fix the rx doesn't work
Date: Fri, 20 Jan 2017 14:07:52 +0800
Message-ID: <1394712342-15778-233-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rtl8152_post_reset() doesn't submit the rx urb, so the rx wouldn't work.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f3b48ad..e8f4f88 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3545,6 +3545,7 @@ static int rtl8152_post_reset(struct usb_interface *intf)
 	if (netif_carrier_ok(netdev)) {
 		mutex_lock(&tp->control);
 		tp->rtl_ops.enable(tp);
+		rtl_start_rx(tp);
 		rtl8152_set_rx_mode(netdev);
 		mutex_unlock(&tp->control);
 		netif_wake_queue(netdev);
-- 
2.7.4
