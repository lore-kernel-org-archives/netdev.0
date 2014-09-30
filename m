From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH] dql: add a burst attribute
Date: Tue, 30 Sep 2014 17:26:51 +0200
Message-ID: <20140930152651.GC24565@breakpoint.cc>
References: <20140930085114.24043.81310.stgit@dragon>
 <1412080482.30721.68.camel@edumazet-glaptop2.roam.corp.google.com>
 <1412081485.30721.75.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140930134655.GA24565@breakpoint.cc>
 <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34846 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751091AbaI3P04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 11:26:56 -0400
Content-Disposition: inline
In-Reply-To: <1412086646.30721.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-09-30 at 15:46 +0200, Florian Westphal wrote:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > 
> > > Add a new dql attribute, to control how much packets we are allowed to
> > > burst from qdisc to device.
> > 
> > I understand the motivation for this, but I find it a bit out-of-place
> > to have a 'packet' type counter in bql context?
> > 
> > Would it perhaps make more sense to restrict bulk dequeues by an upper
> > (possibly changeable from userspace) byte counter limit?
> 
> The byte count is already provided : its the BQL limit.
> We already have ways to tune it (limit_min & limit_max)
> We do not think we need something else here.

So you're saying that a bulk dequeue should just grab as many skbs
as possible until no more available or dql_avail exhausted?

The "magic" value was just to be conservative and not induce any
hol blocking, which is also why Jesper reduced it again in the latest
submission.

Then, we might later be able to remove the TSO restriction and switch
to a pure byte-based limit.

(I don't think having a packet-based count makes sense once tso/gso
 skbs can be bulk dequeued).

Sorry for the confusion.
