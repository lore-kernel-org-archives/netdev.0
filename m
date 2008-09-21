From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sun, 21 Sep 2008 11:46:28 +0200
Message-ID: <20080921094628.GA22453@secunet.com>
References: <20080920.125949.193703969.davem@davemloft.net> <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dwalker@mvista.com,
	arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:48485 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751398AbYIUKWu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Sep 2008 06:22:50 -0400
Content-Disposition: inline
In-Reply-To: <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 03:05:45PM +0900, Herbert Xu wrote:
> David Miller <davem@davemloft.net> wrote:
> >
> > receive using multiple RX queues and MSI-X interrupts.  It's
> > also for things like IPSEC where the per-packet cpu usage
> > is so huge (to do the crypto) that it makes sense to even
> > split up the work to multiple cpus within the same flow.
> 
> Unfortunately doing this with IPsec is going to be non-trivial
> since we still want to maintain packet ordering inside IPsec
> and you don't get the inner flow information until you decrypt
> the packet.

It's non-trivial but possible. I have a test implementation that
runs the whole IP layer in parallel. The basic idea to keep track
of the packet ordering is to give the packets sequence numbers
befor we run in parallel. Befor we push the packets to the upper
layers or to the neighboring subsystem I have a mechanism that
brings them back to the right order. 

With my test environment (two quad core boxes) I get with IPSEC
aes192-sha1 and one tcp stream a throughput of about 600 Mbit/s
compared to about 200 Mbit/s without the parallel processing. 
