From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 16:31:52 +1000
Message-ID: <20060531063152.GA8032@gondor.apana.org.au>
References: <20060531045811.GA6977@gondor.apana.org.au> <20060530.221117.85394939.davem@davemloft.net> <20060531051451.GA7110@gondor.apana.org.au> <20060530.232626.00456312.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39430 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964794AbWEaGcP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 02:32:15 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060530.232626.00456312.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2006 at 11:26:26PM -0700, David Miller wrote:
> 
> I don't think it will be worthwhile to keep NAPI around just for
> TX completion.  Sure the dev_kfree_skb() will schedule software
> interrupt work to do the actual free, but the TX ring walking
> and dev_kfree_skb() calls will be in hard IRQ context.

Sure we won't need all of NAPI.  But would it be that bad to schedule
a tasklet to do the TX completion?

> > > The only regret I have about that is we will go back to not being able
> > > to profile ->hard_start_xmit() very well in such drivers.
> > 
> > Can you elborate on that? I think I've already removed all references
> > to this in my memory :)
> 
> If you disable IRQs in the ->hard_start_xmit() handler, you don't
> get timer based profiling ticks.   Currently we do.

Oh, I'm not proposing that we disable IRQs on xmit_lock at all.  What
I'm saying is that for tg3, since both xmit_lock and tx_lock are BH-
disabling locks, they are equivalent and therefore we can replace
tx_lock with xmit_lock.

For other lockless NICs that have IRQ disabling tx_locks, they can
be converted to BH-disabling ones and then be able to use xmit_lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
