From: David Miller <davem@davemloft.net>
Subject: [PATCH 14/42] isdn: gigaset: Fix set-but-unused variable.
Date: Sun, 17 Apr 2011 17:33:18 -0700 (PDT)
Message-ID: <20110417.173318.102547685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40563
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753886Ab1DRAdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 85EBF24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'offset' is set but unused in
write_iso_tasklet().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/gigaset/bas-gigaset.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 8a3c5cf..3913f47 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -1157,7 +1157,6 @@ static void write_iso_tasklet(unsigned long data)
 	struct urb *urb;
 	int status;
 	struct usb_iso_packet_descriptor *ifd;
-	int offset;
 	unsigned long flags;
 	int i;
 	struct sk_buff *skb;
@@ -1225,7 +1224,6 @@ static void write_iso_tasklet(unsigned long data)
 			 *   successfully sent
 			 * - all following frames are not sent at all
 			 */
-			offset = done->limit;	/* default (no error) */
 			for (i = 0; i < BAS_NUMFRAMES; i++) {
 				ifd = &urb->iso_frame_desc[i];
 				if (ifd->status ||
@@ -1235,9 +1233,6 @@ static void write_iso_tasklet(unsigned long data)
 						 i, ifd->actual_length,
 						 ifd->length,
 						 get_usb_statmsg(ifd->status));
-					offset = (ifd->offset +
-						  ifd->actual_length)
-						 % BAS_OUTBUFSIZE;
 					break;
 				}
 			}
-- 
1.7.4.3

