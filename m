From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu
 macro
Date: Wed, 22 May 2013 06:00:30 -0700
Message-ID: <20130522130030.GB3431@linux.vnet.ibm.com>
References: <519B38EC.90401@yandex-team.ru>
 <20130521120906.GD3578@linux.vnet.ibm.com>
 <1369143885.3301.221.camel@edumazet-glaptop>
 <519B8908.9080007@yandex-team.ru>
 <1369150693.3301.233.camel@edumazet-glaptop>
 <519BB90B.6080706@yandex-team.ru>
 <1369188080.3301.268.camel@edumazet-glaptop>
 <20130522095839.GC3578@linux.vnet.ibm.com>
 <1369225727.3301.322.camel@edumazet-glaptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roman Gushchin <klamm@yandex-team.ru>,
	Dipankar Sarma <dipankar@in.ibm.com>, zhmurov@yandex-team.ru,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1369225727.3301.322.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 22, 2013 at 05:28:47AM -0700, Eric Dumazet wrote:
> On Wed, 2013-05-22 at 02:58 -0700, Paul E. McKenney wrote:
> 
> > Now that I am more awake...
> > 
> > The RCU list macros assume that the list header is either statically
> > allocated (in which case no ACCESS_ONCE() or whatever is needed) or
> > that the caller did whatever was necessary to protect the list header,
> > whether that be holding the right lock, using rcu_dereference() when
> > traversing the pointer to the list header, or whatever.
> 
> Not sure what you mean, we do hold rcu_read_lock() here.
> 
> But when we jump back to begin, we do not do
> "rcu_read_unlock()/rcu_read_lock()" pair.

Right, rcu_read_lock() is part of the protection, but rcu_dereference()
is the other part.

All that aside, I can't claim that I understand what problem the various
patches would solve.  ;-)

							Thanx, Paul
