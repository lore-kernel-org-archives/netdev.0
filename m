From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: xfrm_state locking regression...
Date: Thu, 11 Sep 2008 16:22:12 -0700
Message-ID: <20080911232212.GM6693@linux.vnet.ibm.com>
References: <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <20080911212459.GL6693@linux.vnet.ibm.com> <20080911.150006.53056393.davem@davemloft.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, timo.teras@iki.fi,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59823 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbYIKXWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 19:22:20 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8BNMHEf003669
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 19:22:17 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8BNMCAS203892
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 17:22:17 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8BNMBE6005466
	for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 17:22:12 -0600
Content-Disposition: inline
In-Reply-To: <20080911.150006.53056393.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2008 at 03:00:06PM -0700, David Miller wrote:
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Thu, 11 Sep 2008 14:24:59 -0700
> 
> > On Wed, Sep 10, 2008 at 12:33:12AM +1000, Herbert Xu wrote:
> > > On Mon, Sep 08, 2008 at 05:25:13PM -0700, David Miller wrote:
> > > > 
> > > > The only comment I would make is that maybe it's a bit excessive
> > > > to trigger the GC worker every time we walk the states.
> > > 
> > > Good point!
> > > 
> > > I've avoided the memory barrier by simply extending the mutexed
> > > section in the GC to cover the list splicing.  Here's the updated
> > > patch:
> > > 
> > > ipsec: Use RCU-like construct for saved state within a walk
> > > 
> > > Now that we save states within a walk we need synchronisation
> > > so that the list the saved state is on doesn't disappear from
> > > under us.
> > > 
> > > As it stands this is done by keeping the state on the list which
> > > is bad because it gets in the way of the management of the state
> > > life-cycle.
> > > 
> > > An alternative is to make our own pseudo-RCU system where we use
> > > counters to indicate which state can't be freed immediately as
> > > it may be referenced by an ongoing walk when that resumes.
> > 
> > There is only one reader at a time, right?  Otherwise, I don't see how
> > the increments and reads of xfrm_state_walk_completed line up.
> 
> The RTNL semaphore is held across the modifications of the counters.

Got it, thank you, sorry for the noise!

							Thanx, Paul
