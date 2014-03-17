From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Mon, 17 Mar 2014 15:23:56 +0100
Message-ID: <20140317142356.GA26584@breakpoint.cc>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
 <1395060178-11833-37-git-send-email-pablo@netfilter.org>
 <1395064808.9668.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:52882 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933304AbaCQOYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 10:24:00 -0400
Content-Disposition: inline
In-Reply-To: <1395064808.9668.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-03-17 at 13:42 +0100, Pablo Neira Ayuso wrote:
> > From: Florian Westphal <fw@strlen.de>
> > 
> > connlimit currently suffers from spinlock contention, example for
> > 4-core system with rps enabled:
> 
> > +#define CONNLIMIT_SLOTS	256
> > +#define CONNLIMIT_LOCK_SLOTS	32
> 
> 32 spinlocks use 2 cache lines (assuming 4 bytes per spinlock, and 64
> bytes cache lines)
> 
> So I guess this probably should be increased to have less false sharing.

True, Jesper pointed out the same thing to me.

> I believe this hash table of spinlocks could be global, not in each
> struct xt_connlimit_data.

Good point.  Indeed, this can be global.  I did not increase it
since more locks than tree slots is illegal (need exclusive access to
each rtree at this time). I guess we could align it or increase number
of lock and rbtree slots (after moving lock slots out of connlimit
data).

Thanks for the heads-up Eric, I'll see about addressing this later this
week if noone beats me to it.
