From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH 10/26] wireless, at76c50x:: Don't needlessly test for NULL
 before calling release_firmware()
Date: Mon, 9 Apr 2012 22:50:47 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1204092218300.13925@swampdragon.chaosbits.net>
References: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1204092157340.13925@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The release_firmware() function deals gracefully with being passed a
NULL pointer, so explicit tests before the call are rather pointless.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/net/wireless/at76c50x-usb.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 4045e5a..faa8bcb 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -2512,10 +2512,8 @@ static void __exit at76_mod_exit(void)
 
 	printk(KERN_INFO DRIVER_DESC " " DRIVER_VERSION " unloading\n");
 	usb_deregister(&at76_driver);
-	for (i = 0; i < ARRAY_SIZE(firmwares); i++) {
-		if (firmwares[i].fw)
-			release_firmware(firmwares[i].fw);
-	}
+	for (i = 0; i < ARRAY_SIZE(firmwares); i++)
+		release_firmware(firmwares[i].fw);
 	led_trigger_unregister_simple(ledtrig_tx);
 }
 
-- 
1.7.10


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
