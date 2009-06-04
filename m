From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] hso: convert dev_alloc_skb() to netdev_alloc_skb()
Date: Thu, 04 Jun 2009 18:50:29 +0300
Message-ID: <20090604155029.6660.14235.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:34269 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754094AbZFDPu3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 11:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---

 drivers/net/usb/hso.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 1064dda..61b4d7c 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -899,15 +899,14 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 					continue;
 				}
 				/* Allocate an sk_buff */
-				odev->skb_rx_buf = dev_alloc_skb(frame_len);
+				odev->skb_rx_buf = netdev_alloc_skb(odev->net,
+								    frame_len);
 				if (!odev->skb_rx_buf) {
 					/* We got no receive buffer. */
 					D1("could not allocate memory");
 					odev->rx_parse_state = WAIT_SYNC;
 					return;
 				}
-				/* Here's where it came from */
-				odev->skb_rx_buf->dev = odev->net;
 
 				/* Copy what we got so far. make room for iphdr
 				 * after tail. */

