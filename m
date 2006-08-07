From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Mon, 7 Aug 2006 14:21:30 +1000
Message-ID: <20060807042130.GA3943@gondor.apana.org.au>
References: <20060806230406.GA1413@gondor.apana.org.au> <1551EAE59135BE47B544934E30FC4FC093FA18@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	shemminger@osdl.org, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38152 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751042AbWHGFIl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Aug 2006 01:08:41 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FA18@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 08:56:31PM -0700, Michael Chan wrote:
>
> > Because netif_queue_stopped is *not* a memory barrier, it can float
> > above the assignment to tx_cons.  So even though netif_stop_queue *is*
> > a memory barrier on x86, the second BUFF_AVAIL test can still fail to
> > see the updated index.
> > 
> > The fix here is obviously to add a memory barrier in tg3_tx.
> 
> You are absolutely right and I missed it.  We should add a wmb()
> after the tx_cons update in tg3_tx().  Thanks.

A wmb() only prevents stores from passing stores.  We need to prevent
a load from passing a store so you need a full memory barrier (smp_mb).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
