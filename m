From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v6 04/11] net: Export xmit_recursion
Date: Mon, 21 Jul 2014 18:52:45 -0700
Message-ID: <CALnjE+p3wHtcn2YpXKhHXB7E-qviap=Oe+iV-vdjCbD5k5_TUQ@mail.gmail.com>
References: <1405923435-1971-1-git-send-email-pshelar@nicira.com>
	<063D6719AE5E284EB5DD2968C1650D6D17279E9B@AcuExch.aculab.com>
	<CALnjE+r7BaX1C1X5=9mz4LUQhZZ9B13prukwh0x5_vBsesZYEA@mail.gmail.com>
	<20140721.143040.505863988764762548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:43838 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752121AbaGVBwq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 21:52:46 -0400
Received: by mail-vc0-f173.google.com with SMTP id hy10so13565740vcb.4
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 18:52:46 -0700 (PDT)
In-Reply-To: <20140721.143040.505863988764762548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 2:30 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Mon, 21 Jul 2014 10:01:52 -0700
>
>> On Mon, Jul 21, 2014 at 1:52 AM, David Laight <David.Laight@aculab.com> wrote:
>>> From: Pravin B Shelar
>>>> Next patch adds re-circulation action to OVS. This is recursive
>>>> action needs to be limited to safe number recursions to
>>>> avoid overflowing kernel stack space.  This patch export
>>>> xmit_recursion so that OVS can increment and check the value
>>>> before executing recirc action.
>>> ...
>>>> +#define NET_RECURSION_LIMIT 10
>>>
>>> I'm not entirely sure that any amount of recursion is a good idea
>>> inside the kernel.
>>> If the nested call frame is small enough so that your 10 nestings
>>> are valid it must also be reasonably easy to arrange for the code
>>> to be converted to a loop.
>>>
>>> Remember that the highest stack use is likely to be inside some
>>> error path (probably inside printk) so any experiments that seem
>>> to imply that that stack use is ok are doomed.
>>>
>>> Static analysis is possible (indirect calls make it tricky) provided
>>> there is no recursion.
>>> I did some static stack use analysis for an embedded system many
>>> years ago. It showed that we needed much larger stacks that we'd
>>> allowed for.
>>
>> I am using same recursion counter as networking stack does. Recursion
>> in OVS has lesser cost compared to recursion in networking stack, So
>> it is conservative to use same counter to track recursion in OVS as
>> networking stack recursion.
>
> The networking core uses it is to prevent untenable configurations.
>
> I was going to bring this issue up the other day but I've been
> to busy to do so.  I really want you to seriously look into using
> an iterative algorithm, it can't be so hard inside of openvswitch
> itself.
>
> Any time you go into openvswitch from "somewhere else" you initialize
> a per-cpu structure that keeps track of work to do, if you need to pop
> an MPLS header or whatever and recurse, record it in that structure
> and just return.
>
> This both eliminates recursion, and is faster, since you'll be reusing
> the same stack frame that's fresh and hot in the caches already.
>
OK, since recirc needs more work, I will post the series without recirc patches.

Thanks,
Pravin.

> I want to do this in the core networking at some point too.
