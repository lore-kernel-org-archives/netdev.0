From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] net/usb/kalmia: use %*phC to dump small buffers
Date: Wed, 29 May 2013 10:22:30 +0300
Message-ID: <1369812150-27599-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11407 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964799Ab3E2HWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 03:22:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of dereferencing pointer and put values on stack we could use nice
%*phC specifier.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
Since v1:
- don't split message strings

 drivers/net/usb/kalmia.c | 45 +++++++++++++++------------------------------
 1 file changed, 15 insertions(+), 30 deletions(-)

diff --git a/drivers/net/usb/kalmia.c b/drivers/net/usb/kalmia.c
index 0192073..6866eae 100644
--- a/drivers/net/usb/kalmia.c
+++ b/drivers/net/usb/kalmia.c
@@ -221,12 +221,9 @@ done:
 		memset(skb_put(skb, padlen), 0, padlen);
 	}
 
-	netdev_dbg(
-		dev->net,
-		"Sending package with length %i and padding %i. Header: %02x:%02x:%02x:%02x:%02x:%02x.",
-		content_len, padlen, header_start[0], header_start[1],
-		header_start[2], header_start[3], header_start[4],
-		header_start[5]);
+	netdev_dbg(dev->net,
+		"Sending package with length %i and padding %i. Header: %6phC.",
+		content_len, padlen, header_start);
 
 	return skb;
 }
@@ -263,32 +260,23 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 				sizeof(EXPECTED_UNKNOWN_HEADER_1)) || !memcmp(
 				header_start, EXPECTED_UNKNOWN_HEADER_2,
 				sizeof(EXPECTED_UNKNOWN_HEADER_2))) {
-				netdev_dbg(
-					dev->net,
-					"Received expected unknown frame header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
-					header_start[0], header_start[1],
-					header_start[2], header_start[3],
-					header_start[4], header_start[5],
+				netdev_dbg(dev->net,
+					"Received expected unknown frame header: %6phC. Package length: %i\n",
+					header_start,
 					skb->len - KALMIA_HEADER_LENGTH);
 			}
 			else {
-				netdev_err(
-					dev->net,
-					"Received unknown frame header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
-					header_start[0], header_start[1],
-					header_start[2], header_start[3],
-					header_start[4], header_start[5],
+				netdev_err(dev->net,
+					"Received unknown frame header: %6phC. Package length: %i\n",
+					header_start,
 					skb->len - KALMIA_HEADER_LENGTH);
 				return 0;
 			}
 		}
 		else
-			netdev_dbg(
-				dev->net,
-				"Received header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
-				header_start[0], header_start[1], header_start[2],
-				header_start[3], header_start[4], header_start[5],
-				skb->len - KALMIA_HEADER_LENGTH);
+			netdev_dbg(dev->net,
+				"Received header: %6phC. Package length: %i\n",
+				header_start, skb->len - KALMIA_HEADER_LENGTH);
 
 		/* subtract start header and end header */
 		usb_packet_length = skb->len - (2 * KALMIA_HEADER_LENGTH);
@@ -310,12 +298,9 @@ kalmia_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 				sizeof(HEADER_END_OF_USB_PACKET)) == 0);
 			if (!is_last) {
 				header_start = skb->data + ether_packet_length;
-				netdev_dbg(
-					dev->net,
-					"End header: %02x:%02x:%02x:%02x:%02x:%02x. Package length: %i\n",
-					header_start[0], header_start[1],
-					header_start[2], header_start[3],
-					header_start[4], header_start[5],
+				netdev_dbg(dev->net,
+					"End header: %6phC. Package length: %i\n",
+					header_start,
 					skb->len - KALMIA_HEADER_LENGTH);
 			}
 		}
-- 
1.8.2.rc0.22.gb3600c3
