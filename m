From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Tue, 2 Dec 2003 21:10:25 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202101025.GA25422@gondor.apana.org.au>
References: <20031201201651.GA20194@gondor.apana.org.au> <20031201204700.GA20349@gondor.apana.org.au> <20031201135154.6906454c.davem@redhat.com> <20031201220509.GA20827@gondor.apana.org.au> <20031201142131.5da50a07.davem@redhat.com> <20031201152215.522c2447.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031201152215.522c2447.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2003 at 03:22:15PM -0800, David S. Miller wrote:
> 
> You are speaking of a case of zero source addresses.  When would
> we output such an iph->saddr, by way of a route?  Right now this
> is the only part I'm not seeing.

You're right.  My patch is totally bogus.

I misread the ip(8) output.  I thought that if src wasn't shown that
rt_src must be zero.  But in fact it means that rt_src == fl4_src.

My problem turns out to be that oif != 0 for the outgoing packets.
Since frag_needed only handle cache entries where oif == 0 it
never has a chance to work.

The application that generated these packets is the RPC code in glibc.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
