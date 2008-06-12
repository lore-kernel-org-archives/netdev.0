From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Thu, 12 Jun 2008 01:23:29 -0700 (PDT)
Message-ID: <20080612.012329.143140747.davem@davemloft.net>
References: <20080610.224023.116817726.davem@davemloft.net>
	<20080611.224639.250054768.davem@davemloft.net>
	<1213255234.3871.3.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59761
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752516AbYFLIX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 04:23:29 -0400
In-Reply-To: <1213255234.3871.3.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 12 Jun 2008 09:20:34 +0200

> > If the RTNL is held when we invoke flush_scheduled_work() we could
> > deadlock.  One such case is linkwatch, it is a workqueue which tries
>                                             that ^^^^^^^^^
> 
> > The most common case are net driver ->stop() methods.  The
> > simplest conversion is to instead use cancel_{delayed_}work_sync()
> > explicitly on the various workqueues the driver uses.
>                    and that ^^^^^^^^^^
> 
> > This is an OK transformation because these workqueues are doing things
>                                     and that ^^^^^^^^^^
> 
> should read "work struct" because it all uses the global workqueue.
> 
> I haven't looked at the drivers in more detail (sorry) but the patch
> itself looks fine to me (but I wouldn't have caught something like Jarek
> did with the now-unused variables.)

I've made those corrections to the commit message, thanks for
the feedback.

Since Jarek appears to be happy with the patch at this point I'll
commit this and sned it to Linus in my next push of bug fixes.
