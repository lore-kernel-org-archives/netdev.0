From: David Miller <davem@davemloft.net>
Subject: Re: netif_tx_disable and lockless TX
Date: Tue, 30 May 2006 22:11:17 -0700 (PDT)
Message-ID: <20060530.221117.85394939.davem@davemloft.net>
References: <1551EAE59135BE47B544934E30FC4FC041BC90@NT-IRVA-0751.brcm.ad.broadcom.com>
	<20060531045811.GA6977@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62140
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751703AbWEaFKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 May 2006 01:10:50 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060531045811.GA6977@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 31 May 2006 14:58:11 +1000

> Hi Michael:
> 
> On Tue, May 30, 2006 at 09:51:03PM -0700, Michael Chan wrote:
> >
> > > That's why I suggest that every NIC that uses this feature be forced
> > > to do what TG3 does so only BH disabling is needed.  Once that's done
> > > they can just use xmit_lock and everyone will be happy again.
> > 
> > As long as the tx completion is all done in NAPI, it can use BH
> > disabling
> > without irq disabling.
> 
> Yes, TG3 does not disable IRQs when taking its TX lock.  So do you see
> any problems with replacing the TG3 TX lock using xmit_lock?

I don't see any.

Thanks for reminding me about the IRQ vs. BH disabling issue.

It will come back when net channels arrive :-) This is because net
channel drivers will do all the work in hard IRQs and not in a NAPI or
NAPI-like context.

The only regret I have about that is we will go back to not being able
to profile ->hard_start_xmit() very well in such drivers.
