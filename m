From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Fri, 18 Jun 2004 09:09:18 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617230918.GA14739@gondor.apana.org.au>
References: <20040616202341.GD29781@ms2.inr.ac.ru> <E1BajZO-0001UK-00@gondolin.me.apana.org.au> <20040617105843.314dfe30.davem@redhat.com> <20040617213130.GB14089@gondor.apana.org.au> <20040617152216.00a5cec9.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040617152216.00a5cec9.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 03:22:16PM -0700, David S. Miller wrote:
> 
> Right.  I'm sorry, is someone trying to do NFS/UDP over IPSEC?
> My condolences.  :-)

Nope, it breaks TCP as well.  Whether you're TCP/UDP or whatever,
you have to pass xfrm4_tunnel_check_size().  That function uses
an incorrect derivation of the MTU, thus potentially blocking
maximal packets from getting through.

As I said before, this only strikes for certain device MTUs.
So if you're having problems reproducing this, try setting your
device MTU to 1480 (or 1480 + 8x for any integer x).

> More seriously, it is a fringe case.  We do need to handle it,
> but it is no accident that there haven't been very
> many folks complaining about it.

I agree it's not a common problem.  But the reason is not what
you think it is :) It's because the common MTUs 1500, 1492 etc.
are not of the form 1480 + 8x.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
