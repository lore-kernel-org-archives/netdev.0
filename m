From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Fri, 23 Jun 2006 13:35:25 +1000
Message-ID: <20060623033525.GA11751@gondor.apana.org.au>
References: <20060619134227.GA16662@gondor.apana.org.au> <1150727009.5815.72.camel@jzny2> <20060619142928.GA17191@gondor.apana.org.au> <1150727810.5815.78.camel@jzny2> <20060619223326.GA20354@gondor.apana.org.au> <1150814526.5270.64.camel@jzny2> <20060620235207.GA31493@gondor.apana.org.au> <1151004682.5392.97.camel@jzny2> <20060622224302.GA10136@gondor.apana.org.au> <1151023937.5099.40.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40208 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932098AbWFWDfn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 23:35:43 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1151023937.5099.40.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 08:52:17PM -0400, jamal wrote:
> 
> It does feel like the qdisc_is_running though is now a replacement
> for the need for dev->txlock which existed to protect multi-cpus from
> entering the device transmit path. Is that unintended side effect?
> i.e why would dev->txlock be needed anymore in that path?

It's not totally redundant yet since you can set tx_queue_len to zero.
It also still protects against the asynchronous paths that take xmit_lock.
However, it wouldn't be a bad idea to see if there is a way to reduce the
number of locks required on the xmit path to one.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
