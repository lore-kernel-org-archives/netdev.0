From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 13:10:05 +1100
Message-ID: <20050114021005.GA11962@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net> <Pine.LNX.4.58.0501131741430.25252@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0501131741430.25252@w-sridhar.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 13, 2005 at 05:50:17PM -0800, Sridhar Samudrala wrote:
> 
> I think with this patch we will start seeing
> sk_wmem_queued assertions.

Not necessarily.  What's probably happening currently is that
sk_forward_alloc is temporarily raised above the value it should
have.  It then gets cut down by the reclaim function and
subsequently goes negative.

Since there is no reclaim for sk_wmem_queued it doesn't happen
there.

So taking out the adjustments should not cause any problems of
sk_wmem_queued, theoretically :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
