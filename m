From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Check connect address in NETLINK
Date: Tue, 29 Jun 2004 18:45:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629084552.GA6202@gondor.apana.org.au>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040629082252.GA26866@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 12:22:52PM +0400, Alexey Kuznetsov wrote:
> 
> Do you mean the restriction sort of made in AF_UNIX SOCK_DGRAM:
> a connected socket receives messages only from its destination?

Exactly.  Another example would be UDP over IP.

> It was not done because netlink sockets were expected to listen
> for broadcasts, so that this kind of protection would be not useful
> and even harmful. But taking into account that inter-application
> communication is not used, only kernel sends broadcasts and applications
> talking to kernel will receive such broadcasts, because they are connected
> to kernel.

I've had a look in the various NETLINK applications that I know of,
including quagga/iproute/iptables and all the stuff that I wrote, 
none of them does a connect at all.

So it should be harmless to introduce this new semantics.

> The troube is that pid of kernel socket used to be 0, so that
> applications connected to kernel are not connected in technical sense. :-)

That's kind of a good thing since it means that existing applications
are less likely to call connect(2) :)

> Apparently, to implement this we have to add some kind of flag
> marking connected sockets.

Or we can set the disconnected pid to a negative value since POSIX
requires pid_t to be signed.  I see that you've reserved everything
between -4096 and 0.  So perhaps we can pick -1?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
