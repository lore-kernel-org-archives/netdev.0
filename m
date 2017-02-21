From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Focusing the XDP project
Date: Wed, 22 Feb 2017 00:40:46 +0200
Message-ID: <CALzJLG_B+StgYBqUrUF3ZiQXHsLVWzh0uUALfGpgpYDOXwWE-Q@mail.gmail.com>
References: <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
 <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com> <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
 <20170221.114617.1686255511436946338.davem@davemloft.net> <CALx6S36qPxUgvmp4taQFd0OzWyQ9Z4Rv8t+cnph_MAQHiGkvCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        john fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:34933 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdBUWlH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 17:41:07 -0500
Received: by mail-qt0-f178.google.com with SMTP id x35so50680904qtc.2
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 14:41:07 -0800 (PST)
In-Reply-To: <CALx6S36qPxUgvmp4taQFd0OzWyQ9Z4Rv8t+cnph_MAQHiGkvCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 7:40 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Feb 21, 2017 at 8:46 AM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Tue, 21 Feb 2017 08:35:41 -0800
>>
>>> We already have good APIs for similar datapath functionality (GRO,
>>> GSO, xmit_more, etc.), and I don't see why XDP is so special that we
>>> can't come up with a reasonable API for batching and implement it.
>>
>> What you are missing is that it wasn't always this way.
>>
>> The initial TSO support was a hodge-podge of weird driver APIs and
>> simple heuristics thrown all over the place.  It was ugly but worked
>> and allowed us to experiment.  We had to adjust driver internals
>> a lot until on the way towards getting things how they are today.
>>
>> This is the natural course of things, so please don't suggest that XDP
>> shouldn't evolve in the same way.
>>
>> I think we really need to be fast and loose right now and only try to
>> constrict and perfect the API after some of this initial activity has
>> died down.
>>
>> Yes it's more work for the brave drivers that add XDP support, but
>> unfortunately that's how we figure out what's really needed and works
>> in the long term.
>
> I'd be more supportive of this line of thinking if we (e.g. FB) didn't
> have to spend the majority time over the past few months trying to
> deal with all the complexity being thrown into drivers for all these
> new features such as XDP. Case in point, Mellanox drivers are
> completely non-modular and have a horrible directory structure. They
> tried to fix, this but the patch set was rejected because it would
> break people trying to do backports. That's a fair argument, but the
> lesson I gather from that is that we should put more time in up front
> thinking about how to structure code the right way instead of just
> throwing it in and trying to deal with the consequences later.
>

I also gathered the same lesson :) I will do my best to separate
between regular RX path and XDP-enabled RX path as much as possible in
my next RX staging/bulking patches as the current mlx5 design allows
me to do so with a little code duplication.

> Tom
