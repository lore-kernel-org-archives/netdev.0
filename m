From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 35/41] CAPI: Drop capiminor's unused inbytes counter
Date: Mon,  8 Feb 2010 21:12:39 +0100
Message-ID: <c2381f3c677d3c9b632e87d62e7963d0f62c7ba4.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:43445 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977Ab0BHUNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:15 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The inbytes counter was only updated but never read.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 08d5a8a..be85c8c 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -98,7 +98,6 @@ struct capiminor {
 	struct sk_buff    *ttyskb;
 
 	struct sk_buff_head inqueue;
-	int                 inbytes;
 	struct sk_buff_head outqueue;
 	int                 outbytes;
 
@@ -520,15 +519,12 @@ deref_tty:
 static void handle_minor_recv(struct capiminor *mp)
 {
 	struct sk_buff *skb;
-	while ((skb = skb_dequeue(&mp->inqueue)) != NULL) {
-		unsigned int len = skb->len;
-		mp->inbytes -= len;
+
+	while ((skb = skb_dequeue(&mp->inqueue)) != NULL)
 		if (handle_recv_skb(mp, skb) < 0) {
 			skb_queue_head(&mp->inqueue, skb);
-			mp->inbytes += len;
 			return;
 		}
-	}
 }
 
 static int handle_minor_send(struct capiminor *mp)
@@ -659,7 +655,7 @@ static void capi_recv_message(struct capi20_appl *ap, struct sk_buff *skb)
 				datahandle, skb->len-CAPIMSG_LEN(skb->data));
 #endif
 		skb_queue_tail(&mp->inqueue, skb);
-		mp->inbytes += skb->len;
+
 		handle_minor_recv(mp);
 
 	} else if (CAPIMSG_SUBCOMMAND(skb->data) == CAPI_CONF) {
-- 
1.6.0.2

