From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Very low latency TCP for clusters
Date: Tue, 20 Jul 2010 08:57:38 -0400
Message-ID: <4C459D42.2060402@athenacr.com>
References: <AANLkTilNmNZbFWS8LF-UHU65QYIC32HZlgVZ7lXJHxPh@mail.gmail.com>	<1279561319.2553.153.camel@edumazet-laptop>	<AANLkTiniRmnwG4vT-MrQQHQjrdQ4sfOn6Uxi42Dsr8nu@mail.gmail.com>	<1279576980.2458.56.camel@edumazet-laptop> <AANLkTillCVWMHHBImGEeRYy2MJYqtGIvSPvacLKJnpP2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:23063 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932155Ab0GTM5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 08:57:42 -0400
In-Reply-To: <AANLkTillCVWMHHBImGEeRYy2MJYqtGIvSPvacLKJnpP2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> On Mon, Jul 19, 2010 at 3:03 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le lundi 19 juillet 2010 =E0 11:44 -0700, Tom Herbert a =E9crit :
>>
>>> I see about 7 usecs as best number on loopback, so I believe this i=
s
>>> in the ballpark.  As I mentioned above, this about "best case" late=
ncy
>>> of a single thread, so we assume any amount of pinning or other
>>> customized configuration to that purpose.
>> Well, given I get 29 us on a ping between two machines (Gb link, no
>> process involved on receiver, only softirq), I really doubt we can r=
each
>> 5 us on a tcp test involving a user process on both side ;)
>>
> That's pretty pokey ;-) I see numbers around 25 usecs between to
> machines, this is with TCP_NBRR.  With TCP_RR it's more like 35 usecs=
,
> so eliminating the scheduler is already a big reduction.  That leaves
> 18 usecs in device time, interrupt processing, network, and cache
> misses; 7 usecs in TCP processing, user space.  While 5 usecs is an
> aggressive goal, I am not ready to concede that there's an
> architectural limit in either NICs, TCP, or sockets that can't be
> overcome.

Have you toyed with the NIC's interrupt coalescing yet?
I'm wondering if any part of the 25usecs is that.
