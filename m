From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: issue with new TCP TSO stuff
Date: Fri, 13 May 2005 09:52:36 +1000
Message-ID: <20050512235236.GA22658@gondor.apana.org.au>
References: <20050512221046.GA22136@gondor.apana.org.au> <20050512.155230.132927874.davem@davemloft.net> <20050512231038.GA22440@gondor.apana.org.au> <20050512.162426.75782784.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050512.162426.75782784.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 12, 2005 at 04:24:26PM -0700, David S. Miller wrote:
> 
> Ok, the two true downfalls of the current TSO code are:

You're spot on.
 
> #2 could be handled by down-sizing TSO frames when packet loss occurs.
> Ie. tcp_retransmit_skb() or whatever will segmentize a TSO packet
> which is within the sequence it is trying to retransmit.  Implementing
> this is non- trivial mostly due to the fact that it has to work handle
> GFP_ATOMIC memory failures and also get all the pcount crap correct.

I think most of the code to do that might already be there.  Pity
we'll have to keep track of the pcount though.

> #1 is more tricky, and is the main reason I explored the "TSO
> Reloaded" idea.  I wonder if we could just build enormous TSO frames
> _always_.  We pass down these huge things to the output path, with a

I agree that this is the way to go.

> and size appropriately.  I think the tcp_snd_test() simplifications
> made by my TSO Reloaded patch would help a lot here.  The send test is
> logically now split to it's two tests 1) whether to send anything at
> all, and 2) once #1 passes, how many such packets.

That was another one of my comments to your patch :) I was going to
suggest that we move the cwnd/in_flight loop from tcp_snd_test to
emit_send_queue.

> This would be a sort of super-TSO that would do less segmenting work
> than even a "perfect" TSO segmenter would.
> 
> I'm still not sure which approach is best, just throwing around some
> ideas.

On paper your new super-TSO approach sounds the best.  However, I
suppose we won't know for sure until we try :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
