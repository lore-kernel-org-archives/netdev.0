From: Ferry Huberts <mailings@hupie.com>
Subject: Re: [PATCH v2 2/2] net: netem: always adjust now/delay when not reordering
Date: Wed, 21 Aug 2013 09:04:46 +0200
Message-ID: <5214668E.504@hupie.com>
References: <1377030800.4226.89.camel@edumazet-glaptop>  <1377064785-12629-1-git-send-email-mailings@hupie.com> <1377065647.4226.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hupie.dyndns.org ([80.101.237.101]:49106 "EHLO hupie.dyndns.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752500Ab3HUHEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 03:04:48 -0400
In-Reply-To: <1377065647.4226.96.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 21/08/13 08:14, Eric Dumazet wrote:
> On Wed, 2013-08-21 at 07:59 +0200, Ferry Huberts wrote:
>> From: Ferry Huberts <ferry.huberts@pelagic.nl>
>>
>> Not doing this (current behaviour) introduces reordering.
>>
>> The packet_len_2_sched_time call is the only thing that logically
>> depends on q->rate, so move the now/delay adjustment out of the if.
>>
>> How to test:
>> -----------
> 
> I ask again :
> 
> Did you test a config with both rate limiting and delay.

(sorry for missing that question)

Just did so and with rate limiting I get no reordering, which is logical
looking at the code.

The thing is, the evaluation q->rate is within the 'no-reordering' block
and in the current situation you can get reordering (with that 'strange'
command). My patch makes sure that no reordering will occur, and
effectively 'clamps' the realised delay, which currently isn't done.

> 
> Netem primary use is to emulate say a 1Mbits link with a rtt of 50ms
> 
> netem rate 1Mbit delay 50ms
> 
> 
> Because the "delay 10ms 500ms" is very strange : effective delay is in
> the following range : -490 ms ... 510 ms
> 
> Its probably clamped to 0ms ... 510ms

Currently it isn't. With my patch it's 'clamped' in the sense that if
the calculated delay would make the packet be scheduled before the
previous one, that the delay of the current packet is adjusted so that
it's scheduled right after the previous one.

> 
> I really doubt this is what you wanted.

It's the command Teco showed me to test/reproduce it.


-- 
Ferry Huberts
