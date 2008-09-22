From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Mon, 22 Sep 2008 16:23:09 +0800
Message-ID: <20080922082309.GA25739@gondor.apana.org.au>
References: <20080920.125949.193703969.davem@davemloft.net> <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au> <20080921094628.GA22453@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dwalker@mvista.com,
	arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56629 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751630AbYIVIXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 04:23:42 -0400
Content-Disposition: inline
In-Reply-To: <20080921094628.GA22453@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 11:46:28AM +0200, Steffen Klassert wrote:
>
> It's non-trivial but possible. I have a test implementation that
> runs the whole IP layer in parallel. The basic idea to keep track
> of the packet ordering is to give the packets sequence numbers
> befor we run in parallel. Befor we push the packets to the upper
> layers or to the neighboring subsystem I have a mechanism that
> brings them back to the right order. 

Yes that should do the trick.

> With my test environment (two quad core boxes) I get with IPSEC
> aes192-sha1 and one tcp stream a throughput of about 600 Mbit/s
> compared to about 200 Mbit/s without the parallel processing. 

Yes this would definitely help IPsec.  However, I'm not so sure
of its benefit to routing and other parts of networking.  That's
why I'd rather have this sort of hack stay in the crypto system
where it's isolated rather than having it proliferate throughout
the network stack.

When the time comes to weed out this because all CPUs that matter
have encryption in hardware then it'll be much easier to delete a
crypto algorithm as opposed to removing parts of the network
infrastructure :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
