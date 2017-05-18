From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] cdc-ether: divorce initialisation with a filter reset and a generic method
Date: Thu, 18 May 2017 12:09:11 +0200
Message-ID: <8737c2eat4.fsf@miraculix.mork.no>
References: <20170518082328.10094-1-oneukum@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60509 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755194AbdERKK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 06:10:29 -0400
In-Reply-To: <20170518082328.10094-1-oneukum@suse.com> (Oliver Neukum's
        message of "Thu, 18 May 2017 10:23:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.com> writes:

> @@ -417,7 +434,7 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_in=
terface *intf)
>  	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data)
>  			< sizeof(struct cdc_state)));
>=20=20
> -	status =3D usbnet_generic_cdc_bind(dev, intf);
> +	status =3D usbnet_ether_cdc_bind(dev, intf);
>  	if (status < 0)
>  		return status;
>=20=20
> @@ -472,7 +489,6 @@ static void usbnet_cdc_zte_status(struct usbnet *dev,=
 struct urb *urb)
>=20=20
>  	if (urb->actual_length < sizeof(*event))
>  		return;
> -
>  	event =3D urb->transfer_buffer;
>=20=20
>  	if (event->bNotificationType !=3D USB_CDC_NOTIFY_NETWORK_CONNECTION) {
> @@ -493,7 +509,7 @@ static void usbnet_cdc_zte_status(struct usbnet *dev,=
 struct urb *urb)
>  static const struct driver_info	cdc_info =3D {
>  	.description =3D	"CDC Ethernet Device",
>  	.flags =3D	FLAG_ETHER | FLAG_POINTTOPOINT,
> -	.bind =3D		usbnet_cdc_bind,
> +	.bind =3D		usbnet_ether_cdc_bind,
>  	.unbind =3D	usbnet_cdc_unbind,
>  	.status =3D	usbnet_cdc_status,
>  	.set_rx_mode =3D	usbnet_cdc_update_filter,


I didn't quite get this.  You change the call in usbnet_cdc_bind() from
usbnet_generic_cdc_bind() to usbnet_ether_cdc_bind(), which I believe is
fine.  But then you update the .bind hook to point to usbnet_ether_cdc_bind.
Why?  The only effect I can see is that usbnet_get_ethernet_addr() is
skipped. That can't be correct?


Bj=C3=B8rn
