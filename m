From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Super TSO v3
Date: Tue, 24 May 2005 12:32:57 +1000
Message-ID: <20050524023256.GA29242@gondor.apana.org.au>
References: <20050523.121943.78708600.davem@davemloft.net> <20050524003208.GA25778@gondor.apana.org.au> <20050523.192917.48530622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050523.192917.48530622.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2005 at 07:29:17PM -0700, David S. Miller wrote:
>
> > Should we skip this step if the socket has Nagle turned off?
> 
> No, that Nagle is trying to achieve something different (optimize
> request/response type communication) compared to what we're doing
> here (optimizing the number of transmit calls per byte during a
> bulk transfer, without allowing the congestion window to empty
> too much).

True, the Nagle algorithm itself aims to do something different
from this function.  However, the act of turning Nagle off is
an indication that the application wants to minimise the latency
by sending things out ASAP.  So we should either respect that
here by not delaying the packets to increase the TSO size, or
we'll need a new socket option to do that for TSO.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
