From: <Woojung.Huh@microchip.com>
Subject: [PATCH net 4/4] lan78xx: throttle tx path per usb speed
Date: Mon, 25 Jan 2016 23:04:19 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049DEF5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:31193 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932666AbcAYXEU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:04:20 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Throttle TX path when slower than SUPER SPEED USB to avoid
choking CPU.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 9b95333..e0cbc5a 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2264,7 +2264,9 @@ netdev_tx_t lan78xx_start_xmit(struct sk_buff *skb, struct net_device *net)
 	if (skb2) {
 		skb_queue_tail(&dev->txq_pend, skb2);
 
-		if (skb_queue_len(&dev->txq_pend) > 10)
+		/* throttle TX patch at slower than SUPER SPEED USB */
+		if ((dev->udev->speed < USB_SPEED_SUPER) &&
+		    (skb_queue_len(&dev->txq_pend) > 10))
 			netif_stop_queue(net);
 	} else {
 		netif_dbg(dev, tx_err, dev->net,
-- 
2.1.4
