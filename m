From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 22:35:38 +1000
Message-ID: <20080821123538.GA8703@gondor.apana.org.au>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59617 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750999AbYHUMfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:35:44 -0400
Content-Disposition: inline
In-Reply-To: <20080821.052754.104318066.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 05:27:54AM -0700, David Miller wrote:
> 
> This looks even worse, actually.
> 
> If we just unlinked this thing, we don't want anyone finding
> it, even before we grab this lock, to adjust queue counts.

You're right, this doesn't work at all.  In fact it's been broken
even before we removed the root lock.  The problem is that we used
to have one big linked list for each device.  That was protected
by the device qdisc lock.  Now we have one list for each txq and
qdisc_lookup walks every single txq.  This means that no single
qdisc root lock can protect this anymore.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
