From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/3] r8152: fix remote wakeup
Date: Thu, 23 Jul 2015 15:09:06 +0800
Message-ID: <1394712342-15778-150-Taiwan-albertk@realtek.com>
References: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-148-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set needs_remote_wakeup only when the device supports it.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e3a0110..eff1f25 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4059,7 +4059,8 @@ static int rtl8152_probe(struct usb_interface *intf,
 		break;
 	}
 
-	intf->needs_remote_wakeup = 1;
+	if (udev->actconfig->desc.bmAttributes & USB_CONFIG_ATT_WAKEUP)
+		intf->needs_remote_wakeup = 1;
 
 	tp->rtl_ops.init(tp);
 	set_ethernet_addr(tp);
-- 
2.4.2
