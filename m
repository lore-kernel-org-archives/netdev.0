From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga)
 causes kernel oops
Date: Thu, 20 Oct 2011 05:30:50 -0400 (EDT)
Message-ID: <20111020.053050.383972361986316046.davem@davemloft.net>
References: <1319008713.17914.8.camel@edumazet-laptop>
	<20111019.033052.851679720607111734.davem@davemloft.net>
	<20111019080807.GA25099@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, evonlanthen@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: herbert@gondor.hengli.com.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111019080807.GA25099@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Wed, 19 Oct 2011 10:08:07 +0200

> I think Eric's initial patch is probably the safest bet for rc10.
> We can then work on the proper fix for the next release.

There are two "initial patch", I wonder which one you mean.

There's his really first patch, which remoevs the lines in IP_GRE
which change dev->needed_headroom.  I was under the impression we
were against doing that.

The other patch he posted duplicates the device attribute variable
caching in two functions.

My patch is just a tweak so that we only do this sequence in one
place, the new sock_alloc_send_skb_reserve() helper, instead of
in both the ipv4 and ipv6 RAW code.

So I'm a little confused what your suggestion for rc10 really
is :-)
