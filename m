From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Check connect address in NETLINK
Date: Tue, 29 Jun 2004 12:22:52 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629082252.GA26866@ms2.inr.ac.ru>
References: <20040628231439.GA3021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040628231439.GA3021@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> The solution seems simple.  We already have a connect(2) call for
> NETLINK sockets.  So why don't we check the connected address of
> the destination socket against the address of the sender before
> putting the packet on the queue?

Do you mean the restriction sort of made in AF_UNIX SOCK_DGRAM:
a connected socket receives messages only from its destination?

I think this is safe.

It was not done because netlink sockets were expected to listen
for broadcasts, so that this kind of protection would be not useful
and even harmful. But taking into account that inter-application
communication is not used, only kernel sends broadcasts and applications
talking to kernel will receive such broadcasts, because they are connected
to kernel.

The troube is that pid of kernel socket used to be 0, so that
applications connected to kernel are not connected in technical sense. :-)
Apparently, to implement this we have to add some kind of flag
marking connected sockets.

Alexey
