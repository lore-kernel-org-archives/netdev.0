From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: act_mirred: remove spinlock in fast path
Date: Sat, 18 Jun 2016 11:24:44 -0400
Message-ID: <576567BC.9040201@mojatatu.com>
References: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
 <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
 <CAM_iQpXJ9Kq=Ff3jZPJYjotXpYOMhTRSZe3Gu4bZ_fLPyKTyWg@mail.gmail.com>
 <CANn89iJiPnNj1nBHn5v0DQ7fB5n8h1=_h-Ev0UhcYmJE4PehDw@mail.gmail.com>
 <CAM_iQpU57HebOQSYXqoa6xuW4cuSdCqZwQkE_JSu7abHFAuaHw@mail.gmail.com>
 <CANn89iK3DLjJ6y34y1=pnUmH0RKBwwQWj4ZzizVmm98BXxGxYA@mail.gmail.com>
 <57655062.1080407@mojatatu.com>
 <1466262966.6850.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35600 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbcFRPY4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 11:24:56 -0400
Received: by mail-io0-f169.google.com with SMTP id f30so91319790ioj.2
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 08:24:51 -0700 (PDT)
In-Reply-To: <1466262966.6850.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-18 11:16 AM, Eric Dumazet wrote:

>> Given an update/replace of an action is such a rare occassion, what
>> is wrong with init doing a spin lock on existing action?
>> Sure, there is performance impact on fast path at that point - but:
>> as established update/replace is _a rare occassion_ ;->
>
> The potential 'problem' is not the write side, but the read side.
>
> If you read say 3 values <A, B, C>  you might want to read them in a
> consistent way, instead of <new_A, old_B, old_C>
>

That part i get.
What i meant is: while the fast path is doing rcu_read_lock()
of <A, B, C>  and on the rare occassion that _init() is doing a
write to <A,B,C> then if it should spin lock it would not corrupt
what fast path sees as <A, B, C> during the transition.
Am i misunderstanding?

cheers,
jamal
