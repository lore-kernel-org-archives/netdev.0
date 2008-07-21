From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in	RCU.
Date: Mon, 21 Jul 2008 21:19:18 +0800
Message-ID: <20080721131918.GA11114@gondor.apana.org.au>
References: <E1KKu2D-0002kd-00@gondolin.me.apana.org.au> <1216645724.4847.275.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53406 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753912AbYGUNTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 09:19:30 -0400
Content-Disposition: inline
In-Reply-To: <1216645724.4847.275.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2008 at 09:08:44AM -0400, jamal wrote:
>
> The one thing i am unsure of still:
> I think it would be cleaner to just stop a single queue (instead of all)
> when one hardware queue fills up. i.e if there is no congestion on the
> other hardware queues, packets should continue to be fed to their
> hardware queues and not be buffered at qdisc level.

Right you don't necessarily have to stop all queues but you do
need to direct all packets into the qdisc.

> Parallelization would work if you can get X CPUs to send to X hardware
> queues concurently. Feasible in static host setup like virtualization
> environment where you can tie a vm to a cpu. Not very feasible in
> routing where you are driven to a random hardware tx queue by arriving
> packets.

It should work just fine for routing assuming your card does
multi-queue RX.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
