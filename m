From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Fri, 11 Oct 2013 06:25:12 -0700
Message-ID: <20131011132512.GW5790@linux.vnet.ibm.com>
References: <20131009215747.GA5790@linux.vnet.ibm.com>
 <1381356624.4971.26.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009223652.GC5790@linux.vnet.ibm.com>
 <1381359077.4971.37.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009225617.GH11709@jtriplet-mobl1>
 <1381360675.4971.45.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009234040.GB14055@jtriplet-mobl1>
 <1381363960.4971.55.camel@edumazet-glaptop.roam.corp.google.com>
 <20131010002833.GJ5790@linux.vnet.ibm.com>
 <20131011002044.GA32546@jtriplet-mobl1>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, mingo@kernel.org,
	laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com,
	darren@dvhart.com, fweisbec@gmail.com, sbw@mit.edu,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Josh Triplett <josh@joshtriplett.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131011002044.GA32546@jtriplet-mobl1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2013 at 05:20:44PM -0700, Josh Triplett wrote:
> On Wed, Oct 09, 2013 at 05:28:33PM -0700, Paul E. McKenney wrote:
> > On Wed, Oct 09, 2013 at 05:12:40PM -0700, Eric Dumazet wrote:
> > > On Wed, 2013-10-09 at 16:40 -0700, Josh Triplett wrote:
> > > 
> > > > that.  Constructs like list_del_rcu are much clearer, and not
> > > > open-coded.  Open-coding synchronization code is almost always a Bad
> > > > Idea.
> > > 
> > > OK, so you think there is synchronization code.
> > > 
> > > I will shut up then, no need to waste time.
> > 
> > As you said earlier, we should at least get rid of the memory barrier
> > as long as we are changing the code.
> > 
> > Josh, what would you suggest as the best way to avoid the memory barrier,
> > keep sparse happy, and not be too ugly?
> 
> The more I think about it, the more I realize that assigning an __rcu
> pointer to an __rcu pointer *without* a memory barrier is a sufficiently
> uncommon case that you probably *should* just write an open-coded
> assignment.  Just please put a very clear comment right before it.

Fair enough, will do!  Given earlier email, I believe that Eric is
fine with this, and if he isn't I am sure he will let us know.  ;-)

> I'd originally thought it might make sense to have a macro similar to
> rcu_assign_pointer, but I just don't think this is a common enough case,
> and we don't want people thinking they can use this in general for __rcu
> to __rcu assignments (most of which still need a memory barrier).

Yep, it is a rather small fraction of rcu_assign_pointer() instances.

							Thanx, Paul
