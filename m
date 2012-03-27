From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] f_phonet: fix skb truesize underestimation
Date: Tue, 27 Mar 2012 06:04:02 -0700
Message-ID: <1332853442.3248.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Now skb_add_rx_frag() has a truesize parameter, we can fix f_phonet to
properly account truesize of each fragment : a full page.

Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Cc: R=C3=A9mi Denis-Courmont <remi.denis-courmont-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
---
 drivers/usb/gadget/f_phonet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/usb/gadget/f_phonet.c b/drivers/usb/gadget/f_phone=
t.c
index 85a5ceb..965a629 100644
--- a/drivers/usb/gadget/f_phonet.c
+++ b/drivers/usb/gadget/f_phonet.c
@@ -345,7 +345,7 @@ static void pn_rx_complete(struct usb_ep *ep, struc=
t usb_request *req)
 		}
=20
 		skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
-				skb->len <=3D 1, req->actual, req->actual);
+				skb->len <=3D 1, req->actual, PAGE_SIZE);
 		page =3D NULL;
=20
 		if (req->actual < req->length) { /* Last fragment */


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
