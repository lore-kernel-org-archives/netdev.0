From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH v2] net: #ifdef inet_bind_bucket::ib_net
Date: Wed, 12 Nov 2008 11:50:29 +0100
Message-ID: <491AB4F5.2070206@cosmosbay.com>
References: <20081110.164424.167225199.davem@davemloft.net> <20081111110847.GC3665@x200.localdomain> <20081111111946.GD3665@x200.localdomain> <20081111.164554.143409564.davem@davemloft.net> <20081112104439.GA4292@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:50283 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbYKLKuh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:50:37 -0500
In-Reply-To: <20081112104439.GA4292@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan a =E9crit :
> On Tue, Nov 11, 2008 at 04:45:54PM -0800, David Miller wrote:
>> From: Alexey Dobriyan <adobriyan@gmail.com>
>> Date: Tue, 11 Nov 2008 14:19:46 +0300
>>
>>> @@ -35,7 +35,9 @@ struct inet_bind_bucket *inet_bind_bucket_create(=
struct kmem_cache *cachep,
>>>  	struct inet_bind_bucket *tb =3D kmem_cache_alloc(cachep, GFP_ATOM=
IC);
>>> =20
>>>  	if (tb !=3D NULL) {
>>> +#ifdef CONFIG_NET_NS
>>>  		tb->ib_net       =3D hold_net(net);
>>> +#endif
>>>  		tb->port      =3D snum;
>>>  		tb->fastreuse =3D 0;
>>>  		INIT_HLIST_HEAD(&tb->owners);
>> No, this is exactly what we don't want.
>>
>> If you have to add ifdefs to core C files, you're doing something
>> wrong.
>=20
> It depends.
>=20
>> All the details of ifdef this or ifdef that should be hidden in the
>> header files.
>=20
> It depends.
>=20
>> You cited an example where there are a ton of ifdefs in some header
>> fule inline function, but that is EXACTLY how this stuff should be
>> done.  Those header files are where such ugly implementation details
>> belong.
>>
>> When people read actual code, they should be concerning themselves
>> with control flow, what the code is trying to do, etc. rather then
>> being continually interrupted with ifdef this and ifdef that.
>=20
> On the other hand, people are interrupted with ctags jumping when sud=
denly
> whole new file appears, so loss of context is even more. Distance bet=
ween
> static inline pair tend to increase as people add more stuff in betwe=
en.
>=20
> And how this one line ifdef (in one place -- allocation) can interrup=
t
> control flow when you see it's start and immediately see it's end? Is=
 it
> because ifdef starts at column one, and code on average is two-three =
tabs
> indented, so eye jumps to column one?
>=20
> Whey you are suspicious of the code (say, look for a bug) these wrapp=
ers
> are nuisaince, because some very smart one may do completely unexpect=
ed
> thing wrt it's innocent name. And you check them all because you're
> suspicious.
>=20
> Netdevices use dev_net_set(). Add ib_net_set() and forget about this =
hungarian
> pnet thing. const qualifier is also pointless, there maybe nothing wr=
ong with
> it, be there is nothing right as well.
>=20
> Well, yes, Linus starts blogging and hungarian notation in core netwo=
rking. :-)

Take a look at include/net/net_namespace.h=20
I made my best to choose a notation and found :

copy_net_ns(), __put_net(), net_alive(), get_net(), maybe_get_net(),=20
put_net(), net_eq(), hold_net(), release_net()

What a mess.

I then decided to name my two helpers read_pnet() and write_pnet(), not
because I love hungarion notaion, but to keep existing practice in this
file.

I have no problem to clean the whole file and have a consistent notatio=
n.

I have no problem you take care of this.

Thank you

