From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dm9601: HW header size shouldn't be included in packet length
Date: Wed, 27 Jun 2007 08:14:50 +0200
Message-ID: <873b0dgbz9.fsf@p4.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:49478 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759163AbXF0GeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 02:34:25 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4017.mobistarmail.be (SMTP Server) with ESMTP id D289170000A0
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 08:14:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dm9601 driver was including the 2 byte hardware header in the
packet length, causing the HW to send 2 extra bytes of garbage on tx.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

---
 drivers/net/usb/dm9601.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc6/drivers/net/usb/dm9601.c
===================================================================
--- linux-2.6.22-rc6.orig/drivers/net/usb/dm9601.c
+++ linux-2.6.22-rc6/drivers/net/usb/dm9601.c
@@ -489,6 +489,8 @@
 	   b3..n: packet data
 	*/
 
+	len = skb->len;
+
 	if (skb_headroom(skb) < DM_TX_OVERHEAD) {
 		struct sk_buff *skb2;
 
@@ -501,10 +503,9 @@
 
 	__skb_push(skb, DM_TX_OVERHEAD);
 
-	len = skb->len;
 	/* usbnet adds padding if length is a multiple of packet size
 	   if so, adjust length value in header */
-	if ((len % dev->maxpacket) == 0)
+	if ((skb->len % dev->maxpacket) == 0)
 		len++;
 
 	skb->data[0] = len;

-- 
Bye, Peter Korsgaard

