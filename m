From: Tom Herbert <tom@herbertland.com>
Subject: Re: Focusing the XDP project
Date: Tue, 21 Feb 2017 09:40:17 -0800
Message-ID: <CALx6S36qPxUgvmp4taQFd0OzWyQ9Z4Rv8t+cnph_MAQHiGkvCw@mail.gmail.com>
References: <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
 <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com> <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
 <20170221.114617.1686255511436946338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        john fastabend <john.fastabend@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33884 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753741AbdBURkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:40:20 -0500
Received: by mail-qk0-f170.google.com with SMTP id s186so128989523qkb.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 09:40:19 -0800 (PST)
In-Reply-To: <20170221.114617.1686255511436946338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 8:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Tue, 21 Feb 2017 08:35:41 -0800
>
>> We already have good APIs for similar datapath functionality (GRO,
>> GSO, xmit_more, etc.), and I don't see why XDP is so special that we
>> can't come up with a reasonable API for batching and implement it.
>
> What you are missing is that it wasn't always this way.
>
> The initial TSO support was a hodge-podge of weird driver APIs and
> simple heuristics thrown all over the place.  It was ugly but worked
> and allowed us to experiment.  We had to adjust driver internals
> a lot until on the way towards getting things how they are today.
>
> This is the natural course of things, so please don't suggest that XDP
> shouldn't evolve in the same way.
>
> I think we really need to be fast and loose right now and only try to
> constrict and perfect the API after some of this initial activity has
> died down.
>
> Yes it's more work for the brave drivers that add XDP support, but
> unfortunately that's how we figure out what's really needed and works
> in the long term.

I'd be more supportive of this line of thinking if we (e.g. FB) didn't
have to spend the majority time over the past few months trying to
deal with all the complexity being thrown into drivers for all these
new features such as XDP. Case in point, Mellanox drivers are
completely non-modular and have a horrible directory structure. They
tried to fix, this but the patch set was rejected because it would
break people trying to do backports. That's a fair argument, but the
lesson I gather from that is that we should put more time in up front
thinking about how to structure code the right way instead of just
throwing it in and trying to deal with the consequences later.

Tom
