From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v3] net: #ifdef inet_bind_bucket::ib_net
Date: Fri, 14 Nov 2008 00:09:47 +0100
Message-ID: <491CB3BB.5030602@cosmosbay.com>
References: <b6fcc0a0811131453l4c111135p7b58453a533693ea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:37728 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbYKMXJ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 18:09:57 -0500
In-Reply-To: <b6fcc0a0811131453l4c111135p7b58453a533693ea@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :
> On Wed, Nov 12, 2008 at 04:24:23AM -0800, David Miller wrote:
>> From: Alexey Dobriyan <adobriyan@gmail.com>
>> Date: Wed, 12 Nov 2008 15:24:48 +0300
>>
>>> +static inline void ib_net_set(struct inet_bind_bucket *ib, struct =
net *net)
>>> +{
>>> +#ifdef CONFIG_NET_NS
>>> +   ib->ib_net =3D net;
>>> +#endif
>>> +}
>>> +
>> It's basically read_pnet() hidden behind another name.
>> And you'll add new "aliases" for read_pnet() over and over
>> again.
>>
>> That makes no sense to me.
>=20
> It also make no sense to expose write_pnet() for one(!) user and
> simultaneously hide read_pnet() under ib_net() as committed patches d=
o.
>=20
> Something is wrong with read_pnet() as nobody suggested to mass use i=
t
> or send a patch doing it.

I did. My plan is to zap all superflous #ifdef CONFIG_NET_NS if possibl=
e.


>=20
>=20
>         #ifdef CONFIG_NET_NS
>                 ib->ib_net =3D net;
>         #endif
>=20
> It's _obvious_ from this code that it's a C assignment or nop. It's a=
lso
> obvious depending on what config option.
>=20
>         write_pnet(&ib->ib_net, net);
>=20
> What is & operator doing here? Is it important? '&' is syntaxic noise=
=2E
>=20
> And netns assignments are exactly this: assigment or a nop.

You obviously didnt read my patches.

How do you want to implement a C function that can write to ib->ib_net =
?

Yes, I prefer a function over a macro, as most kernel developpers,
for obvious reasons.

Only sane way is :

static inline void write_pnet(struct net **pnet, struct net *net)
{
	*pnet =3D net;
}

and call write_pnet(&ip->ib_net, net);

Strange, this is what I did.

Take the time to read the patch, please.

Thank you

