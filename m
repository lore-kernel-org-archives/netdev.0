From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Wed, 22 Jun 2016 10:40:11 -0700
Message-ID: <CALx6S35zDzLPnP0iAayRKFGg4b6OcWFQ2iAu3CFMsVLd2uG2Gg@mail.gmail.com>
References: <CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
 <20160619.200741.1114304127682357737.davem@davemloft.net> <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
 <20160621.042918.1782717212289281861.davem@davemloft.net> <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34088 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcFVRkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:40:18 -0400
Received: by mail-io0-f177.google.com with SMTP id g13so43632161ioj.1
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:40:12 -0700 (PDT)
In-Reply-To: <CAPshTCgCVs5i1QyLeNPzw2W3X5+r_=5Hw1HOnD+cBsBQBRN35g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2016 at 8:42 PM, Jerry Chu <hkchu@google.com> wrote:
> On Tue, Jun 21, 2016 at 1:29 AM, David Miller <davem@davemloft.net> wrote:
>> From: Tom Herbert <tom@herbertland.com>
>> Date: Mon, 20 Jun 2016 08:13:48 -0700
>>
>>> Routing around the problem is already being done.
>>
>> QUIC, a new protocol used for specific purposes and implemented in
>> userspace from the start is significantly different from making the
>> kernel's _TCP_ implementation bypassed into a userspace one just by
>> UDP encapsulating it.
>>
>> That is a major and conscious change in our mentality.
>>
>> The consequences are far and wide, and I'm having a very hard time
>> seeing the benefits you cite being larger than the negatives here.
>
> I don't believe TOU will lead to a proliferation of TCP implementations in
> the userland - getting a solid TCP implementation is hard. Yes any smart CS
> student in the networking field can write one over a weekend, to get 3WHS
> to work, and may even include graceful shutdown. But creating one from
> scratch that is both high quality, compliant, highly inter-operable, and highly
> performing is really hard. Just look at how much work folks on the list have
> to continue to pour in to maintain the Linux TCP stack as the best on the
> planet.
>
> Yes TOU may lower the bar for random hacks by Joe Random. But I'd argue
> no large organization would serious consider or dare deploy TCP stack
> with random hacks. I know we have a very high bar to pass at Google. This
> should limit the impact of bad TCP stacks on the Internet. If we continue
> to keep up and make timely improvements to the Linux TCP stack, and
> better yet, to continue to improve technology like UML and LKL to make it
> easy for folks to access great technologies in the Linux kernel stack and
> deploy them in the userland, it will probably take away all the motivations
> for people to do their own random hacks.
>
+1

A major point of TOU is precisely that we want to continue leveraging
the Linux stack to build scalable, flexible, robust servers. We are
only considering userspace based transport protocol for end clients
which are already "Joe Random" devices as far as servers are
concerned. The difference between TOU and "traditional" OS bypass
networking is that we are implementing only the transport layer
protocol in userspace (i.e. TCP, SCTP, DCCP, etc.), not anything
related to L2 and L3 which makes the solution feasible to deploy on
existing client OSes.

Tom
