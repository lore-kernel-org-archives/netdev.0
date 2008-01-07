From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [IPV4] ROUTE: Avoid sparse warnings
Date: Mon, 7 Jan 2008 14:56:24 +0100
Message-ID: <20080107145624.05918cea.dada1@cosmosbay.com>
References: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
	<E1JBqpd-0006vB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	viro@ZenIV.linux.org.uk
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:53803 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584AbYAGOA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 09:00:29 -0500
In-Reply-To: <E1JBqpd-0006vB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Jan 2008 23:11:53 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Eric Dumazet <dada1@cosmosbay.com> wrote:
> >  CHECK   net/ipv4/route.c
> > net/ipv4/route.c:298:2: warning: context imbalance in 'rt_cache_get_first' - wrong count at exit
> > net/ipv4/route.c:307:3: warning: context imbalance in 'rt_cache_get_next' - unexpected unlock
> > net/ipv4/route.c:346:3: warning: context imbalance in 'rt_cache_seq_stop' - unexpected unlock
> > 
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> > 
> > diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> > index 10915bb..fec0571 100644
> > --- a/net/ipv4/route.c
> > +++ b/net/ipv4/route.c
> > @@ -289,11 +289,11 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
> >        struct rt_cache_iter_state *st = seq->private;
> > 
> >        for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
> > -               rcu_read_lock_bh();
> >                r = rt_hash_table[st->bucket].chain;
> >                if (r)
> >                        break;
> >                rcu_read_unlock_bh();
> > +               rcu_read_lock_bh();
> 
> If we have to change perfectly working code to silence sparse then
> either sparse or we are doing something wrong.
> 
> This is not the only spot where we conditionally hold the lock.
> There's got to be a better fix than changing all of them to hold
> locks unconditionally.

Maybe sparse (or me :) ) is a litle bit dumb :(

You are right other functions conditionally hold some lock(s), but in this
case this is not really necessary / worth the complexity.

AFAIK, this patch reduces complexity and text size.

