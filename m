From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Thu, 05 Nov 2009 16:07:25 +0100
Message-ID: <4AF2EA2D.6040301@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com> <200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com> <877hu5892g.fsf@basil.nowhere.org> <4AF2CCD9.7010507@gmail.com> <20091105145428.GS31511@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57124 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbZKEPHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 10:07:25 -0500
In-Reply-To: <20091105145428.GS31511@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
>> I assume cache is cold or even on other cpu (worst case), dealing wi=
th
>> 100.000+ sockets or so...
>=20
> Other CPU cache hit is actually typically significantly=20
> faster than a DRAM access (unless you're talking about a very large N=
UMA=20
> system and a remote CPU far away)

Even if data is dirty in remote CPU cache ?=20

I dont speak of shared data. (if data is shared, workload mostly fits c=
aches)

>> If workload fits in one CPU cache/registers, we dont mind taking one
>> or two cache lines per object, obviously.
>=20
> It's more like part of your workload needs to fit.
>=20
> For example if you use a tree and the higher levels fit into
> the cache, having a few levels in the tree is (approximately) free.
>=20
> That's why I'm not always fond of large hash tables. They pretty
> much guarantee a lot of cache misses under high load, because
> they have little locality.

We already had this discussion Andi, and you know some servers handle 1=
=2E000.000+
sockets, 100.000+ frames per second on XX.XXX different flows, and a bi=
nary tree
means 20 accesses before target. Only 5 or 6 first levels are in cache.
Machine is barely usable.

hash table with 2.000.000 slots gives one or two accesses before target=
,
and rcu is trivial with hash tables.

btree are ok for generalist workloads, and rcu is more complex.

