From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: 27 Sep 2004 08:46:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096289189.1075.37.camel@jzny.localdomain>
References: <1095647944.1046.206.camel@jzny.localdomain>
	 <20040920025802.GA11567@gondor.apana.org.au>
	 <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net>
	 <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net>
	 <20040922045239.GA19573@gondor.apana.org.au>
	 <1095854920.1047.64.camel@jzny.localdomain>
	 <20040923120707.GB32624@gondor.apana.org.au>
	 <1095995042.1044.34.camel@jzny.localdomain>
	 <20040924032440.GB6384@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040924032440.GB6384@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-09-23 at 23:24, Herbert Xu wrote:

> There are three possible netlink usages:
> 
> 1) Request/response:
> 
> No overruns should occur.

Cant assume this. A request for an ACK is fine. A get is a different
ball game.

> 2) Dump:
> 
> No overruns should occur because of dump only fills in the next one when
> the previous one is taken off the queue by the user.
> 
> 3) Async messages:
> 
> Overruns may occur if the arrival rate exceeds the application's
> processing capacity or if the queue is too small for a burst.
> 
> Now we were discussing about how we can do congestion control for 3).
> But to do that we need to know exactly what these messages are.  For
> example if they're coming from an external source as is the case in
> ip_queue then you can't congestion control it at all.
> 
> Oh and never use the same socket for 1+2) and 3) together.  You can
> use the socket for 1) and 2), but 3) must be in its own socket.

I think the discussion to have a mini-slab-like allocator for netlink
that i see going on in other thread is what we need. However, so far
that seems to be only useful for 2).

cheers,
jamal
