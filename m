From: Michael Ma <make0818@gmail.com>
Subject: Re: qdisc spin lock
Date: Fri, 15 Apr 2016 16:05:43 -0700
Message-ID: <CAAmHdhzbEJAR00akLg8UG9UOwa+TRw+PaeuYyguiJuciYaLroA@mail.gmail.com>
References: <CAAmHdhw9bQkCm7uehRZ9mTetMzafdXxWhYj16f8W-YvSz8V4=g@mail.gmail.com>
	<CAM_iQpVSHqLcGjrErAsh54+iD8uwGH5QNGwiJVOQOTsk=dwDbw@mail.gmail.com>
	<CAAmHdhxagKnLP1_5ZW7HTsVBu0TSFYKCvNstAEWN-NHrdnvvVQ@mail.gmail.com>
	<1460125157.6473.434.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAAmHdhw8-qEHwe+GNU_p9UGZyMU38PgrjaM9zEK9nOfSENxDUg@mail.gmail.com>
	<1460760854.10638.81.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:34946 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbcDOXFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 19:05:44 -0400
Received: by mail-ig0-f194.google.com with SMTP id fn8so4564355igb.2
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 16:05:43 -0700 (PDT)
In-Reply-To: <1460760854.10638.81.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-15 15:54 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Fri, 2016-04-15 at 15:46 -0700, Michael Ma wrote:
>> 2016-04-08 7:19 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
>> > On Thu, 2016-03-31 at 16:48 -0700, Michael Ma wrote:
>> >> I didn't really know that multiple qdiscs can be isolated using MQ so
>> >> that each txq can be associated with a particular qdisc. Also we don't
>> >> really have multiple interfaces...
>> >>
>> >> With this MQ solution we'll still need to assign transmit queues to
>> >> different classes by doing some math on the bandwidth limit if I
>> >> understand correctly, which seems to be less convenient compared with
>> >> a solution purely within HTB.
>> >>
>> >> I assume that with this solution I can still share qdisc among
>> >> multiple transmit queues - please let me know if this is not the case.
>> >
>> > Note that this MQ + HTB thing works well, unless you use a bonding
>> > device. (Or you need the MQ+HTB on the slaves, with no way of sharing
>> > tokens between the slaves)
>> >
>> >
>> > https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=bb1d912323d5dd50e1079e389f4e964be14f0ae3
>> >
>> > bonding can not really be used as a true MQ device yet.
>> >
>> > I might send a patch to disable this 'bonding feature' if no slave sets
>> > a queue_id.
>> >
>> >
>> So there is no way of using this MQ solution when bonding interface is
>> used, right? Then modifying HTB might be the only solution?
>
> I probably can submit a bonding patch very soon if there is interest.

Would definitely appreciate that. If you can share the patch it will
be helpful as well. Let me know if I can help with this...
>
> Modifying HTB is way more complicated :(
>
>
>
