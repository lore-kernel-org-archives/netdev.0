From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: act_mirred: remove spinlock in fast path
Date: Sat, 18 Jun 2016 09:13:45 -0700
Message-ID: <1466266425.6850.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
	 <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
	 <CAM_iQpXJ9Kq=Ff3jZPJYjotXpYOMhTRSZe3Gu4bZ_fLPyKTyWg@mail.gmail.com>
	 <CANn89iJiPnNj1nBHn5v0DQ7fB5n8h1=_h-Ev0UhcYmJE4PehDw@mail.gmail.com>
	 <CAM_iQpU57HebOQSYXqoa6xuW4cuSdCqZwQkE_JSu7abHFAuaHw@mail.gmail.com>
	 <CANn89iK3DLjJ6y34y1=pnUmH0RKBwwQWj4ZzizVmm98BXxGxYA@mail.gmail.com>
	 <57655062.1080407@mojatatu.com>
	 <1466262966.6850.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <576567BC.9040201@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35393 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbcFRQNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 12:13:48 -0400
Received: by mail-pf0-f170.google.com with SMTP id c2so40142165pfa.2
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 09:13:47 -0700 (PDT)
In-Reply-To: <576567BC.9040201@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-18 at 11:24 -0400, Jamal Hadi Salim wrote:
> On 16-06-18 11:16 AM, Eric Dumazet wrote:
> 
> >> Given an update/replace of an action is such a rare occassion, what
> >> is wrong with init doing a spin lock on existing action?
> >> Sure, there is performance impact on fast path at that point - but:
> >> as established update/replace is _a rare occassion_ ;->
> >
> > The potential 'problem' is not the write side, but the read side.
> >
> > If you read say 3 values <A, B, C>  you might want to read them in a
> > consistent way, instead of <new_A, old_B, old_C>
> >
> 
> That part i get.
> What i meant is: while the fast path is doing rcu_read_lock()
> of <A, B, C>  and on the rare occassion that _init() is doing a
> write to <A,B,C> then if it should spin lock it would not corrupt
> what fast path sees as <A, B, C> during the transition.
> Am i misunderstanding?

Yes, I do not see how a change in the write side can help.

You probably need a bit of coffee ;)
