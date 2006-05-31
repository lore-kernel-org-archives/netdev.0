From: David Miller <davem@davemloft.net>
Subject: Re: netif_tx_disable and lockless TX
Date: Tue, 30 May 2006 23:26:26 -0700 (PDT)
Message-ID: <20060530.232626.00456312.davem@davemloft.net>
References: <20060531045811.GA6977@gondor.apana.org.au>
	<20060530.221117.85394939.davem@davemloft.net>
	<20060531051451.GA7110@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24793
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751292AbWEaG0O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 02:26:14 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060531051451.GA7110@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 May 2006 15:14:51 +1000

> On Tue, May 30, 2006 at 10:11:17PM -0700, David Miller wrote:
> > 
> > It will come back when net channels arrive :-) This is because net
> > channel drivers will do all the work in hard IRQs and not in a NAPI or
> > NAPI-like context.
> 
> I thought the current channel stuff is RX only.  Is TX completion moving
> to IRQ context as well?

I don't think it will be worthwhile to keep NAPI around just for
TX completion.  Sure the dev_kfree_skb() will schedule software
interrupt work to do the actual free, but the TX ring walking
and dev_kfree_skb() calls will be in hard IRQ context.

> > The only regret I have about that is we will go back to not being able
> > to profile ->hard_start_xmit() very well in such drivers.
> 
> Can you elborate on that? I think I've already removed all references
> to this in my memory :)

If you disable IRQs in the ->hard_start_xmit() handler, you don't
get timer based profiling ticks.   Currently we do.
