From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 14:08:59 +0300
Message-ID: <4CB441CB.2000708@cs.helsinki.fi>
References: <1286838210.30423.128.camel@edumazet-laptop>	<1286839363.30423.130.camel@edumazet-laptop>	<1286859925.30423.184.camel@edumazet-laptop>	<20101011230322.f0f6dd47.akpm@linux-foundation.org>	<1286866699.30423.234.camel@edumazet-laptop>	<20101012002435.f51f2c0e.akpm@linux-foundation.org>	<1286869793.2732.24.camel@edumazet-laptop> <20101012005856.994bea6d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Nick Piggin <npiggin@kernel.dk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101012005856.994bea6d.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/10 10:58 AM, Andrew Morton wrote:
> On Tue, 12 Oct 2010 09:49:53 +0200 Eric Dumazet<eric.dumazet@gmail.co=
m>  wrote:
>
>> Le mardi 12 octobre 2010 =E0 00:24 -0700, Andrew Morton a =E9crit :
>>
>>> I'd love to forget it, but it's faster for some things (I forget
>>> which).  Which is why it's still around.
>>
>> Yes, two years ago it was true on pathological/obscure cases.
>> Every time I did the comparison, SLUB won.
>> You asked me, I did yet another test this morning, and 40% is pretty
>> serious, I believe.
>>
>>> And the ghastly thing about this is that you're forced to care abou=
t it
>>> too because some people are, apparently, still using it.
>>
>> Yes, some people (in my company) still use linux 2.6.9 32bit on HP G=
6/G7
>> machines, I know...
>>
>> I am not saying we should not care, but for any serious network work=
load
>> on NUMA arches, SLUB is the best, and seeing Christoph recent work, =
it
>> might even get better.
>>
>> BTW, I believe all modern distros ship SLUB, dont they ?
>
> Dunno.
>
> Pekka, why haven't we deleted slab yet??

To make a long story short, we still have relevant performance=20
regressions that need to be taken care of. The most interesting one is =
a=20
regression in netperf TCP_RR that's been reported by David Rientjes a=20
while back. There's bunch of SLUB cleanups queued for 2.6.37 that pave=20
the way for Christoph's SLUB queueing work that should hopefully fix=20
that particular issue for 2.6.38.

There's little point in discussing the removal of SLAB as long as there=
=20
are performance regressions for real workloads from people who are=20
willing to share results and test patches. I'm optimistic that we'll be=
=20
able to try removing SLAB some time next year unless something=20
interesting pops up...

			Pekka
