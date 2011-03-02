From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 2 Mar 2011 10:39:20 +0800
Message-ID: <20110302023920.GA16072@gondor.apana.org.au>
References: <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301115305.GA6984@gondor.apana.org.au> <1298984609.3284.98.camel@edumazet-laptop> <20110301131823.GB8028@gondor.apana.org.au> <1298997084.3284.119.camel@edumazet-laptop> <20110302002353.GA15009@gondor.apana.org.au> <1299031203.2930.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51712 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab1CBCjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 21:39:46 -0500
Content-Disposition: inline
In-Reply-To: <1299031203.2930.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 02, 2011 at 03:00:03AM +0100, Eric Dumazet wrote:
> > 
> > Think about it, a TCP socket cannot be used by a multi-threaded app
> > in a scalable way.
> 
> Well...
> 
> If you think about it, SO_REUSEPORT patch has exactly the same goal : 

UDP is a datagram protocol, TCP is not.

Anyway, here is an alternate proposal.  When a TCP socket transmits
for the first time (SYN or SYN-ACK), we pick a queue based on CPU and
store it in the socket.  From then on we stick to that selection.

We would only allow changes if we can ensure that all transmitted
packets have left the queue.  Or we just never change it like we
do now.

For datagram protocols we simply use the current CPU.

> We added RPS and XPS that works correctly if each socket is used by one
> thread. Maybe we need to add an user API or automatically detect a
> particular DGRAM socket is used by many different threads to :

No we don't need that for datagram protocols at all.  By definition
there is no ordering guarantee across CPUs for datagram sockets.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
