From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Wed, 29 Jul 2009 10:12:12 +0800
Message-ID: <20090729021212.GA1946@gondor.apana.org.au>
References: <20090729004428.GA765@gondor.apana.org.au> <20090728.180647.241258705.davem@davemloft.net> <20090729012523.GA1583@gondor.apana.org.au> <20090728.183451.93398827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57517 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751334AbZG2CMW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 22:12:22 -0400
Content-Disposition: inline
In-Reply-To: <20090728.183451.93398827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 28, 2009 at 06:34:51PM -0700, David Miller wrote:
>
> Wouldn't that bypass any rate limiting enforcement done by
> the qdisc too?

You'd only bypass it for the default qdisc (or any other qdisc
that didn't care).  It can either be achived through a flag as
Krishna proposed or perhaps we can make the qdisc's enqueue
function return a special value that indicates the packet can
be dequeued immediately and given to the hardware.

I don't have a good answer for how we can achieve CPU scalability
for rate limiting qdiscs yet.  However, that shouldn't stop us
from getting better CPU scalability for the default qdisc which
is what most people will use for the time being.

One possibility is to partition the bandwidth equally between
the queues and apply rate limiting locally within each queue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
