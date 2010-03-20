From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] ip_gre: include route header_len in max_headroom calculation
Date: Sat, 20 Mar 2010 16:47:28 +0200
Message-ID: <4BA4E000.1030206@iki.fi>
References: <1269088078-7343-1-git-send-email-timo.teras@iki.fi> <20100320123736.GC1930@gondor.apana.org.au> <4BA4C2ED.9090701@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:60571 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539Ab0CTOr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 10:47:29 -0400
Received: by ewy8 with SMTP id 8so255822ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 07:47:28 -0700 (PDT)
In-Reply-To: <4BA4C2ED.9090701@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Sat, Mar 20, 2010 at 02:27:58PM +0200, Timo Teras wrote:
>>> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
>>> index f47c9f7..f78402d 100644
>>> --- a/net/ipv4/ip_gre.c
>>> +++ b/net/ipv4/ip_gre.c
>>> @@ -810,11 +810,13 @@ static netdev_tx_t ipgre_tunnel_xmit(struct=20
>>> sk_buff *skb, struct net_device *dev
>>>              tunnel->err_count =3D 0;
>>>      }
>>> =20
>>> -    max_headroom =3D LL_RESERVED_SPACE(tdev) + gre_hlen;
>>> +    max_headroom =3D LL_RESERVED_SPACE(tdev) + gre_hlen +=20
>>> rt->u.dst.header_len;
>>> =20
>>>      if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
>>>          (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
>>>          struct sk_buff *new_skb =3D skb_realloc_headroom(skb,=20
>>> max_headroom);
>>> +        if (max_headroom > dev->needed_headroom)
>>> +            dev->needed_headroom =3D max_headroom;
>>
>> Are you sure about this? LL_RESERVED_SPACE already includes
>> dev->needed_headroom so won't this get bigger each time?
>=20
> Whoops. Must've been after-midnight issue. And not noticed since the
> max_headroom won't change many times.
>=20
> dev->needed_headroom should be compared against=20
> gre_hlen+rt->u.dst.header_len.
> I'll send a fixed patch in a jiffy.

Actually, isn't the above right?

max_headroom is calculated with LL_RESERVED_SPACE of the tdev, which
is the interface to which the gre packet is being sent to, not the
gre interface. Thus, max_headroom won't include gre devices
previous needed_headroom.

- Timo
