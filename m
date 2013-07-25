From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 2/2] USBNET: increase max rx/tx qlen for improving USB3 thoughtput
Date: Thu, 25 Jul 2013 13:47:54 +0800
Message-ID: <1374731274-27415-3-git-send-email-ming.lei@canonical.com>
References: <1374731274-27415-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:40805 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab3GYFsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 01:48:36 -0400
In-Reply-To: <1374731274-27415-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default RX_QLEN()/TX_QLEN() didn't consider susper speed
USB device, so only max 4 URBs are scheduled at the same time
for tx/rx, then USB3 NIC can't perform very well.

With this patch, both rx and tx thoughput are increased more than
100Mbps when doing iperf test on ax88179_178a USB 3.0 NIC.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/usbnet.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index d74de07..e4811d7 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -355,6 +355,15 @@ void usbnet_update_max_qlen(struct usbnet *dev)
 		dev->rx_qlen = MAX_QUEUE_MEMORY / dev->rx_urb_size;
 		dev->tx_qlen = MAX_QUEUE_MEMORY / dev->hard_mtu;
 		break;
+	case USB_SPEED_SUPER:
+		/*
+		 * Not take default 5ms qlen for super speed HC to
+		 * save memory, and iperf tests show 2.5ms qlen can
+		 * work well
+		 */
+		dev->rx_qlen = 5 * MAX_QUEUE_MEMORY / dev->rx_urb_size;
+		dev->tx_qlen = 5 * MAX_QUEUE_MEMORY / dev->hard_mtu;
+		break;
 	default:
 		dev->rx_qlen = dev->tx_qlen = 4;
 	}
-- 
1.7.9.5
