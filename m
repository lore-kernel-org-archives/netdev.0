From: Julien Tinnes <jln@google.com>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Fri, 16 Nov 2012 10:51:24 -0800
Message-ID: <CAKyRK=iKnoRZbjyEXSYbKoFq8=wtVKAJYTQYeE9y_84YevdagA@mail.gmail.com>
References: <1353022864.10798.6.camel@edumazet-glaptop>
	<20121116.013940.813652515905883288.davem@davemloft.net>
	<1353079913.10798.31.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:50238 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950Ab2KPSvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 13:51:25 -0500
Received: by mail-qa0-f53.google.com with SMTP id k31so2075538qat.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 10:51:24 -0800 (PST)
In-Reply-To: <1353079913.10798.31.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 16, 2012 at 7:31 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2012-11-16 at 01:39 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Thu, 15 Nov 2012 15:41:04 -0800
>>
>> > From: Eric Dumazet <edumazet@google.com>
>> >
>> > order-5 allocations can fail with current kernels, we should
>> > try to reduce allocation sizes to allow network namespace
>> > creation.
>> >
>> > Reported-by: Julien Tinnes <jln@google.com>
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>>
>> Indeed, this has to be done better.
>>
>> But this kind of retry solution results in non-deterministic behavior.
>> Yes the tcp metrics cache is best effort, but it's size can influence
>> behavior in a substantial way depending upon the workload.
>>
>> I would suggest that we instead use different limits, ones which the
>> page allocator will satisfy for us always with GFP_KERNEL.
>>
>> 1) include linux/mmzone.h
>>
>> 2) Make the two limits based upon PAGE_ALLOC_COSTLY_ORDER.
>>
>> That is, make the larger table size PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER
>> and the smaller one PAGE_SIZE << (PAGE_ALLOC_COSTLY_ORDER - 1).
>
> Well, we dont really know what the size needs to be, and your proposal
> reduces the size by a 4 factor, even for the initial namespace.
>
> Julien report was about Chrome browser own netns, on a suspend/resume
> cycle (or something like that)

It happens when users start Chrome. Chrome will create one new network
NS (for the sandbox).

This has been used for a few years now, but we had our first report in
January of this year and we've been getting a few reports very
recently at a rate that is starting to worry me (crbug.com/110756).

Thanks a lot for helping with this!

Julien
