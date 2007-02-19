From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 1/2] RTNL and flush_scheduled_work deadlocks
Date: Mon, 19 Feb 2007 08:11:59 +0100
Message-ID: <20070219071159.GB1686@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty> <45D60022.9060701@candelatech.com> <20070219061300.GA1640@ff.dom.local> <45D94347.8060405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:41554 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750710AbXBSHIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 02:08:37 -0500
Content-Disposition: inline
In-Reply-To: <45D94347.8060405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 18, 2007 at 10:27:19PM -0800, Ben Greear wrote:
> Jarek Poplawski wrote:
> >On Fri, Feb 16, 2007 at 11:04:02AM -0800, Ben Greear wrote:
> >  
> >>Stephen Hemminger wrote:
> >>    
> >>>On Thu, 15 Feb 2007 23:40:32 -0800
> >>>Ben Greear <greearb@candelatech.com> wrote:
> >>>      
> >>>>Maybe there should be something like an ASSERT_NOT_RTNL() in the 
> >>>>flush_scheduled_work()
> >>>>method?  If it's performance criticial, #ifdef it out if we're not 
> >>>>debugging locks?
> >>>>
> >>>>        
> >>>You can't safely add a check like that. What if another cpu had acquired
> >>>RTNL and was unrelated.
> >>>      
> >>I guess there isn't a way to see if *this* thread is the owner of the RTNL
> >>currently?  I think lockdep knows the owner...maybe could query it 
> >>somehow,
> >>or just save the owner in the mutex object when debugging is enabled...
> >>    
> >
> >Here is my patch proposal to enable such thing
> >(and to make ASSERT_RTNL simpler btw.).
> >  
> For performance reasons, I'd leave the rtnl_owner inside the
> #if debugging locking code....

This is needed with my second patch. But it is only
proposal, so all could be enhanced of course.
But I don't thing current ASSERT_RTNL has anything
to do with performance. And after all it's for mutex
(slow) path, so I'm not sure if performance is such a
problem.

> You are also changing the semantics of ASSERT_RTNL (assert *this thread* 
> has rtnl, from the
> old behaviour:  assert *some thread* has rtnl).  It may be better this
> way, but it could break code that assumes the old behaviour.

Sure, this should be verified. But this old behavior isn't
very fast and reliable (there is a possibility, we are
asserted wrongly because RTNL lock was held at the moment
by somebody else).

Cheers,
Jarek P.
