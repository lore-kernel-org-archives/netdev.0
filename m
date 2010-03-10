From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Tue, 9 Mar 2010 18:14:10 -0800
Message-ID: <20100310021410.GD6203@linux.vnet.ibm.com>
References: <20100228054012.GA7583@gondor.apana.org.au> <20100307024500.GA20126@gondor.apana.org.au> <20100307031151.GA7546@linux.vnet.ibm.com> <201003092212.59627.arnd@arndb.de>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:44633 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755925Ab0CJCON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Mar 2010 21:14:13 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2A23Dgp023577
	for <netdev@vger.kernel.org>; Tue, 9 Mar 2010 21:03:13 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2A2ECKB153988
	for <netdev@vger.kernel.org>; Tue, 9 Mar 2010 21:14:12 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2A2EBuw012824
	for <netdev@vger.kernel.org>; Tue, 9 Mar 2010 21:14:11 -0500
Content-Disposition: inline
In-Reply-To: <201003092212.59627.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 09, 2010 at 10:12:59PM +0100, Arnd Bergmann wrote:
> On Sunday 07 March 2010, Paul E. McKenney wrote:
> > On Sun, Mar 07, 2010 at 10:45:00AM +0800, Herbert Xu wrote:
> > > On Sat, Mar 06, 2010 at 11:00:00AM -0800, Paul E. McKenney wrote:
> > 
> > Arnd, would it be reasonable to extend your RCU-sparse changes to have
> > four different pointer namespaces, one for each flavor of RCU?  (RCU,
> > RCU-bh, RCU-sched, and SRCU)?  Always a fan of making the computer do
> > the auditing where reasonable.  ;-)
> > 
> > This could potentially catch the mismatched call_rcu()s, at least if the
> > rcu_head could be labeled.
> > 
> > Other thoughts?
> 
> I've just tried annotating net/ipv4/route.c like this and did not get
> very far, because the same pointers are used for rcu and rcu_bh.
> Could you check if this is a false positive or an actual finding?

Hmmm...  I am only seeing a call_rcu_bh() here, so unless I am missing
something, this is a real problem in TREE_PREEMPT_RCU kernels.  The
call_rcu_bh() only interacts with the rcu_read_lock_bh() readers, not
the rcu_read_lock() readers.

One approach is to run freed blocks through both types of grace periods,
I suppose.

							Thanx, Paul
