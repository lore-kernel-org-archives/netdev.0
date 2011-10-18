From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
	causes kernel oops
Date: Tue, 18 Oct 2011 12:05:27 +0200
Message-ID: <20111018100527.GA15383@gondor.apana.org.au>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com> <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com> <1318905032.2571.35.camel@edumazet-laptop> <20111018093411.GA15165@gondor.apana.org.au> <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2011 at 12:01:33PM +0200, Eric Dumazet wrote:
>
> Adding an RCU protected structure to hold hard_header_len /
> needed_headroom / needed_tailroom should be possible, but this adds yet
> another pointer dereference...

I don't think we need RCU here since the problem is simply that
we're using two different values for skb allocations and skb_reserve.

As long as we use one and the same value it should work.  The value
will rarely be incorrect and when it is, automatic reallocation will
occur.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
