From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tg3 reset_task question
Date: Thu, 5 Apr 2007 21:58:07 +1000
Message-ID: <20070405115807.GB10972@gondor.apana.org.au>
References: <d66d623f0704041334m5e0c68ebw777f621c779e1153@mail.gmail.com> <1175722621.7911.63.camel@dell> <4614105B.4080105@gmail.com> <20070404151007.2648621f@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3795 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1766962AbXDEL6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 07:58:42 -0400
Content-Disposition: inline
In-Reply-To: <20070404151007.2648621f@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 04, 2007 at 10:10:07PM +0000, Stephen Hemminger wrote:
>
> > > Yes, you're right.  Perhaps we should get the rtnl first before
> > > tg3_full_lock(), or turn irq_sync into an atomic counter that allows
> > > nesting.
> 
> When you start reinventing windows locks or the BKL, you know
> you are going down the wrong path

Actually, I think what Michael's suggesting is quite different.
This would be a simple counter that tells the IRQ handlers to
not process any events.  So this isn't really a lock as such.

FWIW I think the counter sounds better than using the RTNL since
with the latter you'd have to figure out whether you're in an
RTNL context or not (e.g., tg3_suspend would also need to grab it).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
