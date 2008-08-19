From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1: disable TSO by default
Date: Tue, 19 Aug 2008 15:58:45 -0700 (PDT)
Message-ID: <20080819.155845.108491107.davem@davemloft.net>
References: <20080818192813.0d0dc1fd@osprey.hogchain.net>
	<E1KVQyr-0001Ui-00@gondolin.me.apana.org.au>
	<20080819175334.28dc1c8e@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	link@miggy.org, ian@jeffray.co.uk, csnook@redhat.com,
	jie.yang@atheros.com, m@fhloston.org
To: jacliburn@bellsouth.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58254
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758087AbYHSW6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 18:58:46 -0400
In-Reply-To: <20080819175334.28dc1c8e@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Tue, 19 Aug 2008 17:53:34 -0500

> On Tue, 19 Aug 2008 23:10:37 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Jay Cliburn <jacliburn@bellsouth.net> wrote:
> 
> > >        netdev->features |= NETIF_F_LLTX;
> > 
> > Another new driver using LLTX, this is not good when we're trying
> > to get rid of it.
> 
> The atl1 driver was merged in the spring of 2007, so I'm not sure I
> consider it new (but your kernel development time horizon is undoubtedly
> *way* longer than mine, so you may indeed consider it new). It was
> basically a vendor driver that we modified to conform to kernel coding
> standards. It started life, we believe, as pretty much a clone of the
> e1000 driver circa 2005, so that's likely where it's use of LLTX
> came from.

You'll have to forgive us, as we often have a knee jerk reaction
to seeing LLTX anywhere :-)

> > Perhaps we could just kill it by ignoring the LLTX flag and always
> > grabbing the xmit lock.  That should be safe as long as none of these
> > drivers grab the xmit lock within their private locks.
> 
> I'd be happy to gin up a patch if you could point me to a driver that
> implements properly what you're asking.

TG3 is a good example, but that's just my heavily slanted opinion.

What your work should amount to is:

1) Eliminate local driver TX spinlock.

2) Stop taking #1 in ->hard_start_xmit()

3) Where you take #1 elsewhere, replace with netif_tx_lock()
   and friends.

4) Stop setting NETIF_F_LLTX.

That should do it, but of course there are usually other details.
