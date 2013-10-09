From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH v2 tip/core/rcu 07/13] ipv6/ip6_tunnel: Apply
 rcu_access_pointer() to avoid sparse false positive
Date: Wed, 9 Oct 2013 16:40:40 -0700
Message-ID: <20131009234040.GB14055@jtriplet-mobl1>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
 <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
 <1381354186-16285-7-git-send-email-paulmck@linux.vnet.ibm.com>
 <1381354949.4971.20.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009215747.GA5790@linux.vnet.ibm.com>
 <1381356624.4971.26.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009223652.GC5790@linux.vnet.ibm.com>
 <1381359077.4971.37.camel@edumazet-glaptop.roam.corp.google.com>
 <20131009225617.GH11709@jtriplet-mobl1>
 <1381360675.4971.45.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	mingo@kernel.org, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	niv@us.ibm.com, tglx@linutronix.de, peterz@infradead.org,
	rostedt@goodmis.org, dhowells@redhat.com, edumazet@google.com,
	darren@dvhart.com, fweisbec@gmail.com, sbw@mit.edu,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381360675.4971.45.camel@edumazet-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 09, 2013 at 04:17:55PM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-09 at 15:56 -0700, Josh Triplett wrote:
> 
> > I'd be really hesitant to introduce that type of direct assignment to an
> > __rcu pointer without wrapping it in some appropriately named macro, or
> > at the very least adding a comment.
> 
> Well, there is no special magic here, in this specific case :
> 
> - deleting an item in an rcu list
> 
> Check list_del_rcu(), and you'll notice there is no _barrier_
> 
> Adding correct barriers is good, but please do not add them when not
> needed.
> 
> It makes code hard to understand.

I'm not arguing for the inclusion of an unnecessary barrier.  I'm
arguing for something more self-documenting than:

> ACCESS(*ptr) = value;

that.  Constructs like list_del_rcu are much clearer, and not
open-coded.  Open-coding synchronization code is almost always a Bad
Idea.

- Josh Triplett
