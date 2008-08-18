From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 11:36:33 +1000
Message-ID: <20080818013633.GA31653@gondor.apana.org.au>
References: <20080817.155723.214209606.davem@davemloft.net> <20080817.160329.121812684.davem@davemloft.net> <20080818012516.GB31337@gondor.apana.org.au> <20080817.183505.163224950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58034 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750870AbYHRBgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 21:36:39 -0400
Content-Disposition: inline
In-Reply-To: <20080817.183505.163224950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 06:35:05PM -0700, David Miller wrote:
>
> That's why I got rid of the "resample" code in these places
> and tried to move everything into RCU.

Right.

> I think I see another way out of this:
> 
> 1) Add __QDISC_STATE_DEACTIVATE.
> 
> 2) Set it right before dev_deactivate() swaps resets the qdisc
>    pointer.
> 
> 3) Test it in dev_queue_xmit() et al. once the qdisc root lock is
>    acquired, and drop lock and resample ->qdisc if
>    __QDISC_STATE_DEACTIVATE is set.

Yep this sounds good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
