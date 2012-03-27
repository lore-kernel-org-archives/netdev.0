From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] cdc-phonet: fix skb truesize underestimation
Date: Tue, 27 Mar 2012 06:17:26 -0700
Message-ID: <1332854246.3248.18.camel@edumazet-laptop>
References: <1332853442.3248.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Felipe Balbi <balbi@ti.com>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:52367 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab2C0NRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 09:17:31 -0400
In-Reply-To: <1332853442.3248.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now skb_add_rx_frag() has a truesize parameter, we can fix cdc-phonet t=
o
properly account truesize of each fragment : a full page.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Felipe Balbi <balbi@ti.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/net/usb/cdc-phonet.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 3886b30..3e41b00 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -165,13 +165,13 @@ static void rx_complete(struct urb *req)
 				memcpy(skb_put(skb, 1), page_address(page), 1);
 				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
 						page, 1, req->actual_length,
-						req->actual_length);
+						PAGE_SIZE);
 				page =3D NULL;
 			}
 		} else {
 			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
 					page, 0, req->actual_length,
-					req->actual_length);
+					PAGE_SIZE);
 			page =3D NULL;
 		}
 		if (req->actual_length < PAGE_SIZE)
