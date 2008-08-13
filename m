From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 15:31:18 +1000
Message-ID: <20080813053118.GA31785@gondor.apana.org.au>
References: <20080812.011510.20845920.davem@davemloft.net> <E1KT803-00086Y-00@gondolin.me.apana.org.au> <20080812.221103.91087925.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58363 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751487AbYHMFbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 01:31:25 -0400
Content-Disposition: inline
In-Reply-To: <20080812.221103.91087925.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 12, 2008 at 10:11:03PM -0700, David Miller wrote:
>
> So, just like one of Jarek's patches, we should simply change
> dev_queue->qdisc into dev_queue->qdisc_sleeping and that should
> take care of the bulk of the issues.
> 
> Shouldn't it?

Yes you're absolutely right, this takes care of the running qdiscs.

> Hmmm... maybe we have to sample __QDISC_STATE_SCHED too.

You need this too for the ones which aren't running but sitting
on output_queue.  Either you'll have to forcibly remove them as
I outlined earlier, or just wait for them to expire naturally.

The latter would seem more suitable since we're waiting anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
