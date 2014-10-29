From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 3/3] r8152: check WORK_ENABLE in suspend function
Date: Wed, 29 Oct 2014 11:12:17 +0800
Message-ID: <1394712342-15778-72-Taiwan-albertk@realtek.com>
References: <1394712342-15778-69-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-69-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid unnecessary behavior when autosuspend occurs during open().
The relative processes should only be run after finishing open().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f224231..ca3c5d5 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3207,7 +3207,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 		netif_device_detach(netdev);
 	}
 
-	if (netif_running(netdev)) {
+	if (netif_running(netdev) && test_bit(WORK_ENABLE, &tp->flags)) {
 		clear_bit(WORK_ENABLE, &tp->flags);
 		usb_kill_urb(tp->intr_urb);
 		tasklet_disable(&tp->tl);
-- 
1.9.3
