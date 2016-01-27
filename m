From: <Woojung.Huh@microchip.com>
Subject: [PATCH 3/3] lan78xx: throttle TX path at slower than SuperSpeed USB
Date: Wed, 27 Jan 2016 22:57:54 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049F348@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:14328 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934135AbcA0W54 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 17:57:56 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Throttle TX path only at slower than SuperSpeed USB.
SuperSpeed USB has enough bandwidth to maintain GigE.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/usb/lan78xx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 650e716..1c299b8 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -2263,7 +2263,9 @@ netdev_tx_t lan78xx_start_xmit(struct sk_buff *skb, struct net_device *net)
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
2.7.0
