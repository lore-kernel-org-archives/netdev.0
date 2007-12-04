From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Mon, 03 Dec 2007 19:14:26 -0500
Message-ID: <47549BE2.9080605@redhat.com>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com> <20071201122120.GB14368@gondor.apana.org.au> <47515CCF.3030009@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: Eric Dumazet <dada1@cosmosbay.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750723AbXLDARP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 19:17:15 -0500
In-Reply-To: <47515CCF.3030009@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Herbert Xu a =E9crit :
>> However, I'm still a little concerned about the effect of two more
>> atomic op's per packet that we're adding here.  Hang on a sec, that
>> should've been Dave's line since atomic ops are cheap on x86 :)
>>
>> But seriously, it's not so much that we have two more atomic op's
>> per packet, but we have two more writes to a single global counter
>> for each packet.  This is going to really suck on SMP.
>>
>> So what I'd like to see is a scheme that's similar to sk_forward_all=
oc.
>> The idea is that each socket allocates memory using mem_schedule and
>> then stores it in sk_forward_alloc.  Each packet then only has to
>> add to/subtract from sk_forward_alloc.
>>
>> There is one big problem with this though, UDP is not serialised lik=
e
>> TCP.  So you can't just use sk_forward_alloc since it's not an atomi=
c_t.
>>
>> We'll need to think about this one a bit more.
>=20
> I agree adding yet another atomics ops is a big problem.
>=20
> Another idea, coupled with recent work on percpu storage done by
> Christoph Lameter, would be to use kind of a percpu_counter :
>=20
> We dont really need strong and precise memory accounting (UDP , but T=
CP
> as well), just some kind of limit to avoid memory to be too much used=
=2E
>=20
> That is, updating a percpu variable, and doing some updates to a glob=
al
> counter only when this percpu variable escapes from a given range.
>=20
> Lot of contended cache lines could benefit from this relaxing (count =
of
> sockets...)
>=20
> I would wait first that Christoph work is done, so that we dont need
> atomic ops on local cpu storage (and no need to disable preemption to=
o).

Thank you for your comments.
I understood your concern of atomic operations.

Let me try to use sk_forward_alloc at first, while percpu storage
is an interesting idea.

Many thanks,
Hideo

--=20
Hitachi Computer Products (America) Inc.

