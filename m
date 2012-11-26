From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC net-next PATCH V1 9/9] net: frag remove readers-writer
 lock (hack)
Date: Mon, 26 Nov 2012 10:18:24 +0100
Message-ID: <20121126091824.GB25197@breakpoint.cc>
References: <20121123130749.18764.25962.stgit@dragon>
 <20121123130847.18764.87682.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>, Cong Wang <amwang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:44902 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753533Ab2KZJSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 04:18:35 -0500
Content-Disposition: inline
In-Reply-To: <20121123130847.18764.87682.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> After all the other patches, the rw_lock is now the contention point.
> 
> This is a quick hack, that remove the readers-writer lock, by
> disabling/breaking hash rebuilding.  Just to see how big the
> performance gain would be.
> 
>   2x10G size(4416) result: 6481+6764 = 13245 Mbit/s (gen: 7652+8077 Mbit/s)
> 
>   4x10G size(4416) result:(5610+6283+5735+5238)=22866 Mbit/s
>                      (gen: 6530+7860+5967+5238 =25595 Mbit/s)
> 
> And the results show, that its a big win. With 4x10G size(4416)
> before: 17923 Mbit/s -> now: 22866 Mbit/s increase 4943 Mbit/s.
> With 2x10G size(4416) before 10689 Mbit/s -> 13245 Mbit/s
> increase 2556 Mbit/s.
> 
> I'll work on a real solution for removing the rw_lock while still
> supporting hash rebuilding.  Suggestions and ideas are welcome.

<devils advocate>
Why not kill it altogether, and just set new secret_interval
without moving frag queues to new location?

The only consequence is that all fragments queued at the time of
changing secret_interval will be lost, and free'd by evictor/timer.

Default secret rebuild interval is 10 minutes, should we care about
small packet loss every 10 minutes?
</devils advocate>
