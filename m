From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: RFC: [PATCH 3/3] usb: cdc_ncm: MirrorLink booster for N60x,70x
Date: Sat, 09 Mar 2013 12:22:42 +0100
Message-ID: <87fw04es1p.fsf@nemi.mork.no>
References: <20130308210324.GA4796@feynman.loic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Loic Domaigne <loic.domaigne-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130308210324.GA4796-z50qq5H0jwZ76vs/tkv/CQ@public.gmane.org> (Loic Domaigne's message
	of "Fri, 8 Mar 2013 22:03:24 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Loic Domaigne <loic.domaigne-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org> writes:

> This patch allows to boost the performance if used for MirrorLink(TM)=
=2E It
> is derived from a patch provided by Nokia-LC/Berlin. It optimizes the=
 transfer
> speed for the Nokia N60x,70x. which requires special settings (jumbo =
frame,=20
> no batching)

This could probably be reworked to a real device specific quirk if
necessary.  But it will need some refinement and justification.

> +			/* The Nokia N60x,70x (productId 0x1419) needs:
> +			 * - Jumbo Frame (MTU 8kB)
> +			 * - Disable TX batching to improve latency
> +			 */
> +			if (dev !=3D NULL)
> +				/* called during NCM bind */
> +				dev->hard_mtu =3D 8192+ETH_HLEN;
> +			else {
> +				/* called during NCM setup */
> +				pr_info(KBUILD_MODNAME ":  jambit MirrorLink booster for "
> +					"Nokia 60x,70x family");
> +				ctx->tx_max_datagrams  =3D 1;
> +				ctx->max_datagram_size =3D 8192+ETH_HLEN;
> +			}

This looks really strange to me at first glance.  An important part of
the NCM protocol is the ability for the host to request these values
from the device, and the only real point of using NCM in the first plac=
e
is the bundling.  If the device has higher performance without bundling=
,
then why the h is it using NCM?

And if it really wants jumbo datagrams, then why doesn't it say so when
the driver ask?

Are the above values based on some perceived performance, or are there
actual measurements behind this?   Yes, sure the latency will drop with
no bundling, but that is sort of the trade-off you chose when you chose
NCM...

> @@ -1269,5 +1320,7 @@ module_exit(cdc_ncm_exit);
>  #endif
> =20
>  MODULE_AUTHOR("Hans Petter Selasky");
> +MODULE_AUTHOR("Loic Domaigne");
>  MODULE_DESCRIPTION("USB CDC NCM host driver");
> +MODULE_DESCRIPTION("MirrorLink Booster by jambit GmbH");
>  MODULE_LICENSE("Dual BSD/GPL");

I do not think this is appropriate at all for a device specific bug
workaround...


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
