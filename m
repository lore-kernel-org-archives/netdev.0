From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] sfq: timer is deferrable
Date: Fri, 18 Jan 2008 21:57:00 -0800
Message-ID: <20080119055700.GC24840@linux.vnet.ibm.com>
References: <20080118144900.1df0dd90@deepthought> <20080119043446.GB24840@linux.vnet.ibm.com> <20080118203655.3b6fbfc9@deepthought>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52238 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbYASF5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 00:57:12 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0J5v7jd031521
	for <netdev@vger.kernel.org>; Sat, 19 Jan 2008 00:57:07 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0J5v2Pd111456
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 22:57:07 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0J5v12d003183
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 22:57:01 -0700
Content-Disposition: inline
In-Reply-To: <20080118203655.3b6fbfc9@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2008 at 08:36:55PM -0800, Stephen Hemminger wrote:
> On Fri, 18 Jan 2008 20:34:46 -0800
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Fri, Jan 18, 2008 at 02:49:00PM -0800, Stephen Hemminger wrote:
> > > The perturbation timer used for re-keying can be deferred, it doesn't
> > > need to be deterministic.
> > 
> > The only concern that I can come up with is that the sfq_perturbation
> > timer might be on one CPU, and all the operations using the corresponding
> > SFQ on another.  This could in theory allow a nearly omniscient attacker
> > to exploit an SFQ imbalance while preventing perturbation of the hash
> > function.
> > 
> > This does not seem to be a valid concern at this point, since there are
> > very few uses of init_timer_deferrable().  And if it should become a
> > problem, one approach would be to have some sort of per-timer limit to
> > the deferral.  Of course, at that point one would need to figure out
> > what this limit should be!
> > 
> > Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
> But the only threat is getting more bandwidth for a longer interval.
> It is all kind of moot anyway because the bandwidth hogs all open
> multiple connections anyway, so SFQ is of no use.

Good point, and an additional reason for my Acked-by above.  ;-)

						Thanx, Paul
