From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] dst: check if dst is freed in dst_check()
Date: Tue, 20 Jul 2010 23:41:16 -0700 (PDT)
Message-ID: <20100720.234116.184416997.davem@davemloft.net>
References: <4C457120.9070105@6wind.com>
	<1279679288.2492.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51408
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762569Ab0GUGlA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jul 2010 02:41:00 -0400
In-Reply-To: <1279679288.2492.15.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Jul 2010 04:28:08 +0200

> Le mardi 20 juillet 2010 =E0 11:49 +0200, Nicolas Dichtel a =E9crit :
>> diff --git a/include/net/dst.h b/include/net/dst.h
>> index 81d1413..7bf4f9a 100644
>> --- a/include/net/dst.h
>> +++ b/include/net/dst.h
>> @@ -319,6 +319,8 @@ static inline int dst_input(struct sk_buff *skb)
>> =20
>>  static inline struct dst_entry *dst_check(struct dst_entry *dst, u3=
2 cookie)
>>  {
>> +	if (dst->obsolete > 1)
>> +		return NULL;
>>  	if (dst->obsolete)
>>  		dst =3D dst->ops->check(dst, cookie);
>>  	return dst;
>=20
> I believe this is not needed and redundant.
>=20
> In what case do you think this matters ?
>=20
> To my knowledge dst_check() is only used by net/xfrm/xfrm_policy.c
>=20
> And xfrm_dst_check() does the necessary checks.

Right, last time I was snooping around in here I came to the
same conclusion.  In fact I think I'm the author of that
enormous comment in xfrm_dst_check(). :-)


