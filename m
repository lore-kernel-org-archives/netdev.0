From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netif_tx_disable vs netif_stop_queue (possible races?)
Date: Sat, 10 Jun 2006 09:35:31 +1000
Message-ID: <20060609233531.GA15756@gondor.apana.org.au>
References: <E1FoYoi-0001gg-00@gondolin.me.apana.org.au> <448993C9.8040400@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, david-b@pacbell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16905 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030388AbWFIXxb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 19:53:31 -0400
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <448993C9.8040400@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 09, 2006 at 04:29:13PM +0100, Daniel Drake wrote:
> 
> Can I interpret your response as: If the TX queue is disabled in 
> advance, no hard_start_xmit functions will be running on any CPU after 
> synchronize_net() has returned?

Correct.  All callers of hard_start_xmit do so under RCU or equivalent
locks so they must be complete by the time synchronize_net() returns.

What you got watch out for though are paths where the driver might
reenable the queue.  That could be a real bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
