From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] Return value from schedule()
Date: Thu, 4 Sep 2008 18:14:24 +0200
Message-ID: <20080904161424.GA23042@elte.hu>
References: <20080827204626.4b65862f@extreme> <20080828111323.GI7908@solarflare.com> <20080903155713.7fab2e19@extreme> <20080904160739.GK2772@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	Linus Torvalds <torvalds@osdl.org>,
	Andrew Morton <akpm@osdl.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:55735 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbYIDQOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 12:14:42 -0400
Content-Disposition: inline
In-Reply-To: <20080904160739.GK2772@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Matthew Wilcox <matthew@wil.cx> wrote:

> In some circumstances, you want to wait for an event to happen.  let's 
> assume that it's a hardware event, so you can't just add a notifier of 
> some kind, you have to poll.  Here's an example:
> 
> On Wed, Sep 03, 2008 at 03:57:13PM -0700, Stephen Hemminger wrote:
> >  			return -ETIMEDOUT;
> > -		udelay(10);
> > +		if (signal_pending(current))
> > +			return -EINTR;
> > +		schedule();
> 
> If there's no other task ready to run, schedule() could return in much
> less than 10 microseconds (actually, it could return in much less than
> 10 microseconds even if another task does run, but let's ignore that case).
> 
> If schedule() returned whether or not it had scheduled another task, we
> could do something like:
> 
> 		if (!schedule())
> 			udelay(10);

hm, i'm not really sure - this really just seems to be a higher prio 
variant of yield() combined with some weird code. Do we really want to 
promote such arguably broken behavior? If there's any chance of any 
polling to take a material amount of CPU time it should be event driven 
to begin with.

	Ingo
