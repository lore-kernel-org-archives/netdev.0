From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Fri, 24 Sep 2004 13:24:40 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924032440.GB6384@gondor.apana.org.au>
References: <1095647944.1046.206.camel@jzny.localdomain> <20040920025802.GA11567@gondor.apana.org.au> <1095683660.1047.254.camel@jzny.localdomain> <414F1E12.6010808@eurodev.net> <20040922000503.GA13218@gondor.apana.org.au> <4150E7E5.2000001@eurodev.net> <20040922045239.GA19573@gondor.apana.org.au> <1095854920.1047.64.camel@jzny.localdomain> <20040923120707.GB32624@gondor.apana.org.au> <1095995042.1044.34.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1095995042.1044.34.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 23, 2004 at 11:04:02PM -0400, jamal wrote:
> 
> So lets start by using the following logic:
> 1) If you made the socket buffers small enough compared to message
> size/arrival rate, then an overrun will happen
> corrollary:
> 2) If you made the message size/arrival fast enough relative to socket
> size, an overrun will happen
> 
> If you agree that #1 is equivalent to #2, then you can experiment by #1
> to see the issue.

There are three possible netlink usages:

1) Request/response:

No overruns should occur.

2) Dump:

No overruns should occur because of dump only fills in the next one when
the previous one is taken off the queue by the user.

3) Async messages:

Overruns may occur if the arrival rate exceeds the application's
processing capacity or if the queue is too small for a burst.

Now we were discussing about how we can do congestion control for 3).
But to do that we need to know exactly what these messages are.  For
example if they're coming from an external source as is the case in
ip_queue then you can't congestion control it at all.

Oh and never use the same socket for 1+2) and 3) together.  You can
use the socket for 1) and 2), but 3) must be in its own socket.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
