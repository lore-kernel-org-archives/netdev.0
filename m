From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: 2.6.23 WARNING: at kernel/softirq.c:139 local_bh_enable()
Date: Fri, 23 Nov 2007 22:32:22 +0300
Message-ID: <20071123193222.GA22168@2ka.mipt.ru>
References: <4745DCD7.8070805@simon.arlott.org.uk> <20071123002157.cb27f4a1.akpm@linux-foundation.org> <20071123105518.GA22062@2ka.mipt.ru> <20071123170756.GV19691@waste.org> <20071123175757.GA23991@2ka.mipt.ru> <20071123184851.GA14415@2ka.mipt.ru> <20071123185101.GA17582@2ka.mipt.ru> <20071123185906.GA23710@2ka.mipt.ru> <20071123191120.GA19691@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Simon Arlott <simon@fire.lp0.eu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54238 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbXKWTdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 14:33:09 -0500
Content-Disposition: inline
In-Reply-To: <20071123191120.GA19691@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 23, 2007 at 01:11:20PM -0600, Matt Mackall (mpm@selenic.com) wrote:
> On Fri, Nov 23, 2007 at 09:59:06PM +0300, Evgeniy Polyakov wrote:
> > On Fri, Nov 23, 2007 at 09:51:01PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > On Fri, Nov 23, 2007 at 09:48:51PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > Stop, we are trying to free skb without destructor and catch connection
> > > > tracking, so it is not a solution. To fix the problem we need to check
> > > > if it is not netfilter related, kind of this (not tested), Simon please
> > > > give it a try:
> > > 
> > > And to be really cool we need to bypass skbs with xfrm attached, since
> > > its freeing also assumes BH context.
> > 
> > What about compile options?
> 
> What about my original suggestion that we mark skbs owned by netpoll
> and free only those. Much safer, no? Untested:

This should work if there are netpoll's skbs, but if we are under memory
pressure we want to free not only netpoll skbs, but at least one, and 
what if there are no netpoll skbs in the queue?

-- 
	Evgeniy Polyakov
