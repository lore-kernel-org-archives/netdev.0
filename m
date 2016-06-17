From: Eric Dumazet <edumazet@google.com>
Subject: Re: act_mirred: remove spinlock in fast path
Date: Fri, 17 Jun 2016 15:03:54 -0700
Message-ID: <CANn89iK3DLjJ6y34y1=pnUmH0RKBwwQWj4ZzizVmm98BXxGxYA@mail.gmail.com>
References: <CAM_iQpU42hydN_akrr8EGuN8OGifyjM3j+W44hjOvRxxM52HbA@mail.gmail.com>
 <CANn89iJj6aqqm0AwQnFR6NJSADje4FS64dzF2-Ac8hSpECG=sQ@mail.gmail.com>
 <CAM_iQpXJ9Kq=Ff3jZPJYjotXpYOMhTRSZe3Gu4bZ_fLPyKTyWg@mail.gmail.com>
 <CANn89iJiPnNj1nBHn5v0DQ7fB5n8h1=_h-Ev0UhcYmJE4PehDw@mail.gmail.com> <CAM_iQpU57HebOQSYXqoa6xuW4cuSdCqZwQkE_JSu7abHFAuaHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:36675 "EHLO
	mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbcFQWD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 18:03:56 -0400
Received: by mail-yw0-f169.google.com with SMTP id d137so7617319ywe.3
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 15:03:55 -0700 (PDT)
In-Reply-To: <CAM_iQpU57HebOQSYXqoa6xuW4cuSdCqZwQkE_JSu7abHFAuaHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 17, 2016 at 2:59 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

> Generally speaking I worry about we change multiple fields in a struct
> meanwhile we could still read them any time in the middle, we may
> get them correct for some easy case, but it is hard to insure the
> correctness when the struct becomes large.
>
> I am thinking to make more tc actions lockless, so this problem
> comes up immediately for other complex cases than mirred.

I certainly wont object to a patch.

Also note that instead of RCU with a pointer and the usual kfree_rcu() stuff,
we now can use seqcount_latch infra which might allow to not increase
memory foot print.
