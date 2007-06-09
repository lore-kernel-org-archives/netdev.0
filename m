From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Sat, 9 Jun 2007 21:08:19 +1000
Message-ID: <20070609110819.GA3092@gondor.apana.org.au>
References: <1181253445.4071.4.camel@localhost> <20070607.154421.109060486.davem@davemloft.net> <1181256848.4071.57.camel@localhost> <20070607.160035.00774597.davem@davemloft.net> <1181262703.3688.10.camel@w-sridhar2.beaverton.ibm.com> <1181266536.4741.27.camel@localhost> <20070608103925.GA23598@gondor.apana.org.au> <1181302497.4063.37.camel@localhost> <20070608123735.GA24582@gondor.apana.org.au> <1181308372.4063.126.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	jeff@garzik.org, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1493 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752717AbXFILJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 07:09:19 -0400
Content-Disposition: inline
In-Reply-To: <1181308372.4063.126.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 09:12:52AM -0400, jamal wrote:
> 
> To mimick that behavior in LLTX, a driver needs to use the same lock on
> both tx and receive. e1000 holds a different lock on tx path from rx
> path. Maybe theres something clever i am missing; but it seems to be a
> bug on e1000.

It's both actually :)

It takes the tx_lock in the xmit routine as well as in the clean-up
routine.  However, the lock is only taken when it updates the queue
status.

Thanks to the ring buffer structure the rest of the clean-up/xmit code
will run concurrently just fine.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
