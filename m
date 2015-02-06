From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 4/7] r8152: check RTL8152_UNPLUG for rtl8152_close
Date: Fri, 6 Feb 2015 11:30:48 +0800
Message-ID: <1394712342-15778-133-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
 <1394712342-15778-129-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-129-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is unnecessary to accress the hw register if the device is unplugged.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 6667809..aade7b5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3046,7 +3046,7 @@ static int rtl8152_close(struct net_device *netdev)
 	netif_stop_queue(netdev);
 
 	res = usb_autopm_get_interface(tp->intf);
-	if (res < 0) {
+	if (res < 0 || test_bit(RTL8152_UNPLUG, &tp->flags)) {
 		rtl_drop_queued_tx(tp);
 		rtl_stop_rx(tp);
 	} else {
-- 
2.1.0
