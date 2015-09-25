From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next] lan78xx: Return 0 when lan78xx_suspend() has no
 error.
Date: Fri, 25 Sep 2015 21:13:48 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40423528@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:36714 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933215AbbIYVNt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 17:13:49 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lan78xx_suspend() may return non-zero from lan78xx_write_reg() in some scenario.
Fix to return 0 when lan78xx_suspend() has no error.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index d2a5f3f..226668e 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -3204,7 +3204,6 @@ int lan78xx_suspend(struct usb_interface *intf, pm_message_t message)
 	int ret;
 	int event;
 
-	ret = 0;
 	event = message.event;
 
 	if (!dev->suspend_count++) {
@@ -3286,6 +3285,7 @@ int lan78xx_suspend(struct usb_interface *intf, pm_message_t message)
 		}
 	}
 
+	ret = 0;
 out:
 	return ret;
 }
-- 
2.1.4
