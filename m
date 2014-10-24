From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] ath6kl: remove incorrect reset_resume handler
Date: Sat, 25 Oct 2014 00:02:52 +0400
Message-ID: <1414180972-16413-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Existing implementation of reset_resume handler just calls
ath6kl_usb_remove() that deallocates all resources.
It can lead to double free, etc. on disconnect.

The patch removes reset_resume handler,
so usb core could conservatively reset the driver.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/ath/ath6kl/usb.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/usb.c b/drivers/net/wireless/ath/ath6kl/usb.c
index a6a5e40b3e98..9da3594fd010 100644
--- a/drivers/net/wireless/ath/ath6kl/usb.c
+++ b/drivers/net/wireless/ath/ath6kl/usb.c
@@ -1193,18 +1193,10 @@ static int ath6kl_usb_pm_resume(struct usb_interface *interface)
 	return 0;
 }
 
-static int ath6kl_usb_pm_reset_resume(struct usb_interface *intf)
-{
-	if (usb_get_intfdata(intf))
-		ath6kl_usb_remove(intf);
-	return 0;
-}
-
 #else
 
 #define ath6kl_usb_pm_suspend NULL
 #define ath6kl_usb_pm_resume NULL
-#define ath6kl_usb_pm_reset_resume NULL
 
 #endif
 
@@ -1222,7 +1214,6 @@ static struct usb_driver ath6kl_usb_driver = {
 	.probe = ath6kl_usb_probe,
 	.suspend = ath6kl_usb_pm_suspend,
 	.resume = ath6kl_usb_pm_resume,
-	.reset_resume = ath6kl_usb_pm_reset_resume,
 	.disconnect = ath6kl_usb_remove,
 	.id_table = ath6kl_usb_ids,
 	.supports_autosuspend = true,
-- 
1.9.1
