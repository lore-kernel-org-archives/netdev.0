From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] tcp: Use absolute system clock for TCP timestamps
Date: Thu, 24 Sep 2015 17:29:58 +0200
Message-ID: <20150924152958.GA29479@breakpoint.cc>
References: <CABPcSq+jxgKkuafpt5ubDLj9CBfHE1WFwmY-cGzRxuRsfM0KGw@mail.gmail.com>
 <CANn89iJ+SrGJHJGYVpi7SnTkefCB6iq9KzvcU_iYTcz+WvYZPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jovi Zhangwei <jovi@cloudflare.com>, sasha.levin@oracle.com,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Tom Herbert <therbert@google.com>,
	makita.toshiaki@lab.ntt.co.jp, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Marek Majkowski <marek@cloudflare.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANn89iJ+SrGJHJGYVpi7SnTkefCB6iq9KzvcU_iYTcz+WvYZPw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <edumazet@google.com> wrote:
> On Thu, Sep 24, 2015 at 7:14 AM, Jovi Zhangwei <jovi@cloudflare.com> wrote:
> > From f455dc3958593250909627474100f6cc5c158a5c Mon Sep 17 00:00:00 2001
> > From: Marek Majkowski <marek@cloudflare.com>
> > Date: Fri, 11 Sep 2015 06:05:07 -0700
> > Subject: [PATCH] tcp: Use absolute system clock for TCP timestamps
> >
> > Using TCP timestamps is beneficial due for to its purpose in PAWS and when
> > its role when SYN cookies are enabled. In practice though TCP timestamps are
> > often disabled due to being a perceived security issue - they leak Linux
> > system uptime.
> >
> > This patch introduces a kernel option that makes TCP timestamp always return
> > an absolute value derived from a system clock as opposed to jiffies from
> > boot.
> >
> > This patch is based on the approach taken by grsecurity:
> >     https://grsecurity.net/~spender/random_timestamp.diff
> >

I did not see the proposed patch because it didn't make this list,
but I do not like the patch linked to above.

With HZ=1000 the clock wraps every 49 days anyway.
If thats is still deemed a problem, then the proposed solution doesn't
help since all this does is add some 'random uptime' when the machine
is booted so remote monitoring will easily give a good approximation of
real uptime.

Really, where is the problem...?

> TCP stack uses tcp_time_stamp internally, we do not want to add
> overhead adding an offset on all places.
> 
> tp->lsndtime is an example, but we have others.
> 
> Therefore, I suggest you add a new function and use it only where needed.

Agreed, the mangling should only be performed when writing ts stamp
into tcp header, and undone when reading ts echo from network.
