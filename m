From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sun, 6 Feb 2005 05:32:18 +1100
Message-ID: <20050205183218.GA11716@gondor.apana.org.au>
References: <20050205061110.GA18275@gondor.apana.org.au> <20050204221344.247548cb.davem@davemloft.net> <20050205064643.GA29758@gondor.apana.org.au> <20050205.195039.05988480.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mirko.parthey@informatik.tu-chemnitz.de,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, shemminger@osdl.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050205.195039.05988480.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Feb 05, 2005 at 07:50:39PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Yes, IPv6 needs "split device" semantics
> (for per-device statistics such as Ip6InDelivers etc),
> and I like later solution.

OK.  Is there any reason why IPv4 should be different from IPv6 in
this respect though?

If the split device dst's are to be kept, we'll need a way to clean
them up.  There are two choices:

1) Put the dst's on IPv6's own GC so that we can search by rt6i_idev.
2) Change the generic GC so that dst->ops->ifdown is always called even
if dst->dev does not match with the device going down.  We also need to
change the individual ifdown functions to check for ->dev.  The IPv6
ifdown function can then check for ->rt6i_idev as well.

What's your preference?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
