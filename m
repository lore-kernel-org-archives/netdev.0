From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 07:36:11 -0700
Message-ID: <20081007143611.GB6384@linux.vnet.ibm.com>
References: <20081006185026.GA10383@minyard.local> <48EA8197.6080502@cosmosbay.com> <20081006.144002.56418911.davem@davemloft.net> <1223368290.26330.10.camel@lappy.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753594AbYJGOg2@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1223368290.26330.10.camel@lappy.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 07, 2008 at 10:31:30AM +0200, Peter Zijlstra wrote:
> On Mon, 2008-10-06 at 14:40 -0700, David Miller wrote:
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Mon, 06 Oct 2008 23:22:31 +0200
> > 
> > > Me wondering what impact this synchronize_rcu() can have on mono-threaded
> > > VOIP applications using lot of UDP sockets. What is the maximum delay of
> > > this function ?
> > 
> > The cost is enormous, we really can't use it here.
> > 
> > I have a patch that did top-level socket destruction using RCU,
> > and that didn't use synchronize_rcu(), and that killed connection
> > rates by up to %20.
> 
> Did you ever figure out why you lost those 20% ?
> 
> > I can only imagine what the cost would be if I had to add such a call
> > in there.
> 
> Yeah, sync_rcu() is rediculously expensive, at best 3 jiffies IIRC.

I could make it -much- faster, but at the expense of -serious- CPU
overhead.  Still, might be useful during boot time (when the system
can't do anything useful anyway) to accelerate getting data structures
initialized.

							Thanx, Paul
