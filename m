From: Alexey ORISHKO <alexey.orishko@stericsson.com>
Subject: RE: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 18:59:05 +0100
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520154A8EE17D8E@EXDCVYMBSTM006.EQ1STM.local>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
 <87r4ley6g9.fsf@nemi.mork.no> <87mww2y4ni.fsf@nemi.mork.no>
 <2214944.HMNV73jJm5@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	Greg Suarez <gsuarez@smithmicro.com>
To: Oliver Neukum <oneukum@suse.de>,
	=?iso-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:54410 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751635Ab3AUSAF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 13:00:05 -0500
In-Reply-To: <2214944.HMNV73jJm5@linux-5eaq.site>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Oliver Neukum [mailto:oneukum@suse.de]
> On Monday 21 January 2013 15:47:13 Bj=F8rn Mork wrote:
> > But I wonder if this isn't really a generic problem in usbnet.  The
> > FLAG_MULTI_PACKET test here seems completely bogus:
> >
> >         if (length % dev->maxpacket =3D=3D 0) {
> >                 if (!(info->flags & FLAG_SEND_ZLP)) {
> >                         if (!(info->flags & FLAG_MULTI_PACKET)) {
> >                                 urb->transfer_buffer_length++;
> >                                 if (skb_tailroom(skb)) {
> >                                         skb->data[skb->len] =3D 0;
> >                                         __skb_put(skb, 1);
> >                                 }
> >                         }
> >                 } else
> >                         urb->transfer_flags |=3D URB_ZERO_PACKET;
> >         }
> >
> > Either the FLAG_MULTI_PACKET minidriver will have already padded th=
e
> > buffer so that we do not hit (length % dev->maxpacket =3D=3D 0), or=
 we
> > should choose one of the alternatives: ZLP or padding.
>=20
> But we cannot simply call __skb_put for a complicated data frame.
> Besides you may want the current behavior.
>=20

Specification says:=20
NCM/MBIM shall not send ZLP if buffer size is dwNtbOutMaxSize.

The problem is:=20
dwNtbOutMaxSize value is negotiated between host and device NCM/MBIM
entities and usbnet has no knowledge about it.

Adding one byte to make buffer looking like a short packet was most
simple approach instead of inventing a way to communicate=20
dwNtbOutMaxSize to usbnet.

You could drop short packet approach if dwNtbOutMaxSize is provided
to usbnet and decision is made accordingly to NCM/MBIM spec (with
exception to faulty devices).

Regards,
Alexey
