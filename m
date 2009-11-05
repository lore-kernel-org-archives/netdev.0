From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including
 destination address in the hash key
Date: Thu, 05 Nov 2009 14:02:17 +0100
Message-ID: <4AF2CCD9.7010507@gmail.com>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com>	<200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com> <877hu5892g.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36866 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbZKENCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 08:02:17 -0500
In-Reply-To: <877hu5892g.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>> I have struct reorderings in progress to reduce number of cache line=
s read
>> per socket from two to one. So this would reduce by 50% time to find
>> a particular socket in the chain.
>=20
> Assuming that each access takes equal time seems like a rather dubiou=
s
> assumption. Consider caches.

Yes, and it depends on SMP affinities too.

I assume cache is cold or even on other cpu (worst case), dealing with
100.000+ sockets or so...

If workload fits in one CPU cache/registers, we dont mind taking one
or two cache lines per object, obviously.


