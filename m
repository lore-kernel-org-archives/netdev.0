From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 11:44:43 -0400
Message-ID: <4BD7066B.9070507@athenacr.com>
References: <alpine.DEB.1.00.1004222249400.27016@pokey.mtv.corp.google.com>	 <1272302434.19143.76.camel@edumazet-laptop>	 <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>	 <20100426.110432.104061817.davem@davemloft.net>	 <4BD6E887.3000804@athenacr.com> <1272378659.2295.193.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:8154 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754811Ab0D0Poq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 11:44:46 -0400
In-Reply-To: <1272378659.2295.193.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mardi 27 avril 2010 =C3=A0 09:37 -0400, Brian Bloniarz a =C3=A9cri=
t :
>> David Miller wrote:
>>> How damn hard is it to add two 16-bit ports to the hash regardless =
of
>>> protocol?
>>>  =20
>> Come to think of it, for UDP the hash must ignore
>> the srcport and srcaddr, because a single bound
>> socket is going to wildcard both those fields.
>>
>=20
> For your application maybe ;)
>=20
> Here, I have thousand of RTP flows to big mediagateways, so the
> (srcaddr, dstaddr) is shared by all these flows.
>=20
> Tom Herbert also wants a threaded DNS server.
>=20
> For UDP, we could have a bitmap (system level ?) to say if a particul=
ar
> destination port wants multi-cpu (RPS) spreading or not, even if the =
NIC
> decided to use a single queue to submit frames to the host (ie mask t=
he
> src_addr and src_port). In this case, RFS on non conected UDP sockets
> could be activated as well.
>=20
> Or just a global sysctl to be able to mask the src_addr and/or src_po=
rt
> in our software rxhash.

This is all good to know. Here are 3 other alternatives/suggestions:

1) Leave things as they are, if it really hurts that badly
for our workload we can just disable RPS entirely.
2) Add a global sysctl to disable RPS for datagram-based protocols.
3) Pluggable SW rxhashes :)

I haven't benchmarked anything for our workloads yet, so
I can't say for sure it's even a big issue.

Has anyone benchmarked RPS + single-threaded DNS servers? It'd
be a pessimization in that case, right? Even the multi-threaded
DNS server wouldn't be workable unless there was something like
the soreuseport patch you & Tom had been been discussing.
