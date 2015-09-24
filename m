From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Thu, 24 Sep 2015 10:54:36 +0800
Message-ID: <20150924025435.GB27355@gondor.apana.org.au>
References: <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <20150923061342.GA19106@gondor.apana.org.au>
 <20150923155440.GB26647@mtj.duckdns.org>
 <20150924023010.GA27131@gondor.apana.org.au>
 <20150924024608.GA25502@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cwang@twopensource.com,
	tom@herbertland.com, kafai@fb.com, kernel-team@fb.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, jiri@resnulli.us,
	nicolas.dichtel@6wind.com, tgraf@suug.ch, sfeldma@gmail.com
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150924024608.GA25502@htj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 23, 2015 at 10:46:08PM -0400, Tejun Heo wrote:
> 
> Hmm... It looks like I'm failing at communicating.  Lemme try again.
> There are two situations where we do this.
> 
> 1. When there are different locking contexts.  In this case, the write
>    path is.  It's already protected by the spinlock so the barrier
>    isn't necessary.
> 
> 2. When the path is hot enough for the cost of smp_rmb() to matter and
>    the specifics of individual deref allows for micro optimization and
>    justifies the added overhead in terms of increased fragility,
>    complexity and need for documentation.
> 
> In both cases, we want to make reasonable trade-offs like any other
> choices we make.  We don't go off and run to one extreme or the other
> just because barriers are involved.  One good measure to use is
> whether the extra documentation necessary is justifiable.  In this
> case, on each unprotected derefs, we want to explain why the
> unprotected deref is okay and justified.

What I am concerned about is the next guy who comes along and
does a rewrite like the one that introduced the netlink_bind
bug.  That person needs to fully understand what each primitive
is protecting against.

Using primitives where they're not needed can lead to misunderstandings
which may end up causing bugs.

Honestly I don't care whether you have a barrier there or not as
I only use x86.  But you very much should add a comment at least
saying that the barrier isn't needed for the cases where I left it
out so that future developers don't get confused.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
