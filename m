From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Wed, 31 Oct 2007 18:51:54 -0600
Message-ID: <m1wst2hjo5.fsf@ebiederm.dsl.xmission.com>
References: <4728D54F.2080208@openvz.org>
	<20071031194924.2436843e.dada1@cosmosbay.com>
	<m1hck7hrd1.fsf@ebiederm.dsl.xmission.com>
	<4729047B.3080003@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49740 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbXKAAx2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 20:53:28 -0400
In-Reply-To: <4729047B.3080003@cosmosbay.com> (Eric Dumazet's message of "Wed,
	31 Oct 2007 23:40:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:

> Eric W. Biederman a =E9crit :
>> Eric Dumazet <dada1@cosmosbay.com> writes:
>>
>>
>>> Definitly wanted here. Thank you.
>>> One more refcounting on each socket creation/deletion was expensive=
=2E
>>
>> Really?  Have you actually measured that?  If the overhead is
>> measurable and expensive we may want to look at per cpu counters or
>> something like that.  So far I don't have any numbers that say any
>> of the network namespace work inherently has any overhead.
>
> It seems that on some old opterons (two 246 for example),
> "if (atomic_dec_and_test(&net->count))" is rather expensive yes :(

I won't argue that atomic_dec_and_test is costly.  My gut feel is that
socket creation/destruction is sufficiently rare that such a test
would be lost in the noise.  Doing anything more sophisticated is
likely to be less readable, and unless we can measure some overhead
my preference right now is to keep the code stupid and simple.  Which
usually has a good icache footprint.

> I am not sure per cpu counters help : I tried this and got no speedup=
=2E (This was
> on net_device refcnt at that time)
>
> (on this machines, the access through fs/gs selector seems expensive =
too)
>
> Maybe a lazy mode could be done, ie only do a atomic_dec(), as done i=
n dev_put()
> ?
>
> Also, "count" sits in a cache line that contains mostly read and shar=
ed fields,
> you might want to put it in a separate cache line in SMP, to avoid ca=
che line
> ping-pongs.

As for cache lines I could reverse the order 'list' and 'work' which
should split the read-only and the writable fields in practice for
that part of the structure.

Eric
