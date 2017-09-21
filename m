From: Allen Pais <allen.lkml@gmail.com>
Subject: [PATCH 1/1] net: usb: catc: use setup_timer() helper
Date: Thu, 21 Sep 2017 18:24:15 +0530
Message-ID: <1505998455-14776-1-git-send-email-allen.lkml@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Allen Pais <allen.lkml@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

    Use setup_timer function instead of initializing timer with the
    function and data fields.

Signed-off-by: Allen Pais <allen.lkml@gmail.com>
---
 drivers/net/usb/catc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index dbc9031..aeb62e1 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -805,9 +805,7 @@ static int catc_probe(struct usb_interface *intf, const struct usb_device_id *id
 	spin_lock_init(&catc->tx_lock);
 	spin_lock_init(&catc->ctrl_lock);
 
-	init_timer(&catc->timer);
-	catc->timer.data = (long) catc;
-	catc->timer.function = catc_stats_timer;
+	setup_timer(&catc->timer, catc_stats_timer, (long)catc);
 
 	catc->ctrl_urb = usb_alloc_urb(0, GFP_KERNEL);
 	catc->tx_urb = usb_alloc_urb(0, GFP_KERNEL);
-- 
2.7.4
