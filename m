From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: act_mirred: remove spinlock in fast path
Date: Sat, 18 Jun 2016 09:45:06 -0400
Message-ID: <57655062.1080407@mojatatu.com>
References: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
 <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
 <CAM_iQpXJ9Kq=Ff3jZPJYjotXpYOMhTRSZe3Gu4bZ_fLPyKTyWg@mail.gmail.com>
 <CANn89iJiPnNj1nBHn5v0DQ7fB5n8h1=_h-Ev0UhcYmJE4PehDw@mail.gmail.com>
 <CAM_iQpU57HebOQSYXqoa6xuW4cuSdCqZwQkE_JSu7abHFAuaHw@mail.gmail.com>
 <CANn89iK3DLjJ6y34y1=pnUmH0RKBwwQWj4ZzizVmm98BXxGxYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:32934 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbcFRNpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 09:45:08 -0400
Received: by mail-io0-f174.google.com with SMTP id t74so90717724ioi.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 06:45:08 -0700 (PDT)
In-Reply-To: <CANn89iK3DLjJ6y34y1=pnUmH0RKBwwQWj4ZzizVmm98BXxGxYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-17 06:03 PM, Eric Dumazet wrote:
> On Fri, Jun 17, 2016 at 2:59 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> Generally speaking I worry about we change multiple fields in a struct
>> meanwhile we could still read them any time in the middle, we may
>> get them correct for some easy case, but it is hard to insure the
>> correctness when the struct becomes large.
>>
>> I am thinking to make more tc actions lockless, so this problem
>> comes up immediately for other complex cases than mirred.
>
> I certainly wont object to a patch.
>
> Also note that instead of RCU with a pointer and the usual kfree_rcu() stuff,
> we now can use seqcount_latch infra which might allow to not increase
> memory foot print.
>

Given an update/replace of an action is such a rare occassion, what
is wrong with init doing a spin lock on existing action?
Sure, there is performance impact on fast path at that point - but:
as established update/replace is _a rare occassion_ ;->

cheers,
jamal
