From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: Focusing the XDP project
Date: Wed, 22 Feb 2017 00:29:41 +0200
Message-ID: <CALzJLG-323ZOyruHok3=jz526bnw=SoYtYSym8RrA3Z5=g0u9Q@mail.gmail.com>
References: <20170220111343.76f77748@redhat.com> <CAKgT0Ucqp6+jWkiGxDoEE-UdbnxsdVLxjZZ6uYtNWHSo4fPUVg@mail.gmail.com>
 <cc26e1ce-05ae-6c3d-a323-b6f18e2ad897@mellanox.com> <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Brenden Blanco <bblanco@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:33664 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdBUWaD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 17:30:03 -0500
Received: by mail-qt0-f196.google.com with SMTP id n13so19499622qtc.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 14:30:02 -0800 (PST)
In-Reply-To: <CALx6S375878KeM0O7BO9sB7B_3p+yO4yxfEhxYdn_=AZvWF-Aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 6:35 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Mon, Feb 20, 2017 at 2:57 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>>
>> Well, although I think Jesper is a little bit exaggerating ;) I guess he has a point
>> and i am on his side on this discussion. you see, if we define the APIs and ABIs now
>> and they turn out to be a bottleneck for the whole XDP arch performance, at that
>> point it will be too late to compare XDP to DPDK and other kernel bypass solutions.
>>
>> What we need to do is to bring XDP to a state where it performs at least the same as other
>> kernel bypass solutions. I know that the DPDK team here at mellanox spent years working
>> on DPDK performance, squeezing every bit out of the code/dcache/icache/cpu you name it..
>> We simply need to do the same for XDP to prove it worthy and can deliver the required
>> rates. Only then, when we have the performance baseline numbers, we can start expanding XDP features
>> and defining new use cases and a uniform API, while making sure the performance is kept at it max.
>>
>> Yes, there is a down side to this, that currently most of the optimizations and implementations we can do
>> are inside the device driver and they are driver dependent, but once we have a clear image
>> on how things should work, we can pause and think on how to generalize the approaches
>> to all device drivers.
>>
> I don't agree with this approach. We only have a handful of drivers
> that support XDP and already it is obvious that XDP is invasive in the
> critical path and has created maintainence issues. XDP is lacking a
> general API which means that drivers have to do more redundant
> operations, and when it comes time to set such an API (as my patch set
> is trying to deal) we need to retrofit it and deal with this

For control path and XDP program hooks management i completely support
your work,
but as Dave puts it, we need to have some freedom at least in the
first stages in the interaction between driver RX path and XDP
programs packet flow, as the flow might change a couple of times until
we settle down on an optimal approach.

> complexity in each driver. I agree that super great XDP performance is
> a goal, but it's not the only goal-- we still need to provide stable,
> maintainable, good performance drivers for everyone.
>

The only complexity XDP is adding to the drivers is the constrains on
RX memory management and memory model, calling the XDP program itself
and handling the  action is really a simple thing once you have the
correct memory model.

Who knows! maybe someday XDP will define one unified RX API for all
drivers and it even will handle normal stack delivery it self :).

for the long long term I dream of a driver passing page fragments +
"on the side offloads (if any)" to the stack instead of fat SKBs, and
in return it will get the same page back to be recycled into RX buffer
or a replacement new one.
good performance should really come from the stack/XDP/upper layers,
not form the device drivers.

but for the short term we will need to continue experimenting with
what we have and optimize it as much as possible with no constrains.
