From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable and lockless TX
Date: Thu, 1 Jun 2006 10:25:25 +1000
Message-ID: <20060601002525.GA19220@gondor.apana.org.au>
References: <20060531045811.GA6977@gondor.apana.org.au> <20060530.221117.85394939.davem@davemloft.net> <1149110429.3078.5.camel@rh4> <20060531.170908.46214247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55314 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965055AbWFAA0E
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 20:26:04 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060531.170908.46214247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 31, 2006 at 05:09:08PM -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Wed, 31 May 2006 14:20:29 -0700
> 
> > David, So do we want to fix this issue as proposed by Herbert to replace
> > tx_lock with xmit_lock? It seems quite straightforward to do. For this
> > change to work, netpoll also needs to be fixed up a bit to check for
> > LLTX before getting the xmit_lock.
> 
> Oh yes, netpoll needs changes, thanks for noticing that.

Why does it need to change? The idea is to take the LLTX flag off tg3
after the conversion to xmit_lock.

> I think this netpoll wrinkle means we also have to make
> sure to set the xmit_lock_owner across the board.

You're right.  In fact this can deadlock today for those drivers that
already make use of xmit_lock without setting the owner.  So I suppose
something like net_xmit_lock to obtain xmit_lock is called for.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
