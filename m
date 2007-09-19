From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: new NAPI quota synchronization issue
Date: Wed, 19 Sep 2007 15:01:29 -0700
Message-ID: <20070919150129.7b0967f7@freepuppy.rosehill.hemminger.net>
References: <20070919.095825.39465358.davem@davemloft.net>
	<20070919.103508.59469052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40660 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbXISWBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:01:34 -0400
In-Reply-To: <20070919.103508.59469052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Sep 2007 10:35:08 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 19 Sep 2007 09:58:25 -0700 (PDT)
> 
> > Probably a good way to deal with this is to simply make the quota
> > handling stateless.
> > 
> > The only reason we handle partial quota usage is to handle the
> > global netdev_budget.  But we can simply "round up" and let
> > netdev_budget get oversubscribed by one napi->quota's worth
> > if necessary.
> > 
> > At that point, n->quota only holds two states when used, full
> > and empty.  And at that point there is no reason to maintain
> > it's value at all.  Only the weight is necessary.
> > 
> > I'll try to post a patch which implements this later today.
> 
> Ok, here is the patch and I've checked it into net-2.6.24 as well.
> 
> There really shouldn't be any fundamental synchronization issues
> in the new NAPI stuff any longer.  I'm pretty sure any problems
> remaining can only be caused by drivers bugs but we'll see :-)
> 
> I went over the list handling several times and it looks bulletproof.
> Only the thread of control that sets the NAPI_STATE_SCHED bit
> atomically will do list modifications, until the thread of control
> that decides unconditionally to clear the bit, which will do a
> list_del() immediately before clearing that bit.
> 
> 

There might be a future problem if some driver decided to change weight
often on the fly?  Perhaps you need to sample it once in start of napi_schedule.
