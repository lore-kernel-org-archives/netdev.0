From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Use skb_queue_walk_safe() in usbnet.
Date: Mon, 22 Sep 2008 20:19:43 -0700 (PDT)
Message-ID: <20080922.201943.05384322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38985
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754497AbYIWDTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 23:19:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 07D02C8C185
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 20:19:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


More work towards making sk_buff list_head transition easier.

usbnet: Use skb_queue_walk_safe() instead of by-hand implementation.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/usb/usbnet.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8463efb..02d25c7 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -512,14 +512,13 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 	int			count = 0;
 
 	spin_lock_irqsave (&q->lock, flags);
-	for (skb = q->next; skb != (struct sk_buff *) q; skb = skbnext) {
+	skb_queue_walk_safe(q, skb, skbnext) {
 		struct skb_data		*entry;
 		struct urb		*urb;
 		int			retval;
 
 		entry = (struct skb_data *) skb->cb;
 		urb = entry->urb;
-		skbnext = skb->next;
 
 		// during some PM-driven resume scenarios,
 		// these (async) unlinks complete immediately
-- 
1.5.6.5

