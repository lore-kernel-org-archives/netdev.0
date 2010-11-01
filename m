From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
Date: Mon, 1 Nov 2010 17:16:39 +0100
Message-ID: <AANLkTimMwTbj-2oP-VP7Ht1VnA8_w7vpTGz1kk5HG7zx@mail.gmail.com>
References: <1288253909-12084-1-git-send-email-mad_soft@inbox.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Dmitry Artamonow <mad_soft-aPYA7nAdAYY@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1288253909-12084-1-git-send-email-mad_soft-aPYA7nAdAYY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2010/10/28 Dmitry Artamonow <mad_soft-aPYA7nAdAYY@public.gmane.org>:
> Crash is triggered by commit e6484930d7 ("net: allocate tx queues in
> register_netdevice"), which moved tx netqueue creation into register_=
netdev.
> So now calling netif_stop_queue() before register_netdev causes an oo=
ps.
> Move netif_stop_queue() after net device registration to fix crash.
>
> Signed-off-by: Dmitry Artamonow <mad_soft-aPYA7nAdAYY@public.gmane.org>
> ---
> =A0drivers/usb/gadget/u_ether.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ethe=
r.c
> index 6bb876d..cb23355 100644
> --- a/drivers/usb/gadget/u_ether.c
> +++ b/drivers/usb/gadget/u_ether.c
> @@ -797,7 +797,6 @@ int gether_setup(struct usb_gadget *g, u8 ethaddr=
[ETH_ALEN])
> =A0 =A0 =A0 =A0 * =A0- iff DATA transfer is active, carrier is "on"
> =A0 =A0 =A0 =A0 * =A0- tx queueing enabled if open *and* carrier is "=
on"
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 netif_stop_queue(net);
> =A0 =A0 =A0 =A0netif_carrier_off(net);
>
> =A0 =A0 =A0 =A0dev->gadget =3D g;
> @@ -812,6 +811,7 @@ int gether_setup(struct usb_gadget *g, u8 ethaddr=
[ETH_ALEN])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INFO(dev, "MAC %pM\n", net->dev_addr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INFO(dev, "HOST MAC %pM\n", dev->host_=
mac);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0the_dev =3D dev;
> =A0 =A0 =A0 =A0}
>

What about a race between register_netdev() -> open() -> rest of
gether_setup() ? What is this netif_stop_queue() here needed for?

Best Regards,
Micha=B3 Miros=B3aw
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
