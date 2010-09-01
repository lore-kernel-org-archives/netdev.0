From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] 3c59x: Remove incorrect locking; correct
 documented lock hierarchy
Date: Wed, 01 Sep 2010 14:38:15 -0700 (PDT)
Message-ID: <20100901.143815.215547115.davem@davemloft.net>
References: <1283213733.7653.180.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51089
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752142Ab0IAVh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 17:37:58 -0400
In-Reply-To: <1283213733.7653.180.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Tue, 31 Aug 2010 01:15:33 +0100

> vortex_ioctl() was grabbing vortex_private::lock around its call to
> generic_mii_ioctl().  This is no longer necessary since there are more
> specific locks which the mdio_{read,write}() functions will obtain.
> Worse, those functions do not save and restore IRQ flags when locking
> the MII state, so interrupts will be enabled when generic_mii_ioctl()
> returns.
> 
> Since there is currently no need for any function to call
> mdio_{read,write}() while holding another spinlock, do not change them
> to save and restore IRQ flags but remove the specification of ordering
> between vortex_private::lock and vortex_private::mii_lock.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> I've now borrowed a card to test 3c59x on.  I've seen another regression
> reported <http://bugs.debian.org/586967> after my locking changes, which
> I can't reproduce.

I think the lock is necessary, in some form.

Nothing otherwise protects vp->mii, which is accessed and modified by
not just this ioctl, but also ethtool operation calls.

So we can't apply your patch as-is.
