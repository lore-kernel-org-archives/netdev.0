From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Linux Route Cache performance tests
Date: Mon, 7 Nov 2011 13:42:44 +0000
Message-ID: <1320673364.3020.21.camel@bwh-desktop>
References: <4EB6AE62.5050803@itcare.pl>
	 <1320600597.6506.7.camel@edumazet-laptop> <4EB6D1D8.8040604@itcare.pl>
	 <1320605326.6506.27.camel@edumazet-laptop> <4EB6DE06.7050009@itcare.pl>
	 <1320608290.6506.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18826 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394Ab1KGNmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 08:42:49 -0500
In-Reply-To: <1320608290.6506.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-11-06 at 20:38 +0100, Eric Dumazet wrote:
> Le dimanche 06 novembre 2011 =C3=A0 20:20 +0100, Pawe=C5=82 Staszewsk=
i a =C3=A9crit :
[...]
> > So the point of this test was figure out how much of route cache en=
tries=20
> > Linux can handle without dropping performance.
>=20
> No need to even do a bench, its pretty easy to understand how a hash
> table is handled.
>=20
> Allowing long chains is not good.
>=20
> With your 512k slots hash table, you cannot expect handling 1.4M rout=
es
> with optimal performance. End of story.
>=20
> Since route hash table is allocated at boot time, only way to change =
its
> size is using "rhash_entries=3D2097152" boot parameter.
>=20
> If it still doesnt fly, try with "rhash_entries=3D4194304"

A routing cache this big is not going to fit in the processor caches,
anyway; in fact even the hash table may not.  So a routing cache hit is
likely to involve processor cache misses.  After David's work to make
cacheless operation faster, I suspect that such a 'hit' can be a net
loss.  But it *is* necessary to run a benchmark to answer this (and the
answer will obviously vary between systems).

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
