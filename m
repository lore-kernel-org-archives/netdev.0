From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Sat, 21 Mar 2015 05:25:36 +0000
Message-ID: <20150321052535.GB24466@acer.localdomain>
References: <20150320101603.GA17662@gondor.apana.org.au>
 <20150320102701.GA28736@acer.localdomain>
 <20150320214712.GA23963@gondor.apana.org.au>
 <20150320215612.GA566@casper.infradead.org>
 <20150320215756.GA24045@gondor.apana.org.au>
 <20150320220751.GB566@casper.infradead.org>
 <20150320221021.GA24140@gondor.apana.org.au>
 <20150320222311.GC566@casper.infradead.org>
 <20150320222530.GA24309@gondor.apana.org.au>
 <20150320223613.GD566@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43359 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbbCUFZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:25:40 -0400
Content-Disposition: inline
In-Reply-To: <20150320223613.GD566@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.03, Thomas Graf wrote:
> On 03/21/15 at 09:25am, Herbert Xu wrote:
> > On Fri, Mar 20, 2015 at 10:23:11PM +0000, Thomas Graf wrote:
> > > 
> > > He might as well just run for (;;) to burn cycles in his namespace.
> > > If you give away virtualized local privileges you better be ready
> > > to restrict the resources consumed. 
> > 
> > Please reread the first email that you replied to, let me quote:
> > 
> > 	A CPU intensive workload that can be rescheduled is
> > 	completely different from one that is running under spin
> > 	lock with BH disabled.
> 
> We have countless ways to create linear list of things like classifiers,
> qdiscs, multicast memberships, net_devices, fib_rules, etc. All taking
> spin locks or write locks. Most of them with BH disabled. Some at
> least use hashtables with most of them fixed size.

That's my point. Its impossible to fix this by restricting data
structures, this just removes a valid use case.

> I don't want to downplay this but do you *really* want to run
> untrusted workloads with CAP_NET_ADMIN privileges?
