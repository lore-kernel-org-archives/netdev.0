From: cold cold <nedkonedev@gmail.com>
Subject: Re: 0% cpu usasge after fresh boot or net restart but 10% CPU if
	kernel flush route cache
Date: Fri, 29 Jan 2010 09:38:31 +0200
Message-ID: <41ac0f9e1001282338n76217590u61877f181c05dc06@mail.gmail.com>
References: <41ac0f9e1001260858o7d2a6a6dgb37ecfba5c325932@mail.gmail.com>
	 <1264605976.3197.8.camel@edumazet-laptop>
	 <41ac0f9e1001271153u333a5e2aq6f473ccc6e6d1e23@mail.gmail.com>
	 <1264627088.2892.7.camel@edumazet-laptop>
	 <41ac0f9e1001280114x17951046oda3fddcae4b8b9d3@mail.gmail.com>
	 <1264694957.2930.15.camel@edumazet-laptop>
	 <41ac0f9e1001280826j1a4e6caar47ccfd357b6feb37@mail.gmail.com>
	 <1264698380.2930.20.camel@edumazet-laptop>
	 <41ac0f9e1001281049g119d5b1bgbc47f78150cac6ee@mail.gmail.com>
	 <1264713387.3380.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:45657 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955Ab0A2Hie convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 02:38:34 -0500
Received: by ey-out-2122.google.com with SMTP id d26so391492eyd.19
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 23:38:32 -0800 (PST)
In-Reply-To: <1264713387.3380.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2010 at 11:16 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 28 janvier 2010 =E0 20:49 +0200, cold cold a =E9crit :
>> what you mean drop packets ?
>>
>> i test 2 different things and shearing results with you
>> first test with high CPU is with garbage collection function
>> second results represent CPU usage with totally disabled =A0garbage =
collection
>
> ell, you didnt describe your benchmark method.
>
> 1) your results were on different rx/tx workload, and describing your
> workload is very important to be able to compare results. Then it sho=
uld
> be exactly same workload.
>
> For example, when tx/tx load is high enough, less cpu overhead is spe=
nt
> on irq processing, since each IRQ delivers more packets per round.
>
> 2) you didnt sent "perf top" results for the second/last one.
>
> =A0But the first "perf top" results showed less than 1% of cpu time w=
as
> used by cache cleanup. I guess you dont want to focus on this, since
> its already very good.
>
>
>
> Usually, when we want to bench a router, we study how it deals with D=
DOS
> workload. Feeding lot of packets to the device and study what percent=
age
> of them are actually transmitted. Goal being 100% of legit packets of
> course.
>
> Route cache settings matter in DDOS situations, and the flush operati=
on
> can have a big impact on dropped frames because of cpu/ram congestion=
=2E
>
> Because of 600 seconds oscillations, its pretty hard to study exact c=
pu
> use of a router, unless taking samples on long periods.
>
>
>
>

I'm totally agree with you there must be some scheduler to release
route cache over the time.
So far i see garbage collector do this, but it cost a lot of CPU
probably its is a bug or design problem don't know
for this i make this 2 test to compare CPU usage with and without GC.


/ secret_interval 10 min,  1300000 route entries in cash ofter 10 min,
 7k new route on empty cache 2k on 1300000  /
all route cache parameters default. I try also with gc_elasticity from
8 to 2 and gc_interval from 60 to 1 but don't have
too much difference.

What I'm trying to say is that flush cash is almost instant ( less
then second on 1 CPU) so releasing of cash is not so heavy job
 ( you are right can have a big impact on dropped frames because of
cpu/ram congestion ) but my point is why GC need 5-6min
10% no  4 CPU to do same job ?
