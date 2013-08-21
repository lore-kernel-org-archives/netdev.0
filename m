From: mailings@hupie.com
Subject: Re: [PATCH v2 2/2] net: netem: always adjust now/delay when not    
       reordering
Date: Wed, 21 Aug 2013 16:02:26 +0200 (CEST)
Message-ID: <59065.80.101.237.101.1377093746.squirrel@hupie.dyndns.org>
References: <1377030800.4226.89.camel@edumazet-glaptop>   
    <1377064785-12629-1-git-send-email-mailings@hupie.com>   
    <1377065647.4226.96.camel@edumazet-glaptop> <5214668E.504@hupie.com>   
    <1377091824.4226.102.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Ferry Huberts" <mailings@hupie.com>, netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hupie.dyndns.org ([80.101.237.101]:55403 "EHLO hupie.dyndns.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751557Ab3HUOC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 10:02:28 -0400
In-Reply-To: <1377091824.4226.102.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, 2013-08-21 at 09:04 +0200, Ferry Huberts wrote:
>> On 21/08/13 08:14, Eric Dumazet wrote:
>> > On Wed, 2013-08-21 at 07:59 +0200, Ferry Huberts wrote:
>> >> From: Ferry Huberts <ferry.huberts@pelagic.nl>
>> >>
>> >> Not doing this (current behaviour) introduces reordering.
>> >>
>> >> The packet_len_2_sched_time call is the only thing that logically
depends on q->rate, so move the now/delay adjustment out of the if.
>> >>
>> >> How to test:
>> >> -----------
>> >
>> > I ask again :
>> >
>> > Did you test a config with both rate limiting and delay.
>> (sorry for missing that question)
>> Just did so and with rate limiting I get no reordering, which is
logical
>> looking at the code.
>> The thing is, the evaluation q->rate is within the 'no-reordering'
block
>> and in the current situation you can get reordering (with that
'strange'
>> command). My patch makes sure that no reordering will occur, and
effectively 'clamps' the realised delay, which currently isn't done.
>
>
> OK, let me be very clear.
>
> I would like you post the results of regression tests, to make sure that
you do not add a new regression.
>

Since I'm new to netdev development and therefore the processes attached
to it, let me ask where I can find such regression tests?

I'm happy to run them once I know about them... ;-)


> It seems that you want _us_ to check all this for you.
>
> With "rate 1Mbits delay 100ms 10ms", and ping probes sent every 100ms,
the pong reply of _all_ probes should be between 90ms and 110ms
>
> Is it still the case after your patch ?
>

Yes it is.

In the script I described in the commit message I replaced the line
  tc qdisc add dev "${fields[1]}" handle 1 root netem delay 10ms 500ms
with the line (1Mbit gave 'Illegal "rate"')
  tc qdisc add dev "${fields[1]}" handle 1 root netem rate 1024000 delay
100ms 10ms

The output then was (tried a 10 times):
# ./netemreordering
PING 192.168.160.1 (192.168.160.1) 56(84) bytes of data.
64 bytes from 192.168.160.1: icmp_seq=1 ttl=254 time=114 ms
64 bytes from 192.168.160.1: icmp_seq=2 ttl=254 time=109 ms
64 bytes from 192.168.160.1: icmp_seq=3 ttl=254 time=106 ms
64 bytes from 192.168.160.1: icmp_seq=4 ttl=254 time=100 ms
64 bytes from 192.168.160.1: icmp_seq=5 ttl=254 time=111 ms
64 bytes from 192.168.160.1: icmp_seq=6 ttl=254 time=92.2 ms
64 bytes from 192.168.160.1: icmp_seq=7 ttl=254 time=99.8 ms
64 bytes from 192.168.160.1: icmp_seq=8 ttl=254 time=91.4 ms
64 bytes from 192.168.160.1: icmp_seq=9 ttl=254 time=97.4 ms
64 bytes from 192.168.160.1: icmp_seq=10 ttl=254 time=95.5 ms

--- 192.168.160.1 ping statistics ---
10 packets transmitted, 10 received, 0% packet loss, time 910ms
rtt min/avg/max/mdev = 91.413/101.879/114.534/7.723 ms, pipe 2


Is this enough?
Please let me know, I'm happy to oblige.
