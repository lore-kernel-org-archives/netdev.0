From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] isdn/gigaset: use USB API functions rather than constants
Date: Sat, 16 Aug 2014 12:54:15 +0200
Message-ID: <53EF3857.1070000@imap.cc>
References: <20140815162412.GA7192@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net,
	Julia Lawall <julia.lawall@lip6.fr>
To: Himangi Saraogi <himangi774@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140815162412.GA7192@himangi-Dell>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 15.08.2014 um 18:24 schrieb Himangi Saraogi:
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

Nice.
Are you planning a similar patch for bas-gigaset.c too?
Otherwise I'll prepare one myself.

Thanks,
Tilman


> ---
>  drivers/isdn/gigaset/usb-gigaset.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigase=
t/usb-gigaset.c
> index d0a41cb..00d4077 100644
> --- a/drivers/isdn/gigaset/usb-gigaset.c
> +++ b/drivers/isdn/gigaset/usb-gigaset.c
> @@ -751,7 +751,7 @@ static int gigaset_probe(struct usb_interface *in=
terface,
>  	/* Fill the interrupt urb and send it to the core */
>  	usb_fill_int_urb(ucs->read_urb, udev,
>  			 usb_rcvintpipe(udev,
> -					endpoint->bEndpointAddress & 0x0f),
> +					usb_endpoint_num(endpoint)),
>  			 ucs->rcvbuf, buffer_size,
>  			 gigaset_read_int_callback,
>  			 cs, endpoint->bInterval);
>=20

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
