From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 3/6] usbnet: allow mini-drivers to consume L2 headers
Date: Thu,  3 Dec 2015 19:24:20 +0100
Message-ID: <1449167063-22703-4-git-send-email-bjorn@mork.no>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:43204 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267AbbLCSZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 13:25:09 -0500
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assume the minidriver has taken care of all L2 header parsing
if it sets skb->protocol.  This allows the minidriver to
support non-ethernet L2 headers, and even operate without
any L2 header at all.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/usbnet.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 0744bf2ef2d6..0b0ba7ef14e4 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -324,7 +324,10 @@ void usbnet_skb_return (struct usbnet *dev, struct=
 sk_buff *skb)
 		return;
 	}
=20
-	skb->protocol =3D eth_type_trans (skb, dev->net);
+	/* only update if unset to allow minidriver rx_fixup override */
+	if (skb->protocol =3D=3D 0)
+		skb->protocol =3D eth_type_trans (skb, dev->net);
+
 	dev->net->stats.rx_packets++;
 	dev->net->stats.rx_bytes +=3D skb->len;
=20
--=20
2.1.4
