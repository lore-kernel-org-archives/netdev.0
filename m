From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: remove redundant checking for sock timer state
Date: Thu, 31 Jan 2013 23:21:04 -0800
Message-ID: <1359703264.30177.37.camel@edumazet-glaptop>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>
		 <20130201.010946.584437309593473452.davem@davemloft.net>
	 <1359700003.30177.32.camel@edumazet-glaptop> <510B6B4B.8080205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ying.xue@windriver.com,
	netdev@vger.kernel.org
To: Xue Ying <ying.xue0@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51478 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab3BAHVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 02:21:09 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so2155693pad.30
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2013 23:21:08 -0800 (PST)
In-Reply-To: <510B6B4B.8080205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-01 at 15:14 +0800, Xue Ying wrote:
> Eric Dumazet wrote:

> > I had the same reaction but maybe its not anymore a valid thing.
> >
> > Before commit 55c888d6d ([PATCH] timers fixes/improvements) there was
> > indeed a significant cost calling del_timer() because of unconditional
> > spinlock acquisition.
> >
> > But nowadays del_timer() doesn't blindly lock the spinlock.
> >
> > So I guess we could change all occurrences of :
> >
> > if (timer_pending(X))
> >     del_timer(X);
> >
> > It would save some bytes of code.
> >   
> Eric, thanks for your explanation and suggestion.
> 
> But I cannot understand why we should first call timer_pending() before 
> del_timer() in your proposal.
> By my understanding, we might get an unreal timer pending state out of 
> timer base lock (ie, lock_timer_base()),
> and the "unreal" is only for pending state, on the contrary, the value 
> is real for inactive sate.
> So calling timer_pending() out of timer base lock scope can make us 
> avoid some unnecessary grabbing spin lock operations.
> However, in del_timer() there already has placed a timer_pending() 
> before lock_timer_base() is called. So why do we need
> another before calling del_timer()?
> 
> Please you explain more.

I think you misunderstood me.

I said that the old construct :

if (timer_pending(X))
    del_timer(X);

could be changed to

del_timer(X);

Thats what your patch does.

But instead of changing sk_stop_timer(), I suggested you do a patch on
whole net tree.
