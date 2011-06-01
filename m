From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Wed, 01 Jun 2011 16:24:25 +1000
Message-ID: <1306909465.29297.17.camel@pasglop>
References: <1306828745.7481.660.camel@pasglop>
	 <20110531.194115.486383514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ruediger.herbst@googlemail.com,
	bhamilton04@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52905 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302Ab1FAGYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 02:24:39 -0400
In-Reply-To: <20110531.194115.486383514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-31 at 19:41 -0700, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Tue, 31 May 2011 17:59:05 +1000
> 
> > Now the results .... on a dual G5 machine with a 1000Mb link, no
> > measurable netperf difference on Rx and a 3% loss on Tx.
> > 
> > So taking the lock is the Tx path hurts...
> 
> It shouldn't.  You're replacing one lock with another, and in fact
> because TX reclaim occurs in softirq context (and thus SKB freeing can
> be done directly, instead of rescheduled to a softirq) it should be
> faster.
> 
> And I think I see what the problem is:

 .../...

So fixing that reduced the loss to 1.5%. So far I haven't managed to
coerce perf into giving me meaningful data as to what's going on tho.

Interestingly enough, my DART iommu code is pretty high in all the
profile runs, and it's ancient code that happens to contain way more
memory barriers that it needs. I ditched them and ... lost another 1.5
to 2% !

So something odd is going on, Paulus suspects the stupid direct mapped
L2 cache of those old 970 processors. But with my problems with perf I
haven't quite managed to really measure it.

In any case, I now simplified the driver even more, removing the private
lock and the mutex as well. So I'm really ready to trade those 1.5% loss
on 7 years old HW for a simpler and more maintainable driver, if you are
ok with that. It still needs testing on sparc tho.

I'll post a new spin later today after I've tested suspend/resume again.

Cheers,
Ben.


