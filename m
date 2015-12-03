From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 3/6] usbnet: allow mini-drivers to consume L2 headers
Date: Thu, 03 Dec 2015 21:03:54 +0100
Message-ID: <1449173034.4355.0.camel@suse.com>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
	 <1449167063-22703-4-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Aleksander Morgado <aleksander@aleksander.es>,
	Marcel Holtmann <marcel@holtmann.org>,
	Dan Williams <dcbw@redhat.com>, linux-usb@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55593 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753294AbbLCUFv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 15:05:51 -0500
In-Reply-To: <1449167063-22703-4-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-12-03 at 19:24 +0100, Bj=C3=B8rn Mork wrote:
> Assume the minidriver has taken care of all L2 header parsing
> if it sets skb->protocol.  This allows the minidriver to
> support non-ethernet L2 headers, and even operate without
> any L2 header at all.
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
Acked-by: Oliver Neukum <oneukum@suse.com>
> ---
>  drivers/net/usb/usbnet.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 0744bf2ef2d6..0b0ba7ef14e4 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -324,7 +324,10 @@ void usbnet_skb_return (struct usbnet *dev, stru=
ct sk_buff *skb)
>  		return;
>  	}
> =20
> -	skb->protocol =3D eth_type_trans (skb, dev->net);
> +	/* only update if unset to allow minidriver rx_fixup override */
> +	if (skb->protocol =3D=3D 0)
> +		skb->protocol =3D eth_type_trans (skb, dev->net);
> +
>  	dev->net->stats.rx_packets++;
>  	dev->net->stats.rx_bytes +=3D skb->len;
> =20
