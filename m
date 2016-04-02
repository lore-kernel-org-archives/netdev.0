From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [net PATCH 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Sat, 2 Apr 2016 13:26:45 -0700
Message-ID: <57002B05.8070005@hpe.com>
References: <1459536543.6473.289.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160401.152405.915323132719949585.davem@davemloft.net>
 <CAKgT0UcLvAF9gTzcaR=GZyTkM2UQ6ymDmnisjgZiG8hTE+PdLA@mail.gmail.com>
 <20160401.221632.846129753053296932.davem@davemloft.net>
 <1459563709.6473.305.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, aduyck@mirantis.com,
	herbert@gondor.apana.org.au, tom@herbertland.com, jesse@kernel.org,
	edumazet@google.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t5008.houston.hp.com ([15.240.92.66]:34811 "EHLO
	g9t5008.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbcDBU0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 16:26:50 -0400
In-Reply-To: <1459563709.6473.305.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2016 07:21 PM, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 22:16 -0400, David Miller wrote:
>> From: Alexander Duyck <alexander.duyck@gmail.com>
>> Date: Fri, 1 Apr 2016 12:58:41 -0700
>>
>>> RFC 6864 is pretty explicit about this, IPv4 ID used only for
>>> fragmentation.  https://tools.ietf.org/html/rfc6864#section-4.1
>>>
>>> The goal with this change is to try and keep most of the existing
>>> behavior in tact without violating this rule?  I would think the
>>> sequence number should give you the ability to infer a drop in the
>>> case of TCP.  In the case of UDP tunnels we are now getting a bit more
>>> data since we were ignoring the outer IP header ID before.
>>
>> When retransmits happen, the sequence numbers are the same.  But you
>> can then use the IP ID to see exactly what happened.  You can even
>> tell if multiple retransmits got reordered.
>>
>> Eric's use case is extremely useful, and flat out eliminates ambiguity
>> when analyzing TCP traces.
>
> Yes, our team (including Van Jacobson ;) ) would be sad to not have
> sequential IP ID (but then we don't have them for IPv6 ;) )

Your team would not be the only one sad to see that go away.

rick jones

> Since the cost of generating them is pretty small (inet->inet_id
> counter), we probably should keep them in linux. Their usage will phase
> out as IPv6 wins the Internet war...
>
>
