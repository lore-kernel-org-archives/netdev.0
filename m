From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] sfq: timer is deferrable
Date: Sun, 20 Jan 2008 17:18:57 -0800 (PST)
Message-ID: <20080120.171857.136126794.davem@davemloft.net>
References: <20080119043446.GB24840@linux.vnet.ibm.com>
	<20080118203655.3b6fbfc9@deepthought>
	<20080119055700.GC24840@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756048AbYAUBSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 20:18:52 -0500
In-Reply-To: <20080119055700.GC24840@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 18 Jan 2008 21:57:00 -0800

> On Fri, Jan 18, 2008 at 08:36:55PM -0800, Stephen Hemminger wrote:
> > On Fri, 18 Jan 2008 20:34:46 -0800
> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > 
> > > On Fri, Jan 18, 2008 at 02:49:00PM -0800, Stephen Hemminger wrote:
> > > > The perturbation timer used for re-keying can be deferred, it doesn't
> > > > need to be deterministic.
> > > 
> > > The only concern that I can come up with is that the sfq_perturbation
> > > timer might be on one CPU, and all the operations using the corresponding
> > > SFQ on another.  This could in theory allow a nearly omniscient attacker
> > > to exploit an SFQ imbalance while preventing perturbation of the hash
> > > function.
> > > 
> > > This does not seem to be a valid concern at this point, since there are
> > > very few uses of init_timer_deferrable().  And if it should become a
> > > problem, one approach would be to have some sort of per-timer limit to
> > > the deferral.  Of course, at that point one would need to figure out
> > > what this limit should be!
> > > 
> > > Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > 
> > But the only threat is getting more bandwidth for a longer interval.
> > It is all kind of moot anyway because the bandwidth hogs all open
> > multiple connections anyway, so SFQ is of no use.
> 
> Good point, and an additional reason for my Acked-by above.  ;-)

I've applied this patch, thanks :-)
