From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 09:10:38 +1000
Message-ID: <20050512231038.GA22440@gondor.apana.org.au>
References: <20050512.131349.32715242.davem@davemloft.net> <20050512214744.GA21958@gondor.apana.org.au> <20050512221046.GA22136@gondor.apana.org.au> <20050512.155230.132927874.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050512.155230.132927874.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 03:52:30PM -0700, David S. Miller wrote:
> 
> The "scp largefile dest:" test case went down from 4.6MB/sec
> to 4.3MB/sec when I enable TSO on the tg3 device with the
> new TSO code.

OK, I'm sure we can optimise the code so that it beats the
non-TSO case.

However, I think you're right that this does have some fundamental
overheads compared to the existing TSO code which we can't remove.

More specifically, the existing TSO code really does avoid
segmentation in that no MTU-sized skb's are allocated unless
the congestion window requires that to be done.  The new code
will always allocate MTU-sized skb's no matter what.

The ideal solution should bring the best of both worlds :) That is,
no segmentation on output unless required by the congestion window,
while at the same time avoiding the tcp_skb_pcount logic.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
