From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net-next] usbnet: Fix tx_packets stat for FLAG_MULTI_FRAME drivers
Date: Fri, 27 Feb 2015 09:50:41 +0100
Message-ID: <87lhjj3fha.fsf@nemi.mork.no>
References: <1424979277.4444.39.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	ct-linux-kernel <linux-kernel-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1424979277.4444.39.camel-2NU49sBE5Aze9VDwLV8dzJPsBRI6B4nW9dF7HbQ/qKg@public.gmane.org> (Ben
	Hutchings's message of "Thu, 26 Feb 2015 19:34:37 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org> writes:

> Currently the usbnet core does not update the tx_packets statistic fo=
r
> drivers with FLAG_MULTI_PACKET and there is no hook in the TX
> completion path where they could do this.
>
> cdc_ncm and dependent drivers are bumping tx_packets stat on the
> transmit path while asix and sr9800 aren't updating it at all.
>
> Add a packet count in struct skb_data so these drivers can fill it
> in, initialise it to 1 for other drivers, and add the packet count
> to the tx_packets statistic on completion.
>
> Signed-off-by: Ben Hutchings <ben.hutchings-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
> ---
> I have only tested the asix driver after this change; I think cdc_ncm
> and one of the non-multi-packet drivers should also be tested before
> it's applied.

Looks very good to me.  I did a quick test with an MBIM device (the
cdc_mbim driver uses the parts of cdc_ncm you modify here), and it
worked as expected.

Thanks for doing this.  My only complaint was a wishlist for a similar
byte fixup, but then I noticed that you already did that :-)

Tested-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>



Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
