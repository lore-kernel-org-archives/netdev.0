From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] udp_diag: Fix the !ipv6 case
Date: Sat, 10 Dec 2011 13:15:55 -0500 (EST)
Message-ID: <20111210.131555.2025649575447940902.davem@davemloft.net>
References: <4EE32777.2030003@parallels.com>
	<4EE327CB.4040505@parallels.com>
	<1323514931.4016.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785Ab1LJSP7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 13:15:59 -0500
In-Reply-To: <1323514931.4016.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Dec 2011 12:02:11 +0100

> Le samedi 10 d=E9cembre 2011 =E0 13:35 +0400, Pavel Emelyanov a =E9cr=
it :
>> Wrap the udp6 lookup into the proper ifdef-s.
>>=20
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>>=20
>> ---
>>=20
>> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
>> index 6506344..df7f960 100644
>> --- a/net/ipv4/udp_diag.c
>> +++ b/net/ipv4/udp_diag.c
>> @@ -41,6 +41,7 @@ static int udp_dump_one(struct udp_table *tbl, str=
uct sk_buff *in_skb,
>>  				req->id.idiag_src[0], req->id.idiag_sport,
>>  				req->id.idiag_dst[0], req->id.idiag_dport,
>>  				req->id.idiag_if, tbl);
>> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
>=20
> strange space after second 'defined' ;)
>=20
> By the way, we can now use :
>=20
> #if IS_ENABLED(CONFIG_IPV6)

I applied this patch, changing it to use IS_ENABLED() along the way.

Thanks.
