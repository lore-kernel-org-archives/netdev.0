From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net] r8152: fix rtl8152_post_reset function
Date: Fri, 20 Jan 2017 14:33:55 +0800
Message-ID: <1394712342-15778-234-Taiwan-albertk@realtek.com>
References: <1394712342-15778-233-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-233-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The rtl8152_post_reset() should sumbit rx urb and interrupt transfer,
otherwise the rx wouldn't work and the linking change couldn't be
detected.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f3b48ad..0e99af0 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3545,12 +3545,14 @@ static int rtl8152_post_reset(struct usb_interface *intf)
 	if (netif_carrier_ok(netdev)) {
 		mutex_lock(&tp->control);
 		tp->rtl_ops.enable(tp);
+		rtl_start_rx(tp);
 		rtl8152_set_rx_mode(netdev);
 		mutex_unlock(&tp->control);
 		netif_wake_queue(netdev);
 	}
 
 	napi_enable(&tp->napi);
+	usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
