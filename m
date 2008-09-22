From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Mon, 22 Sep 2008 15:54:40 +0200
Message-ID: <20080922135440.GC9549@secunet.com>
References: <20080920.125949.193703969.davem@davemloft.net> <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au> <20080921094628.GA22453@secunet.com> <20080922082309.GA25739@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dwalker@mvista.com,
	arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:53600 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbYIVNyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 09:54:40 -0400
Content-Disposition: inline
In-Reply-To: <20080922082309.GA25739@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 04:23:09PM +0800, Herbert Xu wrote:
> 
> > With my test environment (two quad core boxes) I get with IPSEC
> > aes192-sha1 and one tcp stream a throughput of about 600 Mbit/s
> > compared to about 200 Mbit/s without the parallel processing. 
> 
> Yes this would definitely help IPsec.  However, I'm not so sure
> of its benefit to routing and other parts of networking.  That's
> why I'd rather have this sort of hack stay in the crypto system
> where it's isolated rather than having it proliferate throughout
> the network stack.

The crypto benefits the most of course, but routing and xfrm lookups
could benefit on bigger networks too. However, the method to bring
the packets back to order is quite generic and could be used
even in the crypto system. The important thing for me is that we
can run in parallel even if we have just one flow.

> 
> When the time comes to weed out this because all CPUs that matter
> have encryption in hardware then it'll be much easier to delete a
> crypto algorithm as opposed to removing parts of the network
> infrastructure :)
> 

Yes, if you think about how to remove it I agree here.
