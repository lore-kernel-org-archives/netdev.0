From: "David S. Miller" <davem@davemloft.net>
Subject: Re: design for TSO performance fix
Date: Fri, 28 Jan 2005 11:28:38 -0800
Message-ID: <20050128112838.21e53b6c.davem@davemloft.net>
References: <20050127163146.33b01e95.davem@davemloft.net>
	<E1CuKzJ-0001mY-00@gondolin.me.apana.org.au>
	<20050127211940.31f97ed3.davem@davemloft.net>
	<20050128054441.GA8260@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050128054441.GA8260@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 16:44:41 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Colour me confused then.  How are you going to remember the
> packet boundaries which we need to do if we're going to keep
> counting packets instead of bytes?

It's just like how the code was before I added all of
that tcp_pcount_t code.  The retransmit queue only
ever contains normal MSS sized frames.

When we decide to send something off the queue, we try
to build them up into TSO frames.

Congestion control etc. decisions are still made by packet
counting.

When we get ACKs and SACKs back, we can just trim and mark the
retransmit queue in the simplest way since we don't have
TSO packets in there anymore.

TSO packets only exist in the tcp_transmit_skb() path,
nothing else in the stack sees them.
