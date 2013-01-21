From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 15:55:05 +0100
Message-ID: <2214944.HMNV73jJm5@linux-5eaq.site>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no> <87r4ley6g9.fsf@nemi.mork.no> <87mww2y4ni.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	Alexey Orishko <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87mww2y4ni.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 21 January 2013 15:47:13 Bj=F8rn Mork wrote:
> But I wonder if this isn't really a generic problem in usbnet.  The
> FLAG_MULTI_PACKET test here seems completely bogus:
>=20
>         if (length % dev->maxpacket =3D=3D 0) {
>                 if (!(info->flags & FLAG_SEND_ZLP)) {
>                         if (!(info->flags & FLAG_MULTI_PACKET)) {
>                                 urb->transfer_buffer_length++;
>                                 if (skb_tailroom(skb)) {
>                                         skb->data[skb->len] =3D 0;
>                                         __skb_put(skb, 1);
>                                 }
>                         }
>                 } else
>                         urb->transfer_flags |=3D URB_ZERO_PACKET;
>         }
>=20
> Either the FLAG_MULTI_PACKET minidriver will have already padded the
> buffer so that we do not hit (length % dev->maxpacket =3D=3D 0), or w=
e
> should choose one of the alternatives: ZLP or padding.

But we cannot simply call __skb_put for a complicated data frame.
Besides you may want the current behavior.

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
