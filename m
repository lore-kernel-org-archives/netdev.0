From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 19:14:55 -0700
Message-ID: <CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
References: <CAKgT0UfZmK=gSSn+1Z8=KpW9ckVAJJgQg1+5NdO9SKfWv8GiCg@mail.gmail.com>
	<20120726.140601.1137230112117936793.davem@davemloft.net>
	<CAKgT0Ue4mRUpEmKA7SNpTv8D7BKcxYQ65PGoOUkxB27sLuT1Rw@mail.gmail.com>
	<20120726.155327.947597248143903676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:38152 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783Ab2G0CVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 22:21:21 -0400
Received: by vcbfk26 with SMTP id fk26so2338245vcb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 19:21:21 -0700 (PDT)
In-Reply-To: <20120726.155327.947597248143903676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 26, 2012 at 3:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Thu, 26 Jul 2012 15:03:39 -0700
>
>> Here is the latest perf results with all of these patches in place.
>> As you predicted your patch essentially cut the lookup overhead in
>> half:
>
> Ok good.
>
> That patch is hard to make legitimate, I'd have to do a bit or work
> before we could realize that change.
>
> We can only combine the LOCAL and MAIN tables like that so long as
> there are no overlaps in the routes covered by the two tables.  We'd
> also have to be sure to report the routes properly in dumps too.
>
> I really wish we had never segregated these two tables, it's
> completely pointless and hurts performance.  But now we have to
> accomodate this legacy.

Any idea why these look-ups are so expensive in the first place?  When
I dump fib_trie it doesn't look like I have much there.  I would have
thought the table would be pretty static with just 8 flows all going
to the same destination address, but it seems like I was getting hit
with cache misses for some reason.

Thanks,

Alex
