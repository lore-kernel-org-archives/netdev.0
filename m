From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Super TSO v3
Date: Mon, 23 May 2005 19:29:17 -0700 (PDT)
Message-ID: <20050523.192917.48530622.davem@davemloft.net>
References: <20050523.121943.78708600.davem@davemloft.net>
	<20050524003208.GA25778@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050524003208.GA25778@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Super TSO v3
Date: Tue, 24 May 2005 10:32:08 +1000

> On Mon, May 23, 2005 at 07:19:43PM +0000, David S. Miller wrote:
> > 
> > The guts of the logic is in tcp_tso_should_defer().  And
> > when dealing with a TSO frame, tcp_write_xmit() calls
> > this instead of tcp_nagle_test().  So you can view this
> > deferral as a sort of "TSO Nagle".
> 
> Should we skip this step if the socket has Nagle turned off?

No, that Nagle is trying to achieve something different (optimize
request/response type communication) compared to what we're doing
here (optimizing the number of transmit calls per byte during a
bulk transfer, without allowing the congestion window to empty
too much).

> Also why are we doing this check in tcp_push_one? The only
> way we can get there is if the TSO goal has been reached
> or there is out-of-band stuff to send.

Good point, that copy of the test can be removed.
