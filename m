From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Schedule correct qdisc in watchdog.
Date: Tue, 19 Aug 2008 05:37:45 +0000
Message-ID: <20080819053745.GA2722@ff.dom.local>
References: <20080818113531.GB7158@ff.dom.local> <200808181545.30146.denys@visp.net.lb> <20080818125805.GA7938@ff.dom.local> <20080818.165638.169012226.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:21801 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbYHSFhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 01:37:51 -0400
Received: by ug-out-1314.google.com with SMTP id c2so387586ugf.37
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 22:37:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080818.165638.169012226.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 04:56:38PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 18 Aug 2008 12:58:05 +0000
> 
> > On Mon, Aug 18, 2008 at 03:45:29PM +0300, Denys Fedoryshchenko wrote:
> > > Patch applied, got another warning.
> > 
> > I hope I'll figure this out before evening. Probably it's safer
> > to stop testing for a while.
> 
> We have to put the kfree() of the qdisc back into an RCU handler,
> that's all.

As a matter of fact, I still have some doubts about this. Top level
qdiscs must be deactivated before destroy and during this process we
make sure nothing can use them anymore. So, since this all is under
rtnl_lock(), I wonder if we really need this qdisc root_lock around
qdisc_destroy() for root qdiscs at all.

Maybe there are some common lists which depend on this and rtnl_lock
isn't enough for them. If so, maybe it's easier to change locking in
these places. But, of course, I can miss something.

I'm not against RCU here if it's really needed. Otherwise, this
destroying in softirq context, without rtnl_lock() looks like a
potential obstacle for the future.

Jarek P.
