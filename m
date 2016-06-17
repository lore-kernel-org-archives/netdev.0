From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: act_mirred: remove spinlock in fast path
Date: Fri, 17 Jun 2016 14:35:58 -0700
Message-ID: <CAM_iQpXJ9Kq=Ff3jZPJYjotXpYOMhTRSZe3Gu4bZ_fLPyKTyWg@mail.gmail.com>
References: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
 <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:32911 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752355AbcFQVgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 17:36:19 -0400
Received: by mail-yw0-f173.google.com with SMTP id g20so82975954ywb.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 14:36:19 -0700 (PDT)
In-Reply-To: <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 2:24 PM, Eric Dumazet <edumazet@google.com> wrote:
> Well, I added a READ_ONCE() to read tcf_action once.
>
> Adding rcu here would mean adding a pointer and extra cache line, to
> deref the values.
>
> IMHO the race here has no effect . You either read the old or new value.

Sure, the point is we may read a new ->tcf_action and an old ->tcfm_eaction,
this is what I am worrying.

If that is not a good example, what about new ->tcf_action and ->tcfm_eaction,
with an old ->tcfm_ifindex?

>
> If the packet is processed before or after the 'change' it would have
> the same 'race'
>

Why? As long as the change is like a transaction, we are safe.

> All these fields are integers, they never are 'partially written'.
>
> The only case m->tcfm_eaction could be read twice is in the error
> path. Who cares ?

This is not what I worry about. I guess you miss read eaction with action.
