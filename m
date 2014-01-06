From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 01/12] netfilter: avoid get_random_bytes calls
Date: Mon, 6 Jan 2014 14:04:51 +0100
Message-ID: <20140106130451.GF28854@breakpoint.cc>
References: <1388963586-5049-1-git-send-email-pablo@netfilter.org>
 <1388963586-5049-2-git-send-email-pablo@netfilter.org>
 <20140105234157.GB29910@order.stressinduktion.org>
 <20140106115436.GE28854@breakpoint.cc>
 <20140106124340.GC4611@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140106124340.GC4611@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> On Mon, Jan 06, 2014 at 12:54:36PM +0100, Florian Westphal wrote:
> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > Can you elaborate?  If entropy estimate is really really low
> > (because we're booting up), why would get_random_bytes() be a better
> > choice [ i understand net_get_random_once() is for delaying
> > the actual random_bytes call until a later point in time where we've
> > hopefully collected more entropy ]

[..]

> On some of my small virtual machines (amd64) I even see this message while
> login on the console (small iptables set also loaded before). In the mean
> time prandom_u32() is still seeded with maybe 3 bits (I once measured it)
> at the beginning and won't get a refresh until the nonblocking pool is
> fully initialized.

I see.  In this case it indeed could be a problem; I was doing this
change with the assumption that prandom is useable at ->checkenty time.

> > I specifically did not use net_get_random_once once because checkentry is
> > not a hotpath.
> > 
> > I don't see why get_random_bytes use increases the security margin, especially
> > considering none of these hashes have periodic run-time rehashing?
> > 
> > But sure, if you think this change is a problem, Pablo can just revert it.
> 
> I don't know if it is a real problem. Most of the time the initial seed
> should be enough, but I guess get_random_bytes would still be a more
> defensive choice. I would have used it. ;)

Alright.  Given that this went into -next, I think we have a few weeks to
investigate.

I will check if the specific hash uses are problematic in their own right
(due to lack of reseed) or if they are weakened by this change only.

I'll follow up on this.

Pablo/David, if you think this needs to be fixed RIGHT NOW then please
just issue a revert for a42b99a6e329654d376b330de057eff87686d890.

Thanks!
