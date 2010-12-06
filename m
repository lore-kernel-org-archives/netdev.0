From: Indrek Peri <Indrek.Peri@Ericsson.com>
Subject: [PATCH] Dot not insert RX urbs if EVENT_DEV_ASLEEP flag is set.
Date: Mon, 6 Dec 2010 11:24:07 +0100
Message-ID: <1291631047-23766-1-git-send-email-Indrek.Peri@Ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Indrek Peri <Indrek.Peri@Ericsson.com>
To: <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:58113 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab0LFKWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 05:22:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Indrek Peri <Indrek.Peri@Ericsson.com>
---
 drivers/net/usb/usbnet.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index c04d49e..d83adcc 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1172,7 +1172,8 @@ static void usbnet_bh (unsigned long param)
 	} else if (netif_running (dev->net) &&
 		   netif_device_present (dev->net) &&
 		   !timer_pending (&dev->delay) &&
-		   !test_bit (EVENT_RX_HALT, &dev->flags)) {
+		   !test_bit (EVENT_RX_HALT, &dev->flags) &&
+		   !test_bit (EVENT_DEV_ASLEEP, &dev->flags)) {
 		int	temp = dev->rxq.qlen;
 		int	qlen = RX_QLEN (dev);
 
-- 
1.7.0.3

