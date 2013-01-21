From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: cdc_ncm: workaround for missing CDC Union
Date: Mon, 21 Jan 2013 16:28:48 +0100
Message-ID: <87ip6qy2q7.fsf@nemi.mork.no>
References: <1358519147-10073-1-git-send-email-bjorn@mork.no>
	<87r4ley6g9.fsf@nemi.mork.no> <87mww2y4ni.fsf@nemi.mork.no>
	<2214944.HMNV73jJm5@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Orishko <alexey.orishko@gmail.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Greg Suarez <gsuarez@smithmicro.com>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39243 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932065Ab3AUP3k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 10:29:40 -0500
In-Reply-To: <2214944.HMNV73jJm5@linux-5eaq.site> (Oliver Neukum's message of
	"Mon, 21 Jan 2013 15:55:05 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oneukum@suse.de> writes:
> On Monday 21 January 2013 15:47:13 Bj=C3=B8rn Mork wrote:
>> But I wonder if this isn't really a generic problem in usbnet.  The
>> FLAG_MULTI_PACKET test here seems completely bogus:
>>=20
>>         if (length % dev->maxpacket =3D=3D 0) {
>>                 if (!(info->flags & FLAG_SEND_ZLP)) {
>>                         if (!(info->flags & FLAG_MULTI_PACKET)) {
>>                                 urb->transfer_buffer_length++;
>>                                 if (skb_tailroom(skb)) {
>>                                         skb->data[skb->len] =3D 0;
>>                                         __skb_put(skb, 1);
>>                                 }
>>                         }
>>                 } else
>>                         urb->transfer_flags |=3D URB_ZERO_PACKET;
>>         }
>>=20
>> Either the FLAG_MULTI_PACKET minidriver will have already padded the
>> buffer so that we do not hit (length % dev->maxpacket =3D=3D 0), or =
we
>> should choose one of the alternatives: ZLP or padding.
>
> But we cannot simply call __skb_put for a complicated data frame.

Agreed.  But I believe the condition should be=20

 if (!(info->flags & FLAG_SEND_ZLP) && !(info->flags & FLAG_MULTI_PACKE=
T)) {
     ..
 } else {
     urb->transfer_flags |=3D URB_ZERO_PACKET;
 }

to ensure that we send the ZLP in this case.

> Besides you may want the current behavior.

Why? Does it ever make sense to prevent both the short packet and the
ZLP?


Bj=C3=B8rn
