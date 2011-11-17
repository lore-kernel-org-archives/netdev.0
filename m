From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] f_phonet: fix page offset of first received fragment
Date: Thu, 17 Nov 2011 14:58:55 +0200
Message-ID: <1321534735-9949-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:53560 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757275Ab1KQNGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 08:06:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

We pull one byte (the MAC header) from the first fragment before the
fragment is actually appended. So the socket buffer length is 1, not 0.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/usb/gadget/f_phonet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index 3490770..16a509a 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -346,7 +346,7 @@ static void pn_rx_complete(struct usb_ep *ep, struc=
t usb_request *req)
 		}
=20
 		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
-				skb->len =3D=3D 0, req->actual);
+				skb->len <=3D 1, req->actual);
 		page =3D NULL;
=20
 		if (req->actual < req->length) { /* Last fragment */
--=20
1.7.5.4
