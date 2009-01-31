From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 10:49:00 +0100
Message-ID: <49841E8C.60401@cosmosbay.com>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com> <20090131093123.GA28151@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37075 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbZAaJtm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 04:49:42 -0500
In-Reply-To: <20090131093123.GA28151@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> On Sat, Jan 31, 2009 at 10:17:44AM +0100, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>>> getaddrinfo() returns list of addresses and IPv6 was the first one =
iirc.
>>> Previously it bailed out, but with my change it will try again with=
out
>>> reason for doing this. With the patch I sent based on Eric's observ=
ation
>>> things should be fine.
>> Problem is your patch is wrong Evgeniy, please think about it litle =
bit more
>> and resubmit it.=20
>=20
> No, patch should be ok. And its part which moves bsockets around was
> added because of your complaints, that it is written into read-mostly
> cache line. It is not a fix and has nothing with the problem at all.
>=20
>> Take the time to run this $0.02 program, before and after your upcom=
ing fix :
>=20
> It is not a fix, but enhancement, which really has nothing with the b=
ug
> in question :)
> Fix is to return an error if socket binding does not use the heuristi=
c.
>=20
>> offset of bsockets being 0x18 or 0x20 is same result : bad because i=
n
>> same cache line than ehash, ehash_locks, ehash_size, ehash_locks_mas=
k,
>> bhash, bhash_size, unless your cpu is a Pentium.
>=20
> Attached patch makes difference, I'm curious if it ever make any
> difference in the benchmarks.
>=20
>> Also, I suggest you change bsockets to something more appropriate, e=
g a
>> percpu counter.
>=20
> I thought on that first, but found that looping over every cpu and
> summing the total number of allocated/freed sockets will have noticeb=
ly
> bigger overhead than having loosely maintaned number of sockets.
>=20
> For the reference. This patch has nothing with the bug we discuss her=
e,
> the proper patch (without need to move bsockets around) was sent
> earlier, which forces port selection codepath to return error when ne=
w
> selection heuristic is not used.
>=20
> --- ./include/net/inet_hashtables.h.orig	2009-01-31 12:27:41.00000000=
0 +0300
> +++ ./include/net/inet_hashtables.h	2009-01-31 12:28:15.000000000 +03=
00
> @@ -134,7 +134,6 @@
>  	struct inet_bind_hashbucket	*bhash;
> =20
>  	unsigned int			bhash_size;
> -	int				bsockets;
> =20
>  	struct kmem_cache		*bind_bucket_cachep;
> =20
> @@ -150,6 +149,8 @@
>  	 */
>  	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
>  					____cacheline_aligned_in_smp;
> +=09
> +	int				bsockets ____cacheline_aligned_in_smp;
> =20
>  };
> =20
>=20


It appears you are always right, I have nothing to say then.

Stupid I am.

I vote for plain revert of your initial patch, since you are anaware
of performance problems it introduces. Then, probably nobody cares
of my complaints, so dont worry.


