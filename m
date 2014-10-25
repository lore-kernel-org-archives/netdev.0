From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Sat, 25 Oct 2014 02:04:00 +0100
Message-ID: <20141025010359.GD11289@acer.localdomain>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com>
 <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com>
 <1414196053.20845.45.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141025003644.GB11289@acer.localdomain>
 <CAHA+R7M3y=Mj_L3yL0UM41mfGa+go+Kq4wYga7D6epY3uq_yWQ@mail.gmail.com>
 <20141025004403.GC11289@acer.localdomain>
 <CAHA+R7NBr_K4fZ-nr2hi+isbxJt92D9o-q+n9xq5Y1rHv14F7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Wang Bo <wang.bo116@zte.com.cn>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Terry Lam <vtlam@google.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43115 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756136AbaJYBEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 21:04:05 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7NBr_K4fZ-nr2hi+isbxJt92D9o-q+n9xq5Y1rHv14F7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 24, 2014 at 05:53:33PM -0700, Cong Wang wrote:
> On Fri, Oct 24, 2014 at 5:44 PM, Patrick McHardy <kaber@trash.net> wrote:
> > On Fri, Oct 24, 2014 at 05:38:48PM -0700, Cong Wang wrote:
> >> On Fri, Oct 24, 2014 at 5:36 PM, Patrick McHardy <kaber@trash.net> wrote:
> >> >
> >> > Again, the correct fix is to make qdisc_create_dflt() not call
> >> > qdisc_destroy() but clean up the qdisc manually as done in
> >> > qdisc_create().
> >>
> >> I kindly wish you a good luck with fixing all callers of qdisc_create_dflt().
> >> Go ahead. :)
> >
> > Here you go:
> >
> 
> ...
> 
> Did you check all ->init() call ->destroy() on failure? Look at the
> sch_pie I have fixed in 1/2.

Why should they? They need to clean up internally, how they do it is
entirely up to them.

> Also check those xxx_init() calling xxx_change().

Please point to conrete bugs if you have any doubts. Real ones, not things
like qdisc_watchdog_init(). This is how the API to which the qdiscs have
been written has always worked.

And yes, I did check the qdisc error paths many times in the past.

> Really, we don't have to make all ->init() doing cleanup by itself.

Are you seriously suggesting that it would be better to have ->destroy()
check what parts were actually initialized and what needs to be cleaned
up instead of assuming a consistent state and have the only function that
actually knows the current state on error (->init()) do its own cleanup?

That's not even worth arguing about, its utterly and completely wrong.
