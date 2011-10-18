From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
	causes kernel oops
Date: Tue, 18 Oct 2011 13:49:45 +0200
Message-ID: <20111018114945.GA16359@gondor.apana.org.au>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com> <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com> <1318905032.2571.35.camel@edumazet-laptop> <20111018093411.GA15165@gondor.apana.org.au> <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111018100527.GA15383@gondor.apana.org.au> <1318933423.2657.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20111018104504.GA15913@gondor.apana.org.au> <1318937878.2657.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318937878.2657.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2011 at 01:37:58PM +0200, Eric Dumazet wrote:
>
> In the bug we try to fix, we have :
> 
> skb = sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.dev) 
> 
> ... < increase of dev->needed_headroom by another cpu/task >
> 
> skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));

OK, in that case one fix would be to replace LL_ALLOCATED_SPACE
with its two constiuents so that they may be stored in local
variables for later use.

	hlen = LL_HEADROOM(skb);
	tlen = LL_TAILROOM(skb);
	skb_alloc_send_skb(sk, ... + LL_ALIGN(hlen + tlen));

	skb_reserve(skb, LL_ALIGN(hlen));

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
