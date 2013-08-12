From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP performance?
Date: Mon, 12 Aug 2013 16:10:39 -0400
Message-ID: <5209413F.7090802@gmail.com>
References: <52057734.6060306@candelatech.com> <1376090518.20509.14.camel@edumazet-glaptop> <520583AB.9030509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f42.google.com ([209.85.212.42]:45877 "EHLO
	mail-vb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab3HLUKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 16:10:43 -0400
Received: by mail-vb0-f42.google.com with SMTP id e12so6122590vbg.29
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 13:10:42 -0700 (PDT)
In-Reply-To: <520583AB.9030509@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2013 08:04 PM, Ben Greear wrote:
> On 08/09/2013 04:21 PM, Eric Dumazet wrote:
>> On Fri, 2013-08-09 at 16:11 -0700, Ben Greear wrote:
>>> I just added some support for SCTP to my traffic-generator tool.
>>>
>>> I tried to send 1Gbps of traffic, bi-directional, across two
>>> 10G interfaces.  TCP does this without any trouble at all,
>>> but SCTP was asymetric and never got above around 700Mbps,
>>> and was usually stuck at < 500Mbps.
>>>
>>> perf top didn't show any obvious CPU bottlenecks.
>>>
>>> Has anyone done any recent performance testing with SCTP?
>>>
>>> I'd be interested to know the results if so...
>>
>> You mean there is no SCTP offload on the NIC and/or GRO, yes that's too
>> bad.
>>
>
> I'm sure that is part of the problem.
>
> I got much better results when I explicitly set the
> tx/rx socket buffer sizes to 2MB, so maybe it just sucks
> at auto-tuning it's socket buffer sizes.
>
> Thanks,
> Ben
>

There is no buffer autotunning.  There is also no GRO since SCTP doesn't
lend itself easily to GRO. :(

There has been some research efforts at autotunning, but nothing 
proposed.  I'll see if I can find the code and make it work better.

-vlad
