From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/4] isdn/gigaset: drop unused cardstate structure member
Date: Fri, 3 Oct 2014 17:03:32 +0200
Message-ID: <7921bedda907d1c86948af143cd3e7aeaffad267.1412348612.git.tilman@imap.cc>
References: <cover.1412348612.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:41729 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753461AbaJCQ2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:28:19 -0400
In-Reply-To: <cover.1412348612.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Field int_in_endpointAddr was set but never used. Drop it.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 00d4077..8bda5c8 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -142,7 +142,6 @@ struct usb_cardstate {
 	unsigned char		*rcvbuf;
 	int			rcvbuf_size;
 	struct urb		*read_urb;
-	__u8			int_in_endpointAddr;
 
 	char			bchars[6];		/* for request 0x19 */
 };
@@ -741,7 +740,6 @@ static int gigaset_probe(struct usb_interface *interface,
 	}
 	buffer_size = le16_to_cpu(endpoint->wMaxPacketSize);
 	ucs->rcvbuf_size = buffer_size;
-	ucs->int_in_endpointAddr = endpoint->bEndpointAddress;
 	ucs->rcvbuf = kmalloc(buffer_size, GFP_KERNEL);
 	if (!ucs->rcvbuf) {
 		dev_err(cs->dev, "Couldn't allocate rcvbuf\n");
-- 
1.9.2.459.g68773ac
