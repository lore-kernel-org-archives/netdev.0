From: Sharat Masetty <sharat04@gmail.com>
Subject: Re: RPS vs RFS
Date: Mon, 7 Apr 2014 15:15:11 -0600
Message-ID: <CAJzFV35SU4CnHrT4BZ8Gjd20_58yAGEHG0FuRJ+OgnrDuvUeSw@mail.gmail.com>
References: <CAJzFV36pTwUyfoW=Jz1tBKSYbZTLvokOLST+XoX593YP6oN7Pw@mail.gmail.com>
	<CA+mtBx9aF0XTG8wtBB2W7Be5o3PrbKZ_EWRuSoD73q=gvoT6AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:52773 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753162AbaDGVPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 17:15:13 -0400
Received: by mail-wg0-f46.google.com with SMTP id b13so19750wgh.5
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 14:15:11 -0700 (PDT)
In-Reply-To: <CA+mtBx9aF0XTG8wtBB2W7Be5o3PrbKZ_EWRuSoD73q=gvoT6AQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok.. the use case makes sense to me now.

On the benefits part of it, can you please elaborate a little bit on
the cross CPU wakeup and the lock contention? Are you talking about
scheduling NET_RX_ACTION softIRQ on another CPU, why is this
expensive?
Also what locks are you talking about?  regarding cache locality, do
you think that with hardware architectures where cores sharing the
same L2 cache, cache locality will not be an issue?

Thanks
Sharat

On Thu, Apr 3, 2014 at 5:58 PM, Tom Herbert <therbert@google.com> wrote:
> On Thu, Apr 3, 2014 at 12:14 PM, Sharat Masetty <sharat04@gmail.com> wrote:
>> I am trying to understand the true benefit of RFS over RPS. In the
>> kernel documentation scaling.txt, the author talks about data cache
>> hitrate, can someone explain what this actually means? In which
>> scenarios would RFS be beneficial? Why would it help to have network
>> stack run on the same core on which the application for a stream/flow
>> is running?
>>
> Silo'ing processing is typically good, it provides cache locality,
> potentially eliminates a cross CPU wakeup, and hopefully reduces lock
> contention. There is a secondary benefit in that we get some isolation
> of RX processing and application.
>>
>> Consider a NIC with a single receive queue, single interrupt line, and
>> iperf application is pulling data off this NIC card. In case where
>> iperf may still be running on the same core on which the interrupts
>> are delivered, then in that case the whole stack is pinned to the same
>> core, and would not be benefiting a lot from this scheme
>>
> Consider what happens you have a multi threaded network intensive
> application like a web server. Running all the networking an a single
> CPU becomes a bottleneck (why we created RPS/RFS in the first place).
>
>>
>>
>>
>> References:
>> https://www.kernel.org/doc/Documentation/networking/scaling.txt
>>
>> https://lwn.net/Articles/382428/
>>
>> Regards,
>> Sharat
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
