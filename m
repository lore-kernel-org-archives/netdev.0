From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 10:05:51 +1000
Message-ID: <20080819000551.GA26699@gondor.apana.org.au>
References: <20080817.153218.178334822.davem@davemloft.net> <20080818201236.GA3366@ami.dom.local> <20080818.165411.255925269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49527 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752700AbYHSAF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 20:05:59 -0400
Content-Disposition: inline
In-Reply-To: <20080818.165411.255925269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2008 at 04:54:11PM -0700, David Miller wrote:
> 
> Yep, and that's the lock debugging thing which is triggering now.
> Likely what I'll do is simply reinstate RCU but only for the freeing
> of the memory, nothing more.
> 
> This keeps everything doing destruction under RTNL as desired,
> yet fixes the "we're holding lock that's being freed" problem.

Is this the problem with dev_shutdown freeing the qdisc while
holding its lock?

Couldn't we just drop the lock before calling qdisc_destroy?

dev_shutdown can only be called after dev_deactivate, as such
all qdisc users should have disappeared by now (and if they
haven't, our waiting loop in dev_deactivate didn't work and
we should fix that).

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
