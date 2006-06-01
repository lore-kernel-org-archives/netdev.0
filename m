From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Thu, 1 Jun 2006 12:27:15 +1000
Message-ID: <20060601022715.GA20061@gondor.apana.org.au>
References: <20060531045811.GA6977@gondor.apana.org.au> <20060530.221117.85394939.davem@davemloft.net> <1149110429.3078.5.camel@rh4> <20060531.170908.46214247.davem@davemloft.net> <20060601002525.GA19220@gondor.apana.org.au> <1149116466.4022.5.camel@rh4> <20060601004235.GA19459@gondor.apana.org.au> <1149121673.4022.22.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42759 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751500AbWFAC1n
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 22:27:43 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1149121673.4022.22.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 05:27:53PM -0700, Michael Chan wrote:
> 
> Now that I think about it some more, we can eliminate most of the
> tx_lock in tg3 without converting to xmit_lock. In most places, we get
> the tx_lock after we call netif_tx_disable(), etc, and quiesce the chip.
> So the tx_lock or xmit_lock is really not necessary in most places. The
> tp->lock is sufficient after we stop everything.

Sounds good.

> The only few remaining places where we need it is around
> netif_stop_queue/netif_wake_queue in hard_start_xmit and tx completion.
> We can either keep the tx_lock or convert to xmit_lock and either way
> makes little difference because these are not in the normal fast path.
> If we keep the tx_lock, it will be just like BNX2.

Now that I look at it the BNX2 method looks perfect.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
