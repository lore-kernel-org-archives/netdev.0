From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: IPsec and Path MTU
Date: Thu, 17 Jun 2004 23:01:58 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617190158.GA10925@ms2.inr.ac.ru>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616195653.GC29781@ms2.inr.ac.ru> <20040616231317.GA5742@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040616231317.GA5742@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> The problem is that each bundle can have only one PMTU.  But
> there can be an arbitrary number of paths over each bundle.

Seems, I still do not understand what you mean.

Returning to the beginning:

> 			But this is wrong because it assigns
> a single MTU to all hosts behind an IPsec gateway, even though their
> paths may well diverge beyond the gateway.

Diverge where exactly? On path where packets are transformed? PMTU discovery
cannot do something clever for this case: we receive only small piece
of transformed datagram, in the best case with SPI in it, so we
can only update pmtu not even on bundle, but on even wider aggregate,
on SA itself. This part is missing now, by the way, it is to be done
inside error handlers in transformations.

>From another hand, if it is an ICMP from beyond another end of tunnel,
it is problem of original senders to handle them. Gateways even do not
see such ICMPs, which are destined not for them.

Alexey
