From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Add netif_tx_lock
Date: Mon, 05 Jun 2006 21:32:50 -0700 (PDT)
Message-ID: <20060605.213250.85688925.davem@davemloft.net>
References: <20060531.170908.46214247.davem@davemloft.net>
	<20060601002525.GA19220@gondor.apana.org.au>
	<20060601111503.GA16097@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37268
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932067AbWFFEdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:33:15 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060601111503.GA16097@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 1 Jun 2006 21:15:04 +1000

> On Thu, Jun 01, 2006 at 10:25:25AM +1000, herbert wrote:
> > 
> > > I think this netpoll wrinkle means we also have to make
> > > sure to set the xmit_lock_owner across the board.
> > 
> > You're right.  In fact this can deadlock today for those drivers that
> > already make use of xmit_lock without setting the owner.  So I suppose
> > something like net_xmit_lock to obtain xmit_lock is called for.
> 
> OK, here is a patch which does this.
> 
> [NET]: Add netif_tx_lock

IPOIB is going to BUG() with this change.  Because now, in their
multicast code, you're going to local_bh_disable() via
netif_tx_unlock() with hw IRQs disabled which is illegal.

It shows a bug here in the locking of the IPOIB driver.

We need to think about this change some more. :)
