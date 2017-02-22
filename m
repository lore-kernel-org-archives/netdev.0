From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC v3 0/8] xdp: Infrastructure to generalize XDP
Date: Tue, 21 Feb 2017 16:25:15 -0800
Message-ID: <CALx6S34aOhKt7JS=3tbweMm1pf3gnr4WU1ZnjOUc5-wP+xCuyA@mail.gmail.com>
References: <20170221193417.3641224-1-tom@herbertland.com> <20170221150907.5ae68ffa@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:34522 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752397AbdBVAZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 19:25:17 -0500
Received: by mail-qt0-f177.google.com with SMTP id n21so58439713qta.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 16:25:16 -0800 (PST)
In-Reply-To: <20170221150907.5ae68ffa@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 3:09 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> Hi,
>
> I still have a few worries about this patch set...
>
> On Tue, 21 Feb 2017 11:34:09 -0800, Tom Herbert wrote:
>> This patch set generalizes XDP by making the hooks in drivers to be
>> generic. This has a number of advantages:
>>
>>   - Allows a means to pipeline XDP programs together
>
> Does it add anything beyond what we already can achieve with tail
> calls?  Is there expectations that users will install independent
> black box/pre-compiled programs on the same interface?
>
>>   - Reduces the amount of code and complexity needed in drivers to
>>     manage XDP
>
> Other than for Mellanox drivers the savings are in *teen lines of code?
>
>>   - Provides a more structured environment that is extensible to new
>>     features while being mostly transparent to the drivers
>
> So far all features we added required explicit driver support.
> Checksumming support as an example will require driver changes, too.
> Generalized way to call programs is probably not going to buy us much?
>
Hi Jakub,

What is the the concern with checksumming? Isn't that just an issue of
defining fields in xdp_data and driver populating with the appropriate
information?

Tom

>>   - Allow XDP programs to be set per device or per queue
>
> Some drivers already provide that even though we don't have a user API
> to set it.
>
>>   - Moves management of BPF programs out of driver into a common
>>     infrastructure
>
> I appreciate this one, but IMHO this generalized infrastructure is way
> too complicated for the purpose.  Why not simply place an XDP program
> pointer into netdev and napi and provide driver with a helper to install
> the program there?  Or am I simply not understanding the benefits of
> the generalized hooks?
>
> I probably have a slightly unique perspective caring about offloads but
> IMHO the cost of this patchset outweighs the benefits right now.  You
> haven't actually implement the OFFLOAD command at all (grep for
> XDP_OFFLOAD_BPF) but having to deal with the intermediary layer will
> certainly complicate things here.
>
> There are also miscellaneous optimizations which are possible when
> drivers can inspect the program, like only reserving headroom if
> program may use header adjust...  it does seem to me that this set
> introduces a lot of complexity and only superficial driver
> simplifications.  I would personally rather wait with infrastructure
> like this until John's TX-to-other netdev is well formulated.
>
> Obviously this set will also be a major pain when backporting things,
> too.
