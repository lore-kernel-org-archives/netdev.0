From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] isdn/bas_gigaset: use USB API functions rather than constants
Date: Sun, 17 Aug 2014 13:45:48 +0200
Message-ID: <53F095EC.4060009@imap.cc>
References: <20140817003120.GA11815@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: Himangi Saraogi <himangi774@gmail.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59962 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751159AbaHQLpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 07:45:50 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id 71F36211E0
	for <netdev@vger.kernel.org>; Sun, 17 Aug 2014 07:45:49 -0400 (EDT)
In-Reply-To: <20140817003120.GA11815@himangi-Dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 17.08.2014 um 02:31 schrieb Himangi Saraogi:
> This patch introduces the use of the function usb_endpoint_num.
>=20
> The Coccinelle semantic patch that makes these changes is as follows:
>=20
> @@ struct usb_endpoint_descriptor *epd; @@
>=20
> - (epd->bEndpointAddress & \(USB_ENDPOINT_NUMBER_MASK\|0x0f\))
> + usb_endpoint_num(epd)
>=20
> Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
Acked-by: Tilman Schmidt <tilman@imap.cc>

Thanks,
Tilman

> ---
>  drivers/isdn/gigaset/bas-gigaset.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigase=
t/bas-gigaset.c
> index b7ae0a0..aecec6d 100644
> --- a/drivers/isdn/gigaset/bas-gigaset.c
> +++ b/drivers/isdn/gigaset/bas-gigaset.c
> @@ -2365,7 +2365,7 @@ static int gigaset_probe(struct usb_interface *=
interface,
>  	endpoint =3D &hostif->endpoint[0].desc;
>  	usb_fill_int_urb(ucs->urb_int_in, udev,
>  			 usb_rcvintpipe(udev,
> -					(endpoint->bEndpointAddress) & 0x0f),
> +					usb_endpoint_num(endpoint)),
>  			 ucs->int_in_buf, IP_MSGSIZE, read_int_callback, cs,
>  			 endpoint->bInterval);
>  	rc =3D usb_submit_urb(ucs->urb_int_in, GFP_KERNEL);
>=20

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
